import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
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
    var dmodel = Provider.of<DataModel>(context);
    return SingleChildScrollView(
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: Column(
        children: [
          const SizedBox(height: 16),
          ContainedList<Tuple2<IconData, String>>(
            children: [
              Tuple2(Icons.add, "Add Another Exercise"),
              Tuple2(Icons.close_rounded, "Cancel Workout"),
              Tuple2(Icons.star_rounded, "Finish Workout"),
            ],
            onChildTap: (context, item) {
              if (item.v2 == "Add Another Exercise") {
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
              } else if (item.v2 == "Cancel Workout") {
                showAlert(
                  context: context,
                  title: "Are You Sure?",
                  body: const Text(
                      "If you cancel your workout, all progress will be lost."),
                  cancelText: "Go Back",
                  onCancel: () {},
                  cancelBolded: true,
                  submitColor: Colors.red,
                  submitText: "Yes",
                  onSubmit: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    dmodel.stopWorkout();
                  },
                );
              } else if (item.v2 == "Finish Workout") {
                showAlert(
                  context: context,
                  title: "Are You Sure?",
                  body: const Text(
                      "Once you finish a workout, you cannot go back and modify it."),
                  cancelText: "Go Back",
                  onCancel: () {},
                  submitBolded: true,
                  submitText: "Finish",
                  onSubmit: () async {
                    await lmodel.finishWorkout(dmodel);
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                );
              }
            },
            childBuilder: (context, item) {
              return Row(
                children: [
                  Icon(item.v1, color: AppColors.cell(context)[700]),
                  const SizedBox(width: 8),
                  Text(
                    item.v2,
                    style: TextStyle(
                      color: AppColors.subtext(context),
                      fontSize: 18,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
