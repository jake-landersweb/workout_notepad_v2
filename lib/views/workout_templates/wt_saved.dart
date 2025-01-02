import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/back_button.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/views/workouts/workout_cell.dart';

class WTSaved extends StatefulWidget {
  const WTSaved({super.key});

  @override
  State<WTSaved> createState() => _WTSavedState();
}

class _WTSavedState extends State<WTSaved> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return Scaffold(
      body: HeaderBar(
        title: "Saved Templates",
        isLarge: true,
        bottomSpacing: 0,
        leading: const [BackButton2()],
        trailing: [],
        children: [
          const SizedBox(height: 16),
          Column(
            children: [
              for (var i in dmodel.workoutTemplates)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: WorkoutCell(workout: i),
                ),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
