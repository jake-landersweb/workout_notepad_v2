import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/views/exercises/cee/root.dart';
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
            builder: (context) => CEERoot(
              isCreate: true,
              onCreate: () => dmodel.refreshExercises(),
            ),
          );
        })
      ],
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: sui.CellWrapper(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(LineIcons.search, color: Theme.of(context).primaryColor),
                const SizedBox(width: 16),
                Expanded(
                  child: sui.TextField(
                    labelText: "Search",
                    hintText: "Search by title or category",
                    value: _searchText,
                    onChanged: (val) => setState(() {
                      _searchText = val.toLowerCase();
                    }),
                  ),
                )
              ],
            ),
          ),
        ),
        for (var i in _exercises(context, dmodel)) ExerciseCell(exercise: i),
        const SizedBox(height: 50),
      ],
    );
  }

  List<Exercise> _exercises(BuildContext context, DataModel dmodel) {
    if (_searchText.isEmpty) {
      return dmodel.exercises;
    }
    return dmodel.exercises
        .where((element) =>
            element.title.toLowerCase().contains(_searchText) ||
            element.category.contains(_searchText))
        .toList();
  }
}
