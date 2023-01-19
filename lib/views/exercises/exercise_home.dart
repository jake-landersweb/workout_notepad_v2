import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

class ExerciseHome extends StatefulWidget {
  const ExerciseHome({super.key});

  @override
  State<ExerciseHome> createState() => _ExerciseHomeState();
}

class _ExerciseHomeState extends State<ExerciseHome> {
  @override
  Widget build(BuildContext context) {
    return sui.AppBar(
      title: "Exercises",
      isLarge: true,
      children: [
        _body(context),
      ],
    );
  }

  Widget _body(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return Column(
      children: [
        for (var i in dmodel.exercises)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ExerciseCell(exercise: i),
          ),
        const SizedBox(height: 50),
      ],
    );
  }
}
