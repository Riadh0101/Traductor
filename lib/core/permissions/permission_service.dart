import 'package:permission_handler/permission_handler.dart' as ph;

abstract class PermissionService {
  Future<bool> hasMicrophonePermission();
  Future<ph.PermissionStatus> requestMicrophonePermission();
  Future<bool> openAppSettings();
}

class PermissionServiceImpl implements PermissionService {
  @override
  Future<bool> hasMicrophonePermission() async {
    final status = await ph.Permission.microphone.status;
    return status.isGranted;
  }

  @override
  Future<ph.PermissionStatus> requestMicrophonePermission() async {
    return await ph.Permission.microphone.request();
  }

  @override
  Future<bool> openAppSettings() async {
    return await ph.openAppSettings();
  }
}
