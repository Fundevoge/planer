import 'package:flutter/material.dart';

class TodoList extends StatefulWidget {
  const TodoList({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  @override
  Widget build(BuildContext context) {
    return ListView(

    );
  }
}
