import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

Color calculateTextColor(Color background) {
  return background.computeLuminance() >= 0.5 ? Colors.black : Colors.white;
}

Future<void> shareSong(
  BuildContext context,
  String songPath,
  String songName,
) async {
  List<XFile> files = [];
  // convert song to xfile
  final songFile = XFile(songPath);
  files.add(songFile);
  ShareParams shareParams = ShareParams(files: files, text: songName);
  await SharePlus.instance.share(shareParams);
  if (context.mounted) {
    Navigator.of(context).pop();
  }
}

Future<int> getAndroidVersion() async {
  if (Platform.isAndroid) {
    final androidInfo = await getAndroidInfo();
    return androidInfo.version.sdkInt;
  }
  return 0;
}

Future<AndroidDeviceInfo> getAndroidInfo() async {
  final deviceInfo = DeviceInfoPlugin();
  return await deviceInfo.androidInfo;
}
