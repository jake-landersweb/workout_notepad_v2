import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/exercise_set.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:sapphireui/sapphireui.dart' as sui;

class LaunchWorkoutModel extends ChangeNotifier {
  int workoutIndex = 0;
  late Workout workout;
  late List<WorkoutExercise> exercises;
  late PageController pageController;
  List<List<ExerciseSet>> exerciseChildren = [];

  LaunchWorkoutModel(Workout w, List<WorkoutExercise> e) {
    workout = w;
    exercises = e;
    pageController = PageController(initialPage: workoutIndex);
    _getExerciseChildren();
  }

  Future<void> _getExerciseChildren() async {
    for (var i in exercises) {
      var tmp = await i.getChildren(workout.workoutId);
      exerciseChildren.add(tmp);
    }
    notifyListeners();
  }

  void setIndex(int index) {
    workoutIndex = index;
    notifyListeners();
  }

  void setPage(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Sprung(36),
    );
  }

  Widget header(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < exercises.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _cell(context, exercises[i], i),
              if (i < exercises.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    // color: Theme.of(context).primaryColor,
                    color: Colors.white,
                    height: 1,
                    width: 20,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _cell(BuildContext context, WorkoutExercise e, int index) {
    return sui.Button(
      onTap: () => setPage(index),
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          // color: workoutIndex >= index
          //     ? Theme.of(context).primaryColor
          //     : Colors.transparent,
          color: workoutIndex >= index
              ? Colors.white
              : Theme.of(context).primaryColor,
          shape: BoxShape.circle,
          // border: Border.all(color: Theme.of(context).primaryColor, width: 2),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Text(
            (index + 1).toString(),
            style: ttLabel(
              context,
              // color: workoutIndex >= index
              //     ? Colors.white
              //     : Theme.of(context).primaryColor,
              color: workoutIndex >= index
                  ? Theme.of(context).primaryColor
                  : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
