import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/data/root.dart';

import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/root.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:workout_notepad_v2/views/workouts/logs/root.dart';
import 'package:workout_notepad_v2/views/workouts/workout_exercise_cell.dart';

class WorkoutDetail extends StatefulWidget {
  const WorkoutDetail({
    super.key,
    required this.workout,
  });
  final WorkoutCategories workout;

  @override
  State<WorkoutDetail> createState() => _WorkoutDetailState();
}

class _WorkoutDetailState extends State<WorkoutDetail> {
  late Workout _workout;
  List<WorkoutExercise> _exercises = [];

  @override
  void initState() {
    _workout = widget.workout.workout.copy();
    _init();
    super.initState();
  }

  Future<void> _init() async {
    var tmp = await _workout.getChildren();
    setState(() {
      _exercises = [];
      _exercises = tmp;
    });
  }

  Future<void> _postUpdate(Workout w) async {
    setState(() {
      _workout = w;
      _exercises = [];
    });
    // wait for db to load
    await Future.delayed(const Duration(milliseconds: 100));
    var tmp = await w.getChildren();
    setState(() {
      _exercises = tmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = context.read<DataModel>();
    return Scaffold(
      body: HeaderBar(
        title: _workout.title,
        itemSpacing: 8,
        isLarge: true,
        horizontalSpacing: 0,
        largeTitlePadding: const EdgeInsets.only(left: 16),
        leading: const [comp.BackButton()],
        trailing: [
          if (dmodel.workoutState?.workout.workoutId != _workout.workoutId)
            comp.EditButton(
              onTap: () {
                showMaterialModalBottomSheet(
                  context: context,
                  enableDrag: false,
                  builder: (context) => CEWRoot(
                    isCreate: false,
                    workout: _workout,
                    onAction: (workout) async => _postUpdate(workout),
                  ),
                );
              },
            )
        ],
        children: [
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
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _actions(context, dmodel),
              const SizedBox(height: 16),
              for (int i = 0; i < _exercises.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: WorkoutExerciseCell(
                      workoutId: widget.workout.workout.workoutId,
                      exercise: _exercises[i]),
                )
                    .animate(delay: (25 * i).ms)
                    .slideX(
                        begin: 0.25,
                        curve: Sprung(36),
                        duration: const Duration(milliseconds: 500))
                    .fadeIn()
            ],
          ),
        ],
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
                showMaterialModalBottomSheet(
                  context: context,
                  builder: (context) => WorkoutLogs(workout: _workout),
                );
              },
              index: 2,
            ),
            const SizedBox(width: 16),
            _actionCell(
              context: context,
              icon: Icons.delete_rounded,
              title: "Delete",
              description: "Delete this workout",
              onTap: () {
                // TODO -- implement
              },
              index: 3,
            )
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
    final bgColor =
        Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5);
    final textColor = Theme.of(context).colorScheme.onPrimaryContainer;
    final iconColor = Theme.of(context).colorScheme.primary;
    return Clickable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width / 2.5,
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
