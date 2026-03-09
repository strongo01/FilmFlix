import 'notification_permissions_io.dart'
    if (dart.library.html) 'notification_permissions_web.dart';

/// Requests notification permission for the current platform.
/// Returns true when permission was granted.
Future<bool> requestNotificationPermission() => requestNotificationPermissionImpl();
