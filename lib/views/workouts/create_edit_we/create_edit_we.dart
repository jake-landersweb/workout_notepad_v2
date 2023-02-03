import 'package:flutter/material.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/root.dart';

class CreateEditWorkoutExercise extends StatefulWidget {
  const CreateEditWorkoutExercise({
    super.key,
    required this.exercise,
    required this.onAction,
  });
  final Exercise exercise;
  final Function(Exercise) onAction;

  @override
  State<CreateEditWorkoutExercise> createState() =>
      _CreateEditWorkoutExerciseState();
}

class _CreateEditWorkoutExerciseState extends State<CreateEditWorkoutExercise> {
  late Exercise _exercise;

  @override
  void initState() {
    _exercise = widget.exercise.copy();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return sui.AppBar.sheet(
      title: "Edit Exericse",
      leading: const [comp.CloseButton()],
      children: [],
    );
  }
}
