import 'notification_permissions_io.dart'
    if (dart.library.html) 'notification_permissions_web.dart';

/// Vraagt notificatie-permissie aan voor het huidige platform.
/// Geeft true terug als permissie is verleend.
Future<bool> requestNotificationPermission() =>
    requestNotificationPermissionImpl();
