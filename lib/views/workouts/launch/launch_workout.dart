import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/workouts/launch/root.dart';

class LaunchWorkout extends StatelessWidget {
  const LaunchWorkout({
    super.key,
    required this.workout,
    required this.exercises,
  });
  final Workout workout;
  final List<WorkoutExercise> exercises;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LaunchWorkoutModel(workout, exercises),
      builder: ((context, child) {
        return _body(context);
      }),
    );
  }

  Widget _body(BuildContext context) {
    var lmodel = Provider.of<LaunchWorkoutModel>(context);
    return Stack(
      children: [
        // weird trick to remove line
        Container(
          color: Theme.of(context).primaryColor,
        ),
        Column(
          children: [
            Container(
              color: Theme.of(context).primaryColor,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  lmodel.workout.title,
                                  style: ttSubTitle(
                                    context,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: comp.CloseButton(
                            color: Colors.white,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "${lmodel.workoutIndex + 1}/${lmodel.exercises.length}",
                            style: ttLabel(
                              context,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  lmodel.header(context),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    color: Theme.of(context).primaryColor,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      color: sui.CustomColors.backgroundColor(context),
                      child: PageView(
                        onPageChanged: (value) => lmodel.setIndex(value),
                        controller: lmodel.pageController,
                        children: [
                          if (lmodel.exerciseChildren.isNotEmpty)
                            for (int i = 0; i < lmodel.exercises.length; i++)
                              LWExerciseCell(
                                workout: workout,
                                exercise: lmodel.exercises[i],
                                children: lmodel.exerciseChildren[i],
                              ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
