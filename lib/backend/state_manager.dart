import 'package:flutter/material.dart';

class Rebuilder extends ChangeNotifier {
  void rebuild(){
    notifyListeners();
  }
}