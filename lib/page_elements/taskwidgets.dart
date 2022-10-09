import 'package:flutter/cupertino.dart';
import 'package:planer/backend/helper.dart';
import 'package:planer/models/tasks.dart';
import 'package:flutter/material.dart';

class TileToH extends StatefulWidget {
  final ToH toh;
  final void Function(int) moveToDone;
  final void Function() enterSelectionMode;
  final void Function(List<TDConstraint>?) showConstraints;
  final void Function(Duration) startTimer;
  final void Function(ToH) onTapCallback;

  const TileToH(
      {Key? key,
        required this.toh,
        required this.moveToDone,
        required this.enterSelectionMode,
        required this.showConstraints,
        required this.startTimer,
        required this.onTapCallback})
      : super(key: key);

  @override
  State<TileToH> createState() => _TileToHState();
}

class _TileToHState extends State<TileToH> {
  @override
  Widget build(BuildContext context) {
    final bool hasConstraints = widget.toh.constraints?.isNotEmpty ?? false;
    final Color tohColor = widget.toh.taskColor;
    final Color _tileColor = hasConstraints ? greyedColor(tohColor) : tohColor;
    final Color _rawBoundaryColor = widget.toh.isSelected ? invert(tohColor) : tohColor;
    final Color _boundaryColor = hasConstraints ? greyedColor(_rawBoundaryColor) : _rawBoundaryColor;
    final Color _textColor = hasConstraints ? const Color(0xff484848) : Colors.black;

    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: <Widget>[
        ListTile(
          tileColor: _tileColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: _boundaryColor,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          onTap: () => widget.onTapCallback(widget.toh),
          onLongPress: () {
            setState(() {
              widget.toh.isSelected = true;
            });
            widget.enterSelectionMode();
          },
          title: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ReorderableDragStartListener(
                index: widget.toh.index,
                child: widget.toh.deadlineOverdue()
                    ? const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber,
                )
                    : const Icon(
                  Icons.schedule,
                  color: Colors.lightGreen,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                widget.toh.name,
                style: taskTextStyle.copyWith(color: _textColor),
              ),
              Expanded(child: Container()),
              Row(
                children: [
                  if (widget.toh.timeLimit != null)
                    IconButton(
                        onPressed: () => widget.startTimer(widget.toh.timeLimit!), icon: const Icon(Icons.alarm)),
                  if (hasConstraints)
                    IconButton(
                      icon: const Icon(CupertinoIcons.exclamationmark),
                      onPressed: () => widget.showConstraints(widget.toh.constraints),
                    ),
                  ReorderableDragStartListener(index: widget.toh.index, child: widget.toh.icon),
                  Checkbox(
                      value: widget.toh.isDone,
                      onChanged: (val) {
                        setState(() {
                          widget.toh.isDone = val!;
                        });
                        widget.moveToDone(widget.toh.index);
                      }),
                ],
                mainAxisSize: MainAxisSize.min,
              ),
            ],
          ),
        ),
        if (widget.toh.isHighlighted)
          Stack(
            alignment: AlignmentDirectional.center,
            children: const [
              Icon(
                Icons.star,
                color: Colors.black,
                size: 24,
              ),
              Icon(
                Icons.star,
                color: Colors.amberAccent,
                size: 22,
              )
            ],
          )
      ],
    );
  }
}

class EditModeTileToH extends StatefulWidget {
  final ToH toh;
  final void Function() enterSelectionMode;
  final void Function(List<TDConstraint>?) showConstraints;
  final void Function(ToH) onTapCallback;

  const EditModeTileToH(
      {Key? key,
        required this.toh,
        required this.enterSelectionMode,
        required this.showConstraints,
        required this.onTapCallback})
      : super(key: key);

  @override
  State<EditModeTileToH> createState() => _EditModeTileToHState();
}

