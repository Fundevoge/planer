import 'package:flutter_iconpicker/Serialization/iconDataSerialization.dart';
import 'package:planer/backend/helper.dart';
import 'package:planer/models/tasks.dart';
import 'package:flutter/material.dart';

class TodoList{
  final Key uid;
  final List<ToH> tohs;
  Color listColor;
  Icon listIcon;
  String listName;

  TodoList(this.tohs, this.listColor, this.listIcon, this.listName) : uid = generateUid();

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> jsonToHs = List.from([for (ToH child in tohs) child.toJson()]);
    return {
      "uid": uid.toString(),
      "tohs": jsonToHs,
      "listColor": listColor.value,
      "listName": listName,
      "listIcon": serializeIcon(listIcon.icon!),
    };
  }

  TodoList.fromJson(Map<String, dynamic> json)
      : uid = Key(json['uid']),
        listName = json["listName"],
        listColor = Color(json["listColor"]),
        listIcon =  Icon(deserializeIcon(json["listIcon"])),
        tohs = [for(Map<String, dynamic> serializedToH in json["tohs"]) ToH.fromJson(serializedToH)];

}

class TodoPool{
  final Key uid;
  final List<ToH> tohs;
  Color listColor;
  Icon listIcon;
  String listName;

  TodoPool(this.tohs, this.listColor, this.listIcon, this.listName) : uid = generateUid();

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> jsonToHs = List.from([for (ToH child in tohs) child.toJson()]);
    return {
      "uid": uid.toString(),
      "tohs": jsonToHs,
      "listColor": listColor.value,
      "listName": listName,
      "listIcon": serializeIcon(listIcon.icon!),
    };
  }

  TodoPool.fromJson(Map<String, dynamic> json)
      : uid = Key(json['uid']),
        listName = json["listName"],
        listColor = Color(json["listColor"]),
        listIcon =  Icon(deserializeIcon(json["listIcon"])),
        tohs = [for(Map<String, dynamic> serializedToH in json["tohs"]) ToH.fromJson(serializedToH)];
}
