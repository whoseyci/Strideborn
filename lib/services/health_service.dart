import 'package:health/health.dart';

// ─────────────────────────────────────────────────────────
// Health Service
// Reads step delta since last fetch from HealthKit.
// ─────────────────────────────────────────────────────────

class HealthService {
  static final Health _health = Health();
  static bool _authorized = false;

  static const _types = [HealthDataType.STEPS];
  static const _permissions = [HealthDataAccess.READ];

  /// Request HealthKit permission. Call once on app start.
  static Future<bool> requestPermission() async {
    try {
      _authorized = await _health.requestAuthorization(_types, permissions: _permissions);
      return _authorized;
    } catch (_) {
      return false;
    }
  }

  /// Returns steps taken since [lastFetchTime].
  /// Returns 0 if permission not granted or on error.
  static Future<int> getStepsSince(DateTime lastFetchTime) async {
    if (!_authorized) {
      final granted = await requestPermission();
      if (!granted) return 0;
    }
    try {
      final now = DateTime.now();
      // getHealthDataFromTypes returns individual data points
      final data = await _health.getHealthDataFromTypes(
        types: _types,
        startTime: lastFetchTime,
        endTime: now,
      );
      // Remove duplicates and sum
      final deduped = _health.removeDuplicates(data);
      int total = 0;
      for (final point in deduped) {
        final val = point.value;
        if (val is NumericHealthValue) {
          total += val.numericValue.toInt();
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }
}