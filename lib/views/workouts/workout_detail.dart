// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/close_button.dart';
import 'package:workout_notepad_v2/components/cupertino_sheet.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/data/root.dart';

import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/workout_template.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workouts/clone_workout.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:workout_notepad_v2/views/workouts/create_edit/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/launch_workout.dart';
import 'package:workout_notepad_v2/views/workouts/logs/root.dart';

class WorkoutDetail extends StatefulWidget {
  WorkoutDetail({
    super.key,
    required this.workout,
    bool? allowActions,
    this.isTemplate = false,
  }) {
    isCupertino = false;
    showButtons = allowActions ?? true;
    allowEdit = allowActions ?? true;
  }
  WorkoutDetail.small({
    super.key,
    required this.workout,
    this.isTemplate = false,
  }) {
    isCupertino = true;
    showButtons = false;
  }
  late Workout workout;
  late bool isCupertino;
  late bool showButtons;
  late bool allowEdit;
  final bool isTemplate;

  @override
  State<WorkoutDetail> createState() => _WorkoutDetailState();
}

class _WorkoutDetailState extends State<WorkoutDetail> {
  late Workout _workout;

  @override
  void initState() {
    _workout = widget.workout.copy();
    super.initState();
  }

  // Future<void> _postUpdate(Workout w) async {
  //   setState(() {
  //     _workout = w;
  //   });
  //   // wait for db to load
  //   await Future.delayed(const Duration(milliseconds: 100));
  //   w.exercises = await w.getChildren();
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    if (widget.isCupertino) {
      return HeaderBar.sheet(
        title: _workout.title,
        horizontalSpacing: 0,
        trailing: const [CloseButton2()],
        children: _children(context, dmodel),
      );
    }
    return Scaffold(
      body: HeaderBar(
        title: _workout.title,
        itemSpacing: 8,
        isLarge: true,
        horizontalSpacing: 0,
        largeTitlePadding: const EdgeInsets.only(left: 16),
        leading: const [comp.BackButton2()],
        trailing: [
          if (dmodel.workoutState?.workout.workoutId != _workout.workoutId &&
              widget.allowEdit)
            comp.EditButton(
              onTap: () {
                showMaterialModalBottomSheet(
                  context: context,
                  enableDrag: false,
                  builder: (context) => CEW(
                    workout: _workout,
                    onAction: (workout) {
                      setState(() {
                        _workout = workout;
                      });
                    },
                  ),
                );
              },
            )
        ],
        children: _children(context, dmodel),
      ),
    );
  }

  List<Widget> _children(BuildContext context, DataModel dmodel) {
    return [
      // wrapped container to keep all widgets in memory
      Column(
        children: [
          const SizedBox(height: 8),
          if ((_workout.description ?? "") != "")
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  _workout.description!,
                  style: ttLabel(
                    context,
                    color: AppColors.subtext(context),
                  ),
                ),
              ),
            ),
          if (widget.isTemplate) _importButton(context, dmodel),
          const SizedBox(height: 16),
          if (widget.showButtons)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _actions(context, dmodel),
                const SizedBox(height: 16),
              ],
            ),
          for (int i = 0; i < _workout.getExercises().length; i++)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cell(context),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppColors.border(context), width: 3),
                ),
                child: Column(
                  children: [
                    for (int j = 0; j < _workout.getExercises()[i].length; j++)
                      Column(
                        children: [
                          ExerciseCell(
                            exercise: _workout.getExercises()[i][j],
                            padding: EdgeInsets.zero,
                            showBackground: false,
                          ),
                          if (j < _workout.getExercises()[i].length - 1)
                            Container(
                              color: AppColors.divider(context),
                              height: 1,
                              width: double.infinity,
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            )
                .animate(delay: (50 * i).ms)
                .slideX(
                    begin: 0.25,
                    curve: Sprung(36),
                    duration: const Duration(milliseconds: 500))
                .fadeIn(),
        ],
      ),
    ];
  }

  Widget _importButton(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Clickable(
        onTap: () async {
          if (widget.workout is WorkoutTemplate) {
            var success = await widget.workout.handleInsert();
            if (success) {
              snackbarStatus(
                context,
                "Successfully imported the template",
              );

              // reload the templates
              await dmodel.refreshWorkoutTemplates();
              Navigator.of(context).pop();
            } else {
              snackbarErr(
                context,
                "There was an issue importing the workout template",
              );
            }
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Center(
            child: Text(
              "Save Template",
              style: ttLabel(context, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actions(BuildContext context, DataModel dmodel) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            _actionCell(
              context: context,
              icon: Icons.play_arrow_rounded,
              title:
                  dmodel.workoutState?.workout.workoutId == _workout.workoutId
                      ? "Resume"
                      : "Start",
              description:
                  dmodel.workoutState?.workout.workoutId == _workout.workoutId
                      ? "Resume the workout"
                      : "Launch the workout",
              onTap: () async => launchWorkout(context, dmodel, _workout),
              index: 1,
            ),
            const SizedBox(width: 16),
            _actionCell(
              context: context,
              icon: Icons.sticky_note_2_rounded,
              title: "Logs",
              description: "View workout logs",
              onTap: () {
                cupertinoSheet(
                  context: context,
                  builder: (context) => WorkoutLogs(workout: _workout),
                );
              },
              index: 2,
            ),
            // const SizedBox(width: 16),
            // _actionCell(
            //   context: context,
            //   icon: Icons.camera_rounded,
            //   title: "Snapshots",
            //   description: "View previous versions",
            //   onTap: () {
            //     if (!dmodel.hasValidSubscription()) {
            //       cupertinoSheet(
            //         context: context,
            //         builder: (context) => const Subscriptions(),
            //       );
            //     } else {
            //       cupertinoSheet(
            //         context: context,
            //         builder: (context) => WorkoutSnapshots(workout: _workout),
            //       );
            //     }
            //   },
            //   index: 3,
            // ),
            const SizedBox(width: 16),
            _actionCell(
              context: context,
              icon: Icons.content_copy_rounded,
              title: "Clone",
              description: "Clone this workout",
              onTap: () {
                cupertinoSheet(
                  context: context,
                  builder: (context) => CloneWorkout(workout: _workout),
                );
              },
              index: 4,
            ),
            const SizedBox(width: 16),
            _actionCell(
              context: context,
              icon: Icons.delete_rounded,
              title: "Delete",
              description: "Delete this workout",
              onTap: () {
                showAlert(
                  context: context,
                  title: "Are You Sure?",
                  body: const Text("This action cannot be reversed."),
                  cancelText: "Cancel",
                  cancelBolded: true,
                  onCancel: () {},
                  submitText: "Delete",
                  submitColor: Colors.red,
                  onSubmit: () async {
                    try {
                      var db = await DatabaseProvider().database;
                      if (_workout is WorkoutTemplate) {
                        var template = _workout as WorkoutTemplate;
                        await db.transaction((txn) async {
                          await txn.rawDelete(
                            "DELETE FROM workout_template_exercise WHERE workoutTemplateId = ?",
                            [template.id],
                          );
                          await txn.rawDelete(
                            "DELETE FROM workout_template WHERE id = ?",
                            [template.id],
                          );
                        });
                        await dmodel.fetchData();
                        Navigator.of(context).pop();
                        snackbarStatus(
                          context,
                          "Successfully deleted the workout",
                        );
                      } else {
                        await db.transaction((txn) async {
                          await txn.rawDelete(
                            "DELETE FROM workout_exercise WHERE workoutId = ?",
                            [_workout.workoutId],
                          );
                          await txn.rawDelete(
                            "DELETE FROM workout WHERE workoutId = ?",
                            [_workout.workoutId],
                          );
                        });
                        await dmodel.fetchData();
                        Navigator.of(context).pop();
                        snackbarStatus(
                          context,
                          "Successfully deleted the workout",
                        );
                      }
                    } catch (e) {
                      print(e);
                      NewrelicMobile.instance.recordError(
                        e,
                        StackTrace.current,
                        attributes: {"err_code": "workout_delete"},
                      );
                    }
                  },
                );
              },
              index: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCell({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required int index,
  }) {
    final bgColor = AppColors.cell(context);
    final textColor = AppColors.text(context);
    final iconColor = Theme.of(context).colorScheme.primary;
    return Clickable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border(context), width: 3),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width / 2.5,
          minHeight: MediaQuery.of(context).size.width / 3,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: iconColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: ttLabel(
                  context,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: ttBody(
                  context,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (25 * index).ms)
        .slideX(
            begin: 0.25,
            curve: Sprung(36),
            duration: const Duration(milliseconds: 500))
        .fadeIn();
  }
}
