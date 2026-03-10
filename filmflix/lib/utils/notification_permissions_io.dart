import 'package:permission_handler/permission_handler.dart';

Future<bool> requestNotificationPermissionImpl() async {
  try {
    // On Android (API 33+) and iOS this requests the notification permission.
    final status = await Permission.notification.status;
    
    if (status.isGranted) return true;

    // Als we al eerder hebben gevraagd en het is permanent geweigerd, dan tonen we geen pop-up 
    // want het OS weigert dat. In dat geval sturen we de gebruiker naar de instellingen.
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false; // we can't know immediately if they enabled it, they have to come back
    }

    final req = await Permission.notification.request();
    
    if (req.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return req.isGranted;
  } catch (e) {
    return false;
  }
}
