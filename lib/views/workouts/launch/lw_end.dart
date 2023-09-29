// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/exercises/select_exercise.dart';
import 'package:workout_notepad_v2/views/workouts/launch/lw_model.dart';

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
          ContainedList<Tuple4<IconData, String, Color, AsyncCallback>>(
            childPadding: EdgeInsets.zero,
            children: [
              Tuple4(
                Icons.add,
                "Add Another Exercise",
                Colors.green[300]!,
                () async {
                  cupertinoSheet(
                    context: context,
                    builder: (context) => SelectExercise(
                      onSelect: (e) {
                        lmodel.addExercise(lmodel.state.exercises.length, 0, e);
                      },
                    ),
                  );
                },
              ),
              Tuple4(
                Icons.close_rounded,
                "Cancel Workout",
                Colors.red[300]!,
                () async {
                  await showAlert(
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
                      dmodel.stopWorkout(isCancel: true);
                    },
                  );
                },
              ),
              Tuple4(
                Icons.star_rounded,
                "Finish Workout",
                Colors.orange[200]!,
                () async {
                  await showAlert(
                    context: context,
                    title: "Are You Sure?",
                    body: const Text(
                        "Once you finish a workout, you cannot go back and modify it."),
                    cancelText: "Go Back",
                    onCancel: () {},
                    submitBolded: true,
                    submitText: "Finish",
                    onSubmit: () async {
                      lmodel.handleFinish(context, dmodel);
                    },
                  );
                },
              ),
            ],
            onChildTap: (context, item, _) async {
              await item.v4();
            },
            childBuilder: (context, item, _) {
              return WrappedButton(
                title: item.v2,
                icon: item.v1,
                iconBg: item.v3,
              );
            },
          ),
        ],
      ),
    );
  }
}
