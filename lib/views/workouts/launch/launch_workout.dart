import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/workouts/launch/lw_exercise_detail.dart';
import 'package:workout_notepad_v2/views/workouts/launch/root.dart';

class LaunchWorkout extends StatelessWidget {
  const LaunchWorkout({
    super.key,
    required this.workout,
    this.exercises,
  });
  final Workout workout;
  final List<WorkoutExercise>? exercises;

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return ChangeNotifierProvider(
      create: (context) =>
          LaunchWorkoutModel(dmodel.user!.userId, workout, exercises),
      builder: ((context, child) {
        return _body(context);
      }),
    );
  }

  Widget _body(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    var lmodel = Provider.of<LaunchWorkoutModel>(context);
    return comp.InteractiveSheet(
      header: (context) => _header(context, dmodel, lmodel),
      builder: (context) {
        return PageView(
          onPageChanged: (value) => lmodel.setIndex(value),
          controller: lmodel.pageController,
          children: [
            if (lmodel.exerciseChildren.isNotEmpty)
              for (int i = 0; i < lmodel.exercises.length; i++)
                LWExerciseDetail(index: i),
          ],
        );
      },
    );
  }

  Widget _header(
      BuildContext context, DataModel dmodel, LaunchWorkoutModel lmodel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            comp.CloseButton(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            const Spacer(),
            FilledButton(
              onPressed: () async {
                await lmodel.finishWorkout(dmodel);
                Navigator.of(context).pop();
              },
              child: Text("Finish Workout"),
            ),
          ],
        ),
        Text(
          lmodel.workout.title,
          style: ttTitle(
            context,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        if (lmodel.workout.description != null)
          Text(
            lmodel.workout.description!,
            style: ttBody(
              context,
              color: Theme.of(context)
                  .colorScheme
                  .onSecondaryContainer
                  .withOpacity(0.5),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              comp.TextTimer(
                style: ttLabel(
                  context,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                onMsTick: ((time) => lmodel.duration = time.inSeconds),
              ),
              const Spacer(),
              Text(
                "${lmodel.workoutIndex + 1}/${lmodel.exercises.length}",
                style: ttLabel(
                  context,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
