import 'package:flutter/material.dart';

class DebugContainer extends StatelessWidget {
  final Widget child;
  const DebugContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(0xFFFF0000),
          width: 3
        ),
      ),
      child: child,
    );
  }
}
