import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workouts/create_edit_we/root.dart';
import 'package:workout_notepad_v2/views/workouts/we_cell.dart';

class WorkoutDetail extends StatefulWidget {
  const WorkoutDetail({
    super.key,
    required this.workout,
  });
  final Workout workout;

  @override
  State<WorkoutDetail> createState() => _WorkoutDetailState();
}

class _WorkoutDetailState extends State<WorkoutDetail> {
  late Workout _workout;
  List<Exercise> _exercises = [];

  @override
  void initState() {
    _workout = widget.workout.copy();
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
        leading: const [comp.BackButton()],
        trailing: [
          comp.EditButton(
            onTap: () {
              comp.cupertinoSheet(
                context: context,
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
          const SizedBox(height: 16),
          sui.ListView<Exercise>(
            children: _exercises,
            leadingPadding: 0,
            trailingPadding: 0,
            childBuilder: (context, item) {
              return WECell(workout: _workout, exercise: item);
            },
          ),
        ],
      ),
    );
  }
}
