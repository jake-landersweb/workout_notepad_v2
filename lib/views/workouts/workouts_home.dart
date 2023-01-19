import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/views/workouts/workout_cell.dart';
import 'package:sapphireui/sapphireui.dart' as sui;

class WorkoutsHome extends StatefulWidget {
  const WorkoutsHome({super.key});

  @override
  State<WorkoutsHome> createState() => _WorkoutsHomeState();
}

class _WorkoutsHomeState extends State<WorkoutsHome> {
  @override
  Widget build(BuildContext context) {
    return sui.AppBar(
      title: "Workouts",
      isLarge: true,
      children: [
        _body(context),
      ],
    );
  }

  Widget _body(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i in dmodel.workouts) WorkoutCell(workout: i),
      ],
    );
  }
}
