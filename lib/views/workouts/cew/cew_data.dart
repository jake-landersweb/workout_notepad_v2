import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/exercise.dart';

class CEWExercise {
  late String id;
  late Exercise exercise;
  late List<Exercise> children;

  CEWExercise.init(Exercise e) {
    var uuid = const Uuid();
    id = uuid.v4();
    exercise = e.copy();
    children = [];
  }
}
