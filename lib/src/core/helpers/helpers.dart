import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

Color calculateTextColor(Color background) {
  return background.computeLuminance() >= 0.5 ? Colors.black : Colors.white;
}

Future<void> shareSong(
    BuildContext context, String songPath, String songName) async {
  List<XFile> files = [];
  // convert song to xfile
  final songFile = XFile(songPath);
  files.add(songFile);
  await Share.shareXFiles(
    files,
    text: songName,
  );
  if (context.mounted) {
    Navigator.of(context).pop();
  }
}
