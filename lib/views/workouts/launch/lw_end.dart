import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/root.dart';

class LWEnd extends StatefulWidget {
  const LWEnd({super.key});

  @override
  State<LWEnd> createState() => _LWEndState();
}

class _LWEndState extends State<LWEnd> {
  @override
  Widget build(BuildContext context) {
    var lmodel = Provider.of<LaunchWorkoutModel>(context);
    return SingleChildScrollView(
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: Column(
        children: [
          const SizedBox(height: 8),
          FilledButton(
              onPressed: () {
                cupertinoSheet(
                  context: context,
                  builder: (context) => SelectExercise(
                    title: "Add Another",
                    onSelect: (exercise) {
                      lmodel.addExercise(
                          exercise, lmodel.state.exercises.length);
                    },
                  ),
                );
              },
              child: Text("Add Exercise")),
        ],
      ),
    );
  }
}
