import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:planer/backend/preference_manager.dart';
import 'helper.dart';

enum StructureTaskActive { always, workdays, holidays }

// 0 For Structure, 1 for repeating, 2 otherwise default
final List<Color> tohColors = [];
void initColors() {
  tohColors.add(Color(myPreferences.getInt('structureTaskColor') ?? 0xFFFFFFFF));
  tohColors.add(Color(myPreferences.getInt('repeatingTaskColor') ?? 0xFFFFFFFF));
  tohColors.add(Color(myPreferences.getInt('defaultTaskColor') ?? 0xFFFFFFFF));
  tohColors.addAll([for (String s in myPreferences.getStringList('taskColorIds') ?? []) Color(int.parse(s))]);
}

class Periodicity {
  List<Duration> baseOffsets;
  List<Duration> rhythms;
  DateTime baseDate;
  DateTime endDate;
  Periodicity(this.baseDate, this.rhythms, this.baseOffsets, this.endDate);
}

class TDConstraint {
  bool external;
  List<ToH>? requiredTasks;
  TDConstraint({required this.external, this.requiredTasks});
}

// Any Task or Header:
//  Name, Notes, timerduration?, subtasks?, listname, Date?, index, is_done, icon, color, isHighlighted, deadline?,
//  is_repeating, constraints?
class ToH {
  final Key uid = generateUid();
  String name;
  String notes;
  Duration? timeLimit;
  List<ToH>? children;
  String listName;
  DateTime? listDate;
  int index;
  bool isDone;
  Icon icon;
  int colorIndex;
  bool isHighlighted;
  bool isSelected;
  DateTime? deadline;
  bool isRepeating;
  List<TDConstraint>? constraints;

  ToH(
      {required this.name,
      required this.notes,
      this.timeLimit,
      this.children,
      required this.listName,
      this.listDate,
      required this.index,
      required this.isDone,
      required this.icon,
      required this.colorIndex,
      required this.isHighlighted,
      required this.isSelected,
      this.deadline,
      required this.isRepeating,
      this.constraints});

  bool deadlineOverdue() {
    if (listDate == null || deadline == null) return false;
    if (listDate!.isAfter(DateTime(deadline!.year, deadline!.month, deadline!.day))) return false;
    return true;
  }
}

// Structure (Not for task list, only backend and structure maniplator):
//  Whenactive
class StructureToH extends ToH {
  StructureTaskActive whenActive;

  StructureToH(
      {required super.name,
      required super.notes,
      super.timeLimit,
      super.children,
      required super.listName,
      super.listDate,
      required super.index,
      required super.isDone,
      required super.icon,
      required super.colorIndex,
      required super.isHighlighted,
      required super.isSelected,
      super.deadline,
      required super.isRepeating,
      super.constraints,
      required this.whenActive});
}

// Repeating (Not for task list, only backend and periodicity maniplator):
//  Periodicity(Rhythm, Base_Date)
class PeriodicToH extends ToH {
  Periodicity periodicity;

  PeriodicToH(
      {required super.name,
      required super.notes,
      super.timeLimit,
      super.children,
      required super.listName,
      super.listDate,
      required super.index,
      required super.isDone,
      required super.icon,
      required super.colorIndex,
      required super.isHighlighted,
      required super.isSelected,
      super.deadline,
      required super.isRepeating,
      super.constraints,
      required this.periodicity});
}

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
    final Color tohColor = tohColors[widget.toh.colorIndex];
    final Color _tileColor = widget.toh.constraints?.isNotEmpty ?? false ? greyedColor(tohColor) : tohColor;
    final Color _rawBoundaryColor = widget.toh.isSelected ? invert(tohColor) : tohColor;
    final Color _boundaryColor =
        widget.toh.constraints?.isNotEmpty ?? false ? greyedColor(_rawBoundaryColor) : _rawBoundaryColor;

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
          leading: ReorderableDragStartListener(index: widget.toh.index, child: widget.toh.deadlineOverdue()
              ? const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber,
                )
              : const Icon(
                  Icons.schedule,
                  color: Colors.lightGreen,
                ),
          ),
          title: Text(widget.toh.name),
          trailing: Row(
            children: [
              if (widget.toh.timeLimit != null)
                IconButton(onPressed: () => widget.startTimer(widget.toh.timeLimit!), icon: widget.toh.icon),
              if ((widget.toh.constraints ?? []).isNotEmpty)
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

class EditModeTileToH extends StatelessWidget {
  final ToH toh;
  const EditModeTileToH({Key? key, required this.toh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: ReorderableDragStartListener(index: toh.index, child: Text(toh.name)),
      trailing: Row(
        children: [ReorderableDragStartListener(index: toh.index, child: toh.icon)],
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }
}

void addTask() {}
void markTaskDone() {}
List<ToH> getTasks(DateTime day) {
  return <ToH>[];
}

List<dynamic> getAllTasks() {
  return <ToH>[];
}

ListView renderToH(bool Function(ToH) whereF) {
  return ListView();
}

bool onList(List<ToH> tasks, String listName) {
  return true;
}
