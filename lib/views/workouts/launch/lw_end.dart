// ignore_for_file: use_build_context_synchronously

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/exercises/select_exercise.dart';
import 'package:workout_notepad_v2/views/workouts/launch/lw_model.dart';
import 'package:workout_notepad_v2/views/workouts/launch/lw_save_template.dart';

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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            WrappedButton(
              title: "Add Another Exercise",
              icon: Icons.add,
              iconBg: Colors.green[300],
              borderColor: AppColors.border(context),
              onTap: () {
                cupertinoSheet(
                  context: context,
                  builder: (context) => SelectExercise(
                    onSelect: (e) {
                      lmodel.addExercise(
                        lmodel.state.exercises.length,
                        0,
                        e,
                        dmodel.tags
                            .firstWhereOrNull((element) => element.isDefault),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            WrappedButton(
              title: "Save As Template",
              icon: Icons.splitscreen,
              iconBg: Colors.blue[300]!,
              borderColor: AppColors.border(context),
              onTap: () async {
                await showFloatingSheet(
                  context: context,
                  builder: (context) => LWSaveAsTemplate(
                    initTitle: lmodel.state.workout.title,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            WrappedButton(
              title: "Cancel",
              icon: Icons.cancel_outlined,
              iconBg: Colors.red[300]!,
              borderColor: AppColors.border(context),
              onTap: () async {
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
            const SizedBox(height: 8),
            WrappedButton(
              title: "Finish Exercise",
              icon: Icons.star_rounded,
              iconBg: Colors.orange[200]!,
              borderColor: AppColors.border(context),
              onTap: () async {
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
                    Navigator.of(context, rootNavigator: true).pop();
                    await lmodel.handleFinish(context, dmodel);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
