import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/components/root.dart' as comp;
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
  List<String> _categories = [];
  List<Exercise> _exercises = [];

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    _categories = await widget.workout.getCategories();
    _exercises = await widget.workout.getChildren();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: sui.AppBar(
        title: widget.workout.title,
        isLarge: true,
        leading: const [comp.BackButton()],
        children: [
          for (var i in _exercises)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: WECell(exercise: i),
            ),
        ],
      ),
    );
  }
}
