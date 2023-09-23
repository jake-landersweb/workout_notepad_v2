import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/components/wrapped_button.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:intl/intl.dart';

import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/views/workouts/create_edit/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/launch_workout.dart';

class WorkoutsHome extends StatefulWidget {
  const WorkoutsHome({
    super.key,
    this.showBackButton = true,
  });
  final bool showBackButton;

  @override
  State<WorkoutsHome> createState() => _WorkoutsHomeState();
}

class _WorkoutsHomeState extends State<WorkoutsHome> {
  String _searchText = "";
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return Scaffold(
      body: HeaderBar(
        title: "Workouts",
        isLarge: true,
        bottomSpacing: 0,
        trailing: [
          comp.AddButton(
            onTap: () {
              showMaterialModalBottomSheet(
                context: context,
                enableDrag: false,
                builder: (context) => const CEW(),
              );
            },
          )
        ],
        children: [
          const SizedBox(height: 16),
          WrappedButton(
            title: "Start Empty Workout",
            rowAxisSize: MainAxisSize.max,
            type: WrappedButtonType.main,
            center: true,
            onTap: () async {
              var workout = Workout.init();
              workout.title = DateFormat('MM-dd-yy h:mm:ssa').format(
                DateTime.now(),
              );
              var db = await DatabaseProvider().database;
              await db.insert("workout", workout.toMap());
              await launchWorkout(context, dmodel, workout, isEmpty: true);
            },
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 16),
          for (var i in _workouts(context, dmodel))
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: WorkoutCell(workout: i),
            ),
          SizedBox(
              height: (dmodel.workoutState == null ? 100 : 130) +
                  (dmodel.user!.offline ? 30 : 0)),
        ],
      ),
    );
  }

  List<Workout> _workouts(BuildContext context, DataModel dmodel) {
    if (_searchText.isEmpty) {
      return dmodel.workouts;
    }
    return dmodel.workouts
        .where((element) =>
            element.title.toLowerCase().contains(_searchText) ||
            element.categories
                .any((element) => element.toLowerCase().contains(_searchText)))
        .toList();
  }
}
