import 'dart:math';

import 'package:flutter/material.dart';

Color invert(Color color) {
  final int r = 255 - color.red;
  final int g = 255 - color.green;
  final int b = 255 - color.blue;

  return Color.fromARGB((color.opacity * 255).round(), r, g, b);
}

Color greyedColor(Color color){
  HSLColor hsl = HSLColor.fromColor(color);
  return HSLColor.fromAHSL(hsl.alpha, hsl.hue, 0.3, 0.6).toColor();
}

final Random random = Random();

String generateUid(){
  return "${DateTime.now().microsecondsSinceEpoch}${random.nextInt(1<<32)}";
}
