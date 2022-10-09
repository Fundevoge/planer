import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Serialization/iconDataSerialization.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final SharedPreferences myPreferences;

Future<void> initPreferences() async {
  myPreferences = await SharedPreferences.getInstance();
}

Icon _safeGetNavBarIcon(int index, List<Icon> _icons){
  if(index > _icons.length) return const Icon(Icons.group);
  return _icons[index];
}

String _safeGetNavBarTitle(int index, List<String> _titles){
  if(index > _titles.length) return "Shared $index";
  return _titles[index];
}


List<BottomNavigationBarItem> getNavBarPrefs(){
  List<String> listNames = myPreferences.getStringList('navBarNames') ?? <String>[];
  List<Icon> listIcons = (myPreferences.getStringList('navBarIconData') ?? <String>[])
      .map((e) => Icon(deserializeIcon(jsonDecode(e))))
      .toList();
  List<BottomNavigationBarItem> navBarPrefs = <BottomNavigationBarItem>[];
  for(int i = 0; i < max(listNames.length, listIcons.length); i++){
    navBarPrefs.add(BottomNavigationBarItem(
        icon: _safeGetNavBarIcon(i, listIcons),
        label: _safeGetNavBarTitle(i, listNames)));
  }
  return navBarPrefs;
}
