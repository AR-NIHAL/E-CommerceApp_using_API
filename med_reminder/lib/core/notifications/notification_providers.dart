import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';

/// Provides the singleton [NotificationService] instance.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