class _EditModeTileToHState extends State<EditModeTileToH> {
  @override
  Widget build(BuildContext context) {
    final bool hasConstraints = widget.toh.constraints?.isNotEmpty ?? false;
    final Color tohColor = widget.toh.taskColor;
    final Color _tileColor = hasConstraints ? greyedColor(tohColor) : tohColor;
    final Color _rawBoundaryColor = widget.toh.isSelected ? invert(tohColor) : tohColor;
    final Color _boundaryColor = hasConstraints ? greyedColor(_rawBoundaryColor) : _rawBoundaryColor;
    final Color _textColor = hasConstraints ? const Color(0xff484848) : Colors.black;

    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: <Widget>[
        ListTile(
          tileColor: _tileColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: _boundaryColor,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          onTap: () => widget.onTapCallback(widget.toh),
          onLongPress: () {
            setState(() {
              widget.toh.isSelected = true;
            });
            widget.enterSelectionMode();
          },
          title: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.toh.name,
                style: taskTextStyle.copyWith(color: _textColor),
              ),
              Expanded(child: Container()),
              Row(
                children: [
                  if (widget.toh.timeLimit != null) const Icon(Icons.alarm),
                  if (hasConstraints)
                    IconButton(
                      icon: const Icon(CupertinoIcons.exclamationmark),
                      onPressed: () => widget.showConstraints(widget.toh.constraints),
                    ),
                  ReorderableDragStartListener(index: widget.toh.index, child: widget.toh.icon),
                ],
                mainAxisSize: MainAxisSize.min,
              ),
            ],
          ),
        ),
        if (widget.toh.isHighlighted)
          Stack(
            alignment: AlignmentDirectional.center,
            children: const [
              Icon(
                Icons.star,
                color: Colors.black,
                size: 24,
              ),
              Icon(
                Icons.star,
                color: Colors.amberAccent,
                size: 22,
              )
            ],
          )
      ],
    );
  }
}

class ReadOnlyTileToH extends StatefulWidget {
  final ToH toh;
  final void Function() enterSelectionMode;
  final void Function(List<TDConstraint>?) showConstraints;
  final void Function(ToH) onTapCallback;
  const ReadOnlyTileToH(
      {Key? key,
        required this.toh,
        required this.enterSelectionMode,
        required this.showConstraints,
        required this.onTapCallback})
      : super(key: key);

  @override
  State<ReadOnlyTileToH> createState() => _ReadOnlyTileToHState();
}

class _ReadOnlyTileToHState extends State<ReadOnlyTileToH> {
  @override
  Widget build(BuildContext context) {
    final bool hasConstraints = widget.toh.constraints?.isNotEmpty ?? false;
    const Color tohColor = Color(0xFF999999);
    const Color constrainedToHColor = Color(0xFFCCCCCC);
    const Color selectedBoundaryColor = Color(0xFF444499);
    const Color selectedConstrainedBoundaryColor = Color(0xFF7A7AB8);

    final Color _tileColor = hasConstraints ? constrainedToHColor : tohColor;
    final Color _boundaryColor = hasConstraints
        ? (widget.toh.isSelected ? selectedConstrainedBoundaryColor : constrainedToHColor)
        : (widget.toh.isSelected ? selectedBoundaryColor : tohColor);
    final Color _textColor = hasConstraints ? const Color(0xff484848) : Colors.black;

    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: <Widget>[
        ListTile(
          tileColor: _tileColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: _boundaryColor,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          onTap: () => widget.onTapCallback(widget.toh),
          onLongPress: () {
            setState(() {
              widget.toh.isSelected = true;
            });
            widget.enterSelectionMode();
          },
          title: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ReorderableDragStartListener(
                index: widget.toh.index,
                child: widget.toh.deadlineOverdue()
                    ? const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFB8A87A),
                )
                    : const Icon(
                  Icons.schedule,
                  color: Color(0xFF9BB87A),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                widget.toh.name,
                style: taskTextStyle.copyWith(color: _textColor),
              ),
              Expanded(child: Container()),
              Row(
                children: [
                  if (widget.toh.timeLimit != null)
                    const Icon(Icons.alarm),
                  if (hasConstraints)
                    IconButton(
                      icon: const Icon(CupertinoIcons.exclamationmark),
                      onPressed: () => widget.showConstraints(widget.toh.constraints),
                    ),
                  ReorderableDragStartListener(index: widget.toh.index, child: widget.toh.icon),
                  Checkbox(
                    checkColor: const Color(0xFFD6D6FF),
                    value: widget.toh.isDone,
                    onChanged: null,
                  ),
                ],
                mainAxisSize: MainAxisSize.min,
              ),
            ],
          ),
        ),
        if (widget.toh.isHighlighted)
          Stack(
            alignment: AlignmentDirectional.center,
            children: const [
              Icon(
                Icons.star,
                color: Color(0xFF444444),
                size: 24,
              ),
              Icon(
                Icons.star,
                color: Color(0xFFB8AB7A),
                size: 22,
              )
            ],
          )
      ],
    );
  }
}

class TaskEditor extends StatefulWidget {
  final ToH toh;
  final void Function(ToH) updateToH;

  const TaskEditor({Key? key, required this.toh, required this.updateToH}) : super(key: key);

  @override
  State<TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends State<TaskEditor> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    _nameController.text = widget.toh.name;
    _noteController.text = widget.toh.notes;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
            ),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(hintText: 'Notizen'),
            ),
          ],
        ));
  }
}