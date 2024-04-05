import 'package:flutter/material.dart';

Color calculateTextColor(Color background) {
  return background.computeLuminance() >= 0.5 ? Colors.black : Colors.white;
}
