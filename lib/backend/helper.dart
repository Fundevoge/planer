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

Key generateUid(){
  return Key("${DateTime.now().microsecondsSinceEpoch}${random.nextInt(1<<32)}");
}

const TextStyle taskTextStyle = TextStyle(fontSize: 24, overflow: TextOverflow.ellipsis);
ThemeData appTheme = ThemeData();


// 48/x from x = 2 to x = 11
const List<double> harmonicFirstTen = <double>[24, 16, 12, 9.6, 8, 48/7, 6, 16/3, 4.8, 48/11];
double harmonicSize(int depth){
  return harmonicFirstTen.take(depth).reduce((value, element) => value + element);
}

int randomColorCode(){
  return  0xFF000000 + random.nextInt(0xFFFFFF+1);
}
