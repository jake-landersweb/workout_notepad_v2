import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/data/workout_cat.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workouts/workout_cell.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/components/root.dart' as comp;

class WorkoutsHome extends StatefulWidget {
  const WorkoutsHome({super.key});

  @override
  State<WorkoutsHome> createState() => _WorkoutsHomeState();
}

class _WorkoutsHomeState extends State<WorkoutsHome> {
  String _searchText = "";
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return sui.AppBar(
      title: "Workouts",
      isFluid: true,
      itemSpacing: 8,
      isLarge: true,
      trailing: [
        comp.AddButton(
          onTap: () {
            sui.showCupertinoSheet(
              context: context,
              builder: (context) => CEWRoot(
                isCreate: true,
                onCreate: () {},
              ),
            );
          },
        )
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
        for (var i in _workouts(context, dmodel)) WorkoutCell(wc: i),
      ],
    );
  }

  List<WorkoutCategories> _workouts(BuildContext context, DataModel dmodel) {
    if (_searchText.isEmpty) {
      return dmodel.workouts;
    }
    return dmodel.workouts
        .where((element) =>
            element.workout.title.toLowerCase().contains(_searchText) ||
            element.categories
                .any((element) => element.toLowerCase().contains(_searchText)))
        .toList();
  }
}
