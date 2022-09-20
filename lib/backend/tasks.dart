import 'package:flutter/material.dart';

void addTask(){}
void markTaskDone(){}
void markHeaderDone(){}
List<dynamic> getTasks(DateTime day){return <dynamic>[];}
List<dynamic> getAllTasks(){return <dynamic>[];}
ListView buildTasksHeaders(bool Function(dynamic) whereF){return ListView();}

bool onList(dynamic tasks, String listName) {return true;}

class Task{
  late final String name;
}
