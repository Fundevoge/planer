
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/Serialization/iconDataSerialization.dart';
import 'package:planer/backend/preference_manager.dart';
import 'helper.dart';

enum StructureTaskActive { always, workdays, holidays }

// 0 For Structure, 1 for repeating, 2 otherwise default
late Color structureTaskColor;
late Color repeatingTaskColor;
late Color defaultTaskColor;
void initColors() {
  structureTaskColor = Color(myPreferences.getInt('structureTaskColor') ?? 0xFFFFFFFF);
  repeatingTaskColor = Color(myPreferences.getInt('repeatingTaskColor') ?? 0xFFFFFFFF);
  defaultTaskColor = Color(myPreferences.getInt('defaultTaskColor') ?? 0xFFFFFFFF);
}

late Icon defaultIcon;

void initIcon() {
  defaultIcon = Icon(IconData(myPreferences.getInt('defaultIcon') ?? const Icon(Icons.developer_mode).icon!.codePoint));
}

class Periodicity {
  List<Duration> baseOffsets;
  List<Duration> rhythms;
  DateTime baseDate;
  DateTime endDate;
  Periodicity(this.baseDate, this.rhythms, this.baseOffsets, this.endDate);
  Map<String, dynamic> toJson() {
    return {
      "baseDate": baseDate.toIso8601String(),
      "endDate": endDate.toIso8601String(),
      "rhythms": [for (Duration r in rhythms) r.inSeconds],
      "baseOffsets": [for (Duration b in baseOffsets) b.inSeconds]
    };
  }

  Periodicity.fromJson(Map<String, dynamic> json)
      : baseDate = DateTime.parse(json["baseDate"]),
        endDate = DateTime.parse(json["endDate"]),
        rhythms = [for (String s in json["rhythms"]) Duration(seconds: int.parse(s))],
        baseOffsets = [for (String s in json["baseOffsets"]) Duration(seconds: int.parse(s))];
}

class TDConstraint {
  bool external;
  List<ToH>? requiredTasks;
  TDConstraint({required this.external, this.requiredTasks});
  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>>? jsonChildren =
        (requiredTasks?.isNotEmpty ?? false) ? List.from([for (ToH child in requiredTasks!) child.toJson()]) : null;
    return {"external": external, "requiredTasks": jsonChildren};
  }

  TDConstraint.fromJson(Map<String, dynamic> json)
      : external = json["external"],
        requiredTasks = json["requiredTasks"] != null
            ? [for (Map<String, dynamic> jsonChild in json["requiredTasks"]) ToH.fromJson(jsonChild)]
            : null;
}

// Any Task or Header:
//  Name, Notes, timerduration?, subtasks?, listname, Date?, index, is_done, icon, color, isHighlighted, deadline?,
//  is_repeating, constraints?
class ToH {
  final Key uid;
  String name;
  String notes;
  Duration? timeLimit;
  List<ToH>? children;
  String listName;
  DateTime? listDate;
  int index;
  bool isDone;
  Icon icon;
  Color taskColor;
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
      this.isDone = false,
      required this.icon,
      required this.taskColor,
      this.isHighlighted = false,
      this.isSelected = false,
      this.deadline,
      this.isRepeating = false,
      this.constraints})
      : uid = generateUid();

  factory ToH.debugFactory(int index) {
    return ToH(
      name: "Debug Task $index",
      notes: "Debug Notes",
      listName: "Debug List",
      index: index,
      icon: const Icon(Icons.developer_mode),
      taskColor: defaultTaskColor,
    );
  }

  bool deadlineOverdue() {
    if (listDate == null || deadline == null) return false;
    if (listDate!.isAfter(DateTime(deadline!.year, deadline!.month, deadline!.day))) return false;
    return true;
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>>? jsonChildren =
        (children?.isNotEmpty ?? false) ? List.from([for (ToH child in children!) child.toJson()]) : null;
    final List<Map<String, dynamic>>? jsonConstraints = (constraints?.isNotEmpty ?? false)
        ? List.from([for (TDConstraint child in constraints!) child.toJson()])
        : null;
    return {
      "uid": uid.toString(),
      "name": name,
      "notes": notes,
      "timeLimit": timeLimit?.inSeconds,
      "children": jsonChildren,
      "listName": listName,
      "listDate": listDate?.toIso8601String(),
      "index": index,
      "isDone": isDone,
      "icon": serializeIcon(icon.icon!),
      "taskColor": taskColor.value,
      "isHighlighted": isHighlighted,
      "isSelected": isSelected,
      "deadline": deadline?.toIso8601String(),
      "isRepeating": isRepeating,
      "constraints": jsonConstraints
    };
  }

  ToH.fromJson(Map<String, dynamic> json)
      : uid = Key(json['uid']),
        name = json["name"],
        notes = json["notes"],
        timeLimit = json["timeLimit"],
        children = json["children"] != null
            ? [for (Map<String, dynamic> jsonChild in json["children"]) ToH.fromJson(jsonChild)]
            : null,
        listName = json["listName"],
        listDate = json["listDate"] != null ? DateTime.parse(json["listDate"]) : null,
        index = json["index"],
        isDone = json["isDone"],
        icon = Icon(deserializeIcon(json["icon"])!),
        taskColor = Color(json["taskColor"]),
        isHighlighted = json["isHighlighted"],
        isSelected = json["isSelected"],
        deadline = json["deadline"] != null ? DateTime.parse(json["deadline"]) : null,
        isRepeating = json["isRepeating"],
        constraints = json["constraints"] != null
            ? [for (Map<String, dynamic> jsonConstraint in json["constraint"]) TDConstraint.fromJson(jsonConstraint)]
            : null;
}

// Structure (Not for task list, only backend and structure maniplator):
//  Whenactive
class StructureToH {
  StructureTaskActive whenActive;
  final ToH toh;

  StructureToH({required this.toh, required this.whenActive});
  Map<String, dynamic> toJson() {
    return {"whenActive": whenActive.index, "toh": toh.toJson()};
  }

  StructureToH.fromJson(Map<String, dynamic> json)
      : whenActive = StructureTaskActive.values.elementAt(json["whenActive"]),
        toh = ToH.fromJson(json["toh"]);
}

// Repeating (Not for task list, only backend and periodicity maniplator):
//  Periodicity(Rhythm, Base_Date)
class PeriodicToH {
  Periodicity periodicity;
  final ToH toh;

  PeriodicToH({required this.toh, required this.periodicity});
  Map<String, dynamic> toJson() {
    return {"periodicity": periodicity.toJson(), "toh": toh.toJson()};
  }

  PeriodicToH.fromJson(Map<String, dynamic> json)
      : periodicity = Periodicity.fromJson(json["periodicity"]),
        toh = ToH.fromJson(json["toh"]);
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

void addTask() {}
void markTaskDone() {}
