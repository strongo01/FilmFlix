import 'package:permission_handler/permission_handler.dart';

Future<bool> requestNotificationPermissionImpl() async {
  try {
    // On Android (API 33+) and iOS this requests the notification permission.
    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    final req = await Permission.notification.request();
    return req.isGranted;
  } catch (e) {
    return false;
  }
}
