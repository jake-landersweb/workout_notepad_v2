import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/model/root.dart';

List<Exercise> filteredExercises(List<Exercise> exercises, String searchText) {
  if (searchText.isEmpty) {
    return exercises;
  }
  return exercises
      .where((element) =>
          element.title.toLowerCase().contains(searchText) ||
          element.category.contains(searchText))
      .toList();
}
