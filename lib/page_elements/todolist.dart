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
    return ReorderableListView(onReorder: (int oldIndex, int newIndex) {  },
    children: [],

    );
  }
}

class Pool extends StatefulWidget {
  const Pool({Key? key}) : super(key: key);

  @override
  State<Pool> createState() => _PoolState();
}

class _PoolState extends State<Pool> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView(onReorder: (int oldIndex, int newIndex) {  },
      children: [],

    );
  }
}
