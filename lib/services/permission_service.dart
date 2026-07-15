import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  const PermissionService._();

  static Future<PermissionStatus> getLocationStatus() {
    return Permission.locationWhenInUse.status;
  }

  static Future<PermissionStatus> getNotificationStatus() {
    return Permission.notification.status;
  }

  static Future<PermissionStatus> requestLocationPermission() {
    return Permission.locationWhenInUse.request();
  }

  static Future<PermissionStatus> requestNotificationPermission() {
    return Permission.notification.request();
  }

  static Future<bool> isLocationGranted() async {
    final status = await getLocationStatus();
    return status == PermissionStatus.granted;
  }

  static Future<bool> isNotificationGranted() async {
    final status = await getNotificationStatus();
    return status == PermissionStatus.granted;
  }

  static Future<void> openAppPermissionSettings() {
    return openAppSettings();
  }
}