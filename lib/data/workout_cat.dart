import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/root.dart';

class WorkoutCategories {
  final Workout workout;
  final List<String> categories;

  WorkoutCategories({
    required this.workout,
    required this.categories,
  });

  WorkoutCategories clone() => WorkoutCategories(
        workout: workout.copy(),
        categories: [for (var i in categories) i],
      );

  static Future<List<WorkoutCategories>> getList() async {
    final db = await getDB();
    String sql = """
      SELECT * FROM workout
      ORDER BY created DESC
    """;
    final List<Map<String, dynamic>> response = await db.rawQuery(sql);
    List<WorkoutCategories> wc = [];
    for (var i in response) {
      var w = Workout.fromJson(i);
      var c = await w.getCategories();
      wc.add(WorkoutCategories(workout: w, categories: c));
    }
    return wc;
  }
}
