import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/data/exercise.dart';
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
    return sui.AppBar(
      title: "Exercises",
      isLarge: true,
      isFluid: true,
      itemSpacing: 8,
      trailing: [
        comp.AddButton(onTap: () {
          sui.showCupertinoSheet(
            context: context,
            builder: (context) => const CEERoot(isCreate: true),
          );
        })
      ],
      children: [
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
        for (var i in filteredExercises(dmodel.exercises, _searchText))
          ExerciseCell(
            exercise: i,
            onTap: () {
              sui.showFloatingSheet(
                context: context,
                builder: (context) => sui.FloatingSheet(
                  title: i.title,
                  child: ExerciseDetail(exercise: i),
                ),
              );
            },
          ),
        const SizedBox(height: 50),
      ],
    );
  }
}
