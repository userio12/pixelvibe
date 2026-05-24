import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermission() async {
  if (await Permission.storage.isGranted) return true;
  if (await Permission.videos.isGranted) return true;

  if (await Permission.videos.request().isGranted) return true;
  if (await Permission.storage.request().isGranted) return true;

  return false;
}

Future<bool> requestNotificationPermission() async {
  final status = await Permission.notification.status;
  if (status.isGranted) return true;
  return await Permission.notification.request().isGranted;
}
