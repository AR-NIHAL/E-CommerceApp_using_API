import '../../../../core/storage/hive_boxes.dart';

class OnboardingStorage {
  static const String _seenKey = 'onboardingSeen';

  Future<bool> hasSeenOnboarding() async {
    final box = await HiveBoxes.openAuthBox();
    return box.get(_seenKey) as bool? ?? false;
  }

  Future<void> markOnboardingSeen() async {
    final box = await HiveBoxes.openAuthBox();
    await box.put(_seenKey, true);
  }
}
