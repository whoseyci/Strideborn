/// Platform-adaptive storage facade.
///
/// Native (iOS/Android/desktop): Isar database (db_service_native.dart).
/// Web: SharedPreferences/localStorage (db_service_web.dart) — Isar 3.x
/// does not support web. Same API on both, so callers never care.
export 'db_service_native.dart' if (dart.library.html) 'db_service_web.dart';
