import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';

import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;

class ExerciseHome extends StatefulWidget {
  const ExerciseHome({super.key});

  @override
  State<ExerciseHome> createState() => _ExerciseHomeState();
}

class _ExerciseHomeState extends State<ExerciseHome> {
  String _searchText = "";
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return HeaderBar(
      title: "Exercises",
      isLarge: true,
      trailing: [
        comp.AddButton(onTap: () {
          comp.cupertinoSheet(
            context: context,
            builder: (context) => const CEERoot(isCreate: true),
          );
        })
      ],
      children: [
        const SizedBox(height: 16),
        comp.SearchBar(
          onChanged: (val) {
            setState(() {
              _searchText = val.toLowerCase();
            });
          },
          initText: _searchText,
          labelText: "Search",
          hintText: "Search by title or category",
        ),
        const SizedBox(height: 16),
        for (var i in filteredExercises(dmodel.exercises, _searchText))
          ExerciseCell(
            exercise: i,
            padding: const EdgeInsets.only(bottom: 8),
            onTap: () {
              comp.cupertinoSheet(
                context: context,
                builder: (context) => ExerciseDetail(exercise: i),
              );
            },
          ),
        SizedBox(height: dmodel.workoutState == null ? 50 : 80),
      ],
    );
  }
}
