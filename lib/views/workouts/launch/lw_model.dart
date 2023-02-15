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
    if (exercises.length > 8) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _header(context),
      );
    } else {
      return _header(context);
    }
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
      child: Row(
        children: [
          for (int i = 0; i < exercises.length; i++)
            if (exercises.length > 8)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: _cell(context, exercises[i], i),
                  ),
                ],
              )
            else
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: _cell(context, exercises[i], i),
                    )),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, WorkoutExercise e, int index) {
    return sui.Button(
      onTap: () => setPage(index),
      child: Container(
        width: exercises.length > 8 ? 50 : double.infinity,
        constraints: const BoxConstraints(maxHeight: 60),
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
        child: AspectRatio(
          aspectRatio: 1,
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
      ),
    );
  }
}
