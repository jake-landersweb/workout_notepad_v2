class ExerciseChildArgs {
  late int order;
  int? sets;
  int? reps;
  int? time;
  String? timePost;

  ExerciseChildArgs({
    required this.order,
    this.sets,
    this.reps,
    this.time,
    this.timePost,
  });

  ExerciseChildArgs.fromJson(Map<String, dynamic> json, int order) {
    order = order;
    sets = json['sets'];
    reps = json['reps'];
    time = json['time'];
    timePost = json['timePost'];
  }

  @override
  String toString() {
    return "sets: $sets, reps: $reps, time: $time, timePost: $timePost";
  }
}
