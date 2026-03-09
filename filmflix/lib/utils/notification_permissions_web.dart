import 'dart:html' as html;

Future<bool> requestNotificationPermissionImpl() async {
  try {
    final res = await html.Notification.requestPermission();
    return res == 'granted';
  } catch (e) {
    return false;
  }
}
