import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';

List<Exercise> filteredExercises(
    DataModel dmodel, List<Exercise> exercises, String searchText) {
  if (searchText.isEmpty) {
    return exercises;
  }

  List<Category> cat = dmodel.categories
      .where((element) => element.title.toLowerCase().contains(
            searchText.toLowerCase(),
          ))
      .toList();

  return exercises
      .where(
        (element) =>
            element.title.toLowerCase().contains(searchText) ||
            cat.any((c) => c.categoryId == element.category),
      )
      .toList();
}
