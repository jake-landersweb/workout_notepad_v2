import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/root.dart';
import 'package:workout_notepad_v2/views/workouts/we_cell.dart';

class WorkoutDetail extends StatefulWidget {
  const WorkoutDetail({
    super.key,
    required this.workout,
  });
  final WorkoutCategories workout;

  @override
  State<WorkoutDetail> createState() => _WorkoutDetailState();
}

class _WorkoutDetailState extends State<WorkoutDetail> {
  late Workout _workout;
  List<WorkoutExercise> _exercises = [];

  @override
  void initState() {
    _workout = widget.workout.workout.copy();
    _init();
    super.initState();
  }

  Future<void> _init() async {
    var tmp = await _workout.getChildren();
    setState(() {
      _exercises = [];
      _exercises = tmp;
    });
  }

  Future<void> _postUpdate(Workout w) async {
    setState(() {
      _workout = w;
      _exercises = [];
    });
    // wait for db to load
    await Future.delayed(const Duration(milliseconds: 100));
    var tmp = await w.getChildren();
    setState(() {
      _exercises = tmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: sui.AppBar(
        title: _workout.title,
        isLarge: true,
        isFluid: true,
        itemSpacing: 8,
        leading: const [comp.BackButton()],
        trailing: [
          comp.EditButton(
            onTap: () {
              showMaterialModalBottomSheet(
                context: context,
                enableDrag: false,
                builder: (context) => CEWRoot(
                  isCreate: false,
                  workout: _workout,
                  onAction: (workout) async => _postUpdate(workout),
                ),
              );
            },
          )
        ],
        children: [
          if ((_workout.description ?? "") != "")
            Text(_workout.description!, style: ttLabel(context)),
          _actions(context),
          comp.LabeledWidget(
            label: "Exercises",
            child: Container(),
          ),
          for (var item in _exercises)
            sui.CellWrapper(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: WECell(workout: _workout, exercise: item),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: sui.Button(
            onTap: () {
              comp.cupertinoSheet(
                context: context,
                builder: (context) =>
                    LaunchWorkout(workout: _workout, exercises: _exercises),
              );
            },
            child: sui.CellWrapper(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_arrow_rounded,
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text("Launch Workout", style: ttLabel(context))
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
