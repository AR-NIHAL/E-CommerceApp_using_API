import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../features/dose_tracking/domain/entities/dose_occurrence.dart';

/// Callback type when user taps on a dose notification.
typedef DoseTapCallback = void Function(String occurrenceId);

/// Service for managing exact local alarms and notifications for scheduled doses.
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  DoseTapCallback? onDoseNotificationTapped;
  bool _isInitialized = false;

  NotificationService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _notificationsPlugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const String channelId = 'medicare_reminder_channel';
  static const String channelName = 'Medicine Reminders';
  static const String channelDescription =
      'Notifications and exact alarms for scheduled medications';

  /// Deterministic integer ID for FlutterLocalNotifications from dose occurrence ID.
  static int doseIdToNotificationId(String occurrenceId) {
    return occurrenceId.hashCode.abs() % 2147483647;
  }

  /// Encodes a dose payload into a JSON string.
  static String encodePayload(DoseOccurrence dose) {
    return jsonEncode({
      'occurrenceId': dose.id,
      'medicineId': dose.medicineId,
      'medicineName': dose.medicineName,
      'scheduledAtUtcIso': dose.scheduledAtUtc.toIso8601String(),
    });
  }

  /// Decodes occurrence ID from a notification payload.
  static String? decodeOccurrenceId(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>;
      return map['occurrenceId'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Initializes timezone data, notification channels, and platform settings.
  Future<void> initialize({DoseTapCallback? onTapped}) async {
    if (_isInitialized) return;

    onDoseNotificationTapped = onTapped;

    // Initialize TimeZone database
    try {
      tz.initializeTimeZones();
    } catch (e) {
      debugPrint('TimeZone initialization note: $e');
    }

    // Android Settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Darwin (iOS / macOS) Settings
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          final occurrenceId = decodeOccurrenceId(response.payload);
          if (occurrenceId != null && onDoseNotificationTapped != null) {
            onDoseNotificationTapped!(occurrenceId);
          }
        },
      );

      // Create high-importance Android channel
      final androidChannel = const AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService init note: $e');
    }
  }

  /// Requests notification permissions on Android 13+ and iOS.
  Future<bool> requestPermissions() async {
    try {
      // Android 13+ permission
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }

      // iOS permission
      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('NotificationService requestPermissions note: $e');
    }

    return true;
  }

  /// Schedules an exact local notification for a specific [DoseOccurrence].
  Future<void> scheduleDose(DoseOccurrence dose, {DateTime? now}) async {
    final currentTime = now ?? DateTime.now();
    final localScheduled = dose.scheduledAtLocal;

    // Do not schedule doses in the past
    if (localScheduled.isBefore(currentTime)) {
      return;
    }

    // Ensure timezone database and local location are initialized
    try {
      tz.initializeTimeZones();
      try {
        tz.local;
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    } catch (_) {}

      final id = doseIdToNotificationId(dose.id);
      final scheduledDate = tz.TZDateTime.from(localScheduled, tz.local);

      final title = 'Time for ${dose.medicineName}';
      final body = '${dose.plannedQuantity.toInt()} ${dose.doseUnit}'
          '${dose.instruction != null ? ' · ${dose.instruction}' : ''}';

      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: encodePayload(dose),
      );
    } catch (e) {
      debugPrint('Failed to schedule notification for dose ${dose.id}: $e');
    }
  }

  /// Schedules upcoming pending doses within the next [daysAhead] window (default 7 days).
  Future<void> schedulePendingDoses(
    List<DoseOccurrence> doses, {
    DateTime? now,
    int daysAhead = 7,
  }) async {
    final currentTime = now ?? DateTime.now();
    final cutoff = currentTime.add(Duration(days: daysAhead));

    for (final dose in doses) {
      if (dose.status != DoseStatus.pending) continue;
      final local = dose.scheduledAtLocal;
      if (local.isAfter(currentTime) && local.isBefore(cutoff)) {
        await scheduleDose(dose, now: currentTime);
      }
    }
  }

  /// Cancels a scheduled notification for a specific dose occurrence.
  Future<void> cancelDose(String occurrenceId) async {
    try {
      final id = doseIdToNotificationId(occurrenceId);
      await _notificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint('Notification cancel error: $e');
    }
  }

  /// Cancels all notifications for a list of doses (e.g. when a medicine is deleted).
  Future<void> cancelDoses(List<DoseOccurrence> doses) async {
    for (final dose in doses) {
      await cancelDose(dose.id);
    }
  }

  /// Cancels all active and scheduled notifications.
  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Notification cancelAll error: $e');
    }
  }

  /// Checks if the app was launched by tapping a notification.
  Future<String?> getInitialNotificationDoseId() async {
    try {
      final launchDetails =
          await _notificationsPlugin.getNotificationAppLaunchDetails();
      if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
        final payload = launchDetails.notificationResponse?.payload;
        return decodeOccurrenceId(payload);
      }
    } catch (e) {
      debugPrint('Notification getInitialNotificationDoseId error: $e');
    }
    return null;
  }
}
