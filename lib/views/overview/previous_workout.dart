import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/modal_sheet.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/query_model.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/logger.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/logs/post_workout.dart';
import 'package:workout_notepad_v2/views/workouts/logs/graphs/wl_distribution.dart';
import 'package:workout_notepad_v2/views/workouts/logs/wl_cell_alt.dart';

class PreviousWorkout extends StatefulWidget {
  const PreviousWorkout({super.key});

  @override
  State<PreviousWorkout> createState() => _PreviousWorkoutState();
}

class _PreviousWorkoutState extends State<PreviousWorkout> {
  @override
  Widget build(BuildContext context) {
    return Section(
      "Latest Workout",
      trailingWidget: Clickable(
        onTap: () async {
          var wl = await context.read<QueryModel>().getPreviousWorkout().first;
          if (wl.data != null) {
            showModalSheet(
              context: context,
              builder: (context, scrollController, scrollArea) =>
                  PostWorkoutSummary(
                workoutLogId: wl.data!.v1.workoutLogId,
                scrollController: scrollController,
                scrollArea: scrollArea,
                onSave: (v) {},
              ),
            );
          } else {
            snackbarErr(
                context, "There was an issue getting your last workout");
          }
        },
        child: const Opacity(
          opacity: 0.7,
          child: Row(
            children: [
              Text("Details"),
            ],
          ),
        ),
      ),
      child: AspectRatio(
        aspectRatio: 1.1,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cell(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border(context), width: 3),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _body(context),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return StreamBuilder(
      stream: context.watch<QueryModel>().getPreviousWorkout(),
      builder: (context, snapshot) {
        // checkk for stream error
        if (snapshot.hasError) {
          logger.error("Stream error:",
              {"error": snapshot.error, "stackTrace": snapshot.stackTrace});
          return Center(
            child: Text("Uh oh! Stream Error: ${snapshot.error}"),
          );
        }

        // loading
        if (snapshot.connectionState == ConnectionState.waiting ||
            (snapshot.hasData &&
                snapshot.data?.data == null &&
                snapshot.error == null)) {
          return const Center(child: LoadingIndicator());
        }

        // Error getting the actual data packet
        if (snapshot.hasData && snapshot.error != null) {
          return Center(
            child: Text("Uh oh! Issue: ${snapshot.error}"),
          );
        }

        // success case
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.data != null) {
          var data = snapshot.data!.data!; // Now this should be safe
          return _view(context, data.v1, data.v2);
        }

        logger.error(
            "Unexpected state or no data. Displaying loading as fallback.");
        return const Center(child: LoadingIndicator());
      },
    );
  }

  var repsColor = Colors.red.shade300;
  var weightColor = Colors.green.shade300;
  var timeColor = Colors.blue.shade300;

  List<BarChartGroupData> _barData(WorkoutLog wl) {
    List<BarChartGroupData> groups = [];
    if (wl.exerciseLogs.length <= 2) {
      for (int i = 0; i < wl.exerciseLogs.length; i++) {
        groups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              for (var log in wl.exerciseLogs[i])
                BarChartRodData(
                  toY: log.metadata.map((v) => v.reps).sum.toDouble(),
                  color: repsColor,
                ),
              for (var log in wl.exerciseLogs[i])
                BarChartRodData(
                  toY: log.metadata.map((v) => v.weight).sum.toDouble(),
                  color: weightColor,
                ),
              for (var log in wl.exerciseLogs[i])
                BarChartRodData(
                  toY: log.metadata.map((v) => v.time).sum.toDouble(),
                  color: timeColor,
                ),
            ],
          ),
        );
      }
      return groups;
    }

    var totalReps = wl.exerciseLogs
        .map((v) => v.map((e) => e.metadata.map((v) => v.reps).sum).sum)
        .max
        .toDouble();

    var totalWeight = wl.exerciseLogs
        .map((v) => v.map((e) => e.metadata.map((v) => v.weight).sum).sum)
        .max
        .toDouble();

    var totalTime = wl.exerciseLogs
        .map((v) => v.map((e) => e.metadata.map((v) => v.time).sum).sum)
        .max
        .toDouble();

    for (int i = 0; i < wl.exerciseLogs.length; i++) {
      var reps = wl.exerciseLogs[i]
              .map((e) => e.metadata.map((v) => v.reps).sum)
              .sum
              .toDouble() /
          totalReps;
      var weight = wl.exerciseLogs[i]
              .map((e) => e.metadata.map((v) => v.weight).sum)
              .sum
              .toDouble() /
          totalWeight;
      var time = wl.exerciseLogs[i]
              .map((e) => e.metadata.map((v) => v.time).sum)
              .sum
              .toDouble() /
          totalTime;
      groups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(toY: reps, color: repsColor),
          BarChartRodData(toY: weight, color: weightColor),
          BarChartRodData(toY: time, color: timeColor),
        ],
      ));
    }

    return groups;
  }

  Widget _barDistribution(
    BuildContext context,
    WorkoutLog log,
  ) {
    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              barGroups: _barData(log),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                rightTitles: AxisTitles(),
                topTitles: AxisTitles(),
                leftTitles: AxisTitles(),
                bottomTitles: AxisTitles(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: repsColor,
                    shape: BoxShape.circle,
                  ),
                  height: 10,
                  width: 10,
                ),
                const SizedBox(width: 4),
                Text("Reps", style: ttcaption(context)),
              ],
            ),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: weightColor,
                    shape: BoxShape.circle,
                  ),
                  height: 10,
                  width: 10,
                ),
                const SizedBox(width: 4),
                Text("Weight", style: ttcaption(context)),
              ],
            ),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: timeColor,
                    shape: BoxShape.circle,
                  ),
                  height: 10,
                  width: 10,
                ),
                const SizedBox(width: 4),
                Text("Time", style: ttcaption(context)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _view(
      BuildContext context, WorkoutLog log, List<List<ExerciseLog>> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WorkoutLogCellAlt(
          log: log,
          endContent: Container(),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${(log.exerciseLogs.length > 3 ? log.exerciseLogs.length : log.exerciseLogs.flattened.length).toString()} - Exercises",
                                    style: ttLabel(context),
                                  ),
                                  Text(
                                    "${_getTotalSets(log).toString()} - Sets",
                                    style: ttLabel(context),
                                  ),
                                  Text(
                                    "${_getTotalReps(log).toString()} - Reps",
                                    style: ttLabel(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: _pieChart(
                          context,
                          "Tag Dist.",
                          _getDynamicPieChartData(log),
                          expanded: false,
                          showHeader: false,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: WLDistribution(workoutLogId: log.workoutLogId),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int _getTotalSets(WorkoutLog log) {
    return log.exerciseLogs.fold(
      0,
      (previousValue, element) =>
          previousValue +
          element.fold(
            0,
            (previousValue, element) => previousValue + element.metadata.length,
          ),
    );
  }

  int _getTotalReps(WorkoutLog log) {
    return log.exerciseLogs.fold(
        0,
        (previousValue, element) =>
            previousValue +
            element.fold(
                0,
                (previousValue, element) =>
                    previousValue +
                    element.metadata.fold(
                        0,
                        (previousValue, element) =>
                            previousValue + element.reps)));
  }

  List<Tuple2<String, int>> _getTagsData(WorkoutLog log) {
    List<Tuple2<String, int>> tags = [];

    for (var i in log.exerciseLogs) {
      for (var j in i) {
        for (var meta in j.metadata) {
          for (var tag in meta.tags) {
            var tmpTag =
                tags.firstWhereOrNull((element) => element.v1 == tag.title);
            if (tmpTag == null) {
              tags.add(Tuple2(tag.title, 1));
            } else {
              tmpTag.v2 += 1;
            }
          }
        }
      }
    }

    return tags;
  }

  List<Tuple2<String, int>> _getSetTypeData(WorkoutLog log) {
    List<Tuple2<String, int>> types = [];

    for (var i in log.exerciseLogs) {
      for (var j in i) {
        var tmp =
            types.firstWhereOrNull((v) => v.v1 == exerciseTypeTitle(j.type));
        if (tmp == null) {
          types.add(Tuple2(exerciseTypeTitle(j.type), 0));
        } else {
          tmp.v2 += 1;
        }
      }
    }

    return types;
  }

  List<Tuple2<String, int>> _getDynamicPieChartData(WorkoutLog log) {
    var tags = _getTagsData(log);
    var types = _getSetTypeData(log);
    if (tags.length == 1) {
      if (types.length == 1) {
        return tags;
      }
      return types;
    }
    return tags;
  }

  Widget _pieChart(
    BuildContext context,
    String title,
    List<Tuple2<String, int>> data, {
    bool showHeader = true,
    bool expanded = false,
  }) {
    final pieSections = data.map((i) {
      final color = ColorUtil.random(i.v1);
      return PieChartSectionData(
        value: i.v2.toDouble(),
        color: color,
        title: "",
      );
    }).toList();

    Widget content = PieChart(
      PieChartData(sections: pieSections),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: content),
        Text("Tag Dist.", style: ttcaption(context)),
      ],
    );
  }
}
