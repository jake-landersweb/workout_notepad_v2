import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/workout_cat.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/views/root.dart';
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
            comp.cupertinoSheet(
              context: context,
              builder: (context) => CEWRoot(
                isCreate: true,
                onAction: (w) {
                  print(w);
                },
              ),
            );
            // sui.Navigate(
            //   context,
            // CEWRoot(
            //   isCreate: true,
            //   onAction: (w) {
            //     print(w);
            //   },
            // ),
            //   maintainState: false,
            // );
          },
        )
      ],
      children: [
        comp.SearchBar(
          onChanged: (val) {
            setState(() {
              _searchText = val.toLowerCase();
            });
          },
          labelText: "Search",
          hintText: "Search by title or category",
          initText: _searchText,
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
