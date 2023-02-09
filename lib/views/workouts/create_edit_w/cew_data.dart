import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/exercise_set.dart';
import 'package:workout_notepad_v2/data/root.dart';

class CEWExercise {
  late String id;
  late WorkoutExercise exercise;
  late List<ExerciseSet> children;

  CEWExercise.init(WorkoutExercise e) {
    var uuid = const Uuid();
    id = uuid.v4();
    exercise = e.copy();
    children = [];
  }

  CEWExercise.from(WorkoutExercise e, List<ExerciseSet> c) {
    id = e.workoutExerciseId;
    exercise = e.copy();
    children = [for (var i in c) i.copy()];
  }
}
