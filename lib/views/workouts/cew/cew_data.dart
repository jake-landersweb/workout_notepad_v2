import 'package:workout_notepad_v2/data/exercise.dart';

class CEWExercise {
  late Exercise exercise;
  late List<Exercise> children;

  CEWExercise.init(Exercise e) {
    exercise = e.copy();
    children = [];
  }
}
