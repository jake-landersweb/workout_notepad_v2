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
import 'package:workout_notepad_v2/model/local_prefs.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/logs/post_workout.dart';
import 'package:workout_notepad_v2/views/workouts/logs/wl_cell_alt.dart';

class PreviousWorkout extends StatefulWidget {
  const PreviousWorkout({super.key});

  @override
  State<PreviousWorkout> createState() => _PreviousWorkoutState();
}

class _PreviousWorkoutState extends State<PreviousWorkout> {
  List<int> _getWeightDistribution(List<List<ExerciseLog>> logs) {
    var localPrefs = context.read<LocalPrefs>();

    List<int> wd = [];

    for (var i in logs) {
      var weight = 0;
      for (var j in i) {
        // total weight
        if (j.metadata.isNotEmpty) {
          if (j.metadata[0].weightPost == "kg") {
            if (localPrefs.defaultWeightPost == "lbs") {
              weight += (j.metadata.map((e) => e.weight).sum * 2.2).toInt();
            } else {
              weight += j.metadata.map((e) => e.weight).sum;
            }
          } else {
            if (localPrefs.defaultWeightPost == "lbs") {
              weight += j.metadata.map((e) => e.weight).sum;
            } else {
              weight += (j.metadata.map((e) => e.weight).sum / 2.2).toInt();
            }
          }
        }
      }
      wd.add(weight);
    }

    return wd;
  }

  List<int> _getRepsDistribution(List<List<ExerciseLog>> logs) {
    List<int> rd = [];

    for (var i in logs) {
      var reps = 0;
      for (var j in i) {
        // total weight
        if (j.metadata.isNotEmpty) {
          if (j.metadata[0].weightPost == "kg") {
            reps += j.metadata.map((e) => e.reps).sum;
          } else {
            reps += j.metadata.map((e) => e.reps).sum;
          }
        }
      }
      rd.add(reps);
    }

    return rd;
  }

  List<int> _getTimeDistribution(List<List<ExerciseLog>> logs) {
    List<int> td = [];

    for (var i in logs) {
      var time = 0;
      for (var j in i) {
        // total weight
        if (j.metadata.isNotEmpty) {
          if (j.metadata[0].weightPost == "kg") {
            time += j.metadata.map((e) => e.time).sum;
          } else {
            time += j.metadata.map((e) => e.time).sum;
          }
        }
      }
      td.add(time);
    }

    return td;
  }

  // Function to normalize a list of integers to a list of doubles (0-1 range)
  List<double> normalizeIntegerList(List<int> numbers) {
    if (numbers.isEmpty) {
      return []; // Return an empty list if the input is empty
    }

    // Find the minimum and maximum values in the list
    // We can do this with a simple loop or using reduce.
    // Loop approach (often clearer for beginners and handles single element lists well):
    int minVal = numbers[0];
    int maxVal = numbers[0];

    for (int i = 1; i < numbers.length; i++) {
      if (numbers[i] < minVal) {
        minVal = numbers[i];
      }
      if (numbers[i] > maxVal) {
        maxVal = numbers[i];
      }
    }

    // Alternative using reduce (requires 'dart:math' and list must not be empty):
    // if (numbers.isEmpty) return []; // Handled above
    // int minVal = numbers.reduce(min);
    // int maxVal = numbers.reduce(max);

    // Handle the case where all numbers are the same (to avoid division by zero)
    if (minVal == maxVal) {
      // If all numbers are the same, they are all "normalized" to 0.0
      // (or 0.5, or 1.0 depending on convention, 0.0 is common if there's no spread)
      return List<double>.filled(numbers.length, 0.0);
    }

    // Calculate the range
    double range = (maxVal - minVal).toDouble();

    // Normalize each number and add to the new list
    List<double> normalizedList = [];
    for (int value in numbers) {
      double normalizedValue = (value - minVal) / range;
      normalizedList.add(normalizedValue);
    }

    // More concise way using map:
    // return numbers.map((value) => (value - minVal) / range).toList();

    return normalizedList;
  }

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
                snapshot.data?.error == null)) {
          return const Center(child: LoadingIndicator());
        }

        // Error getting the actual data packet
        if (snapshot.hasData && snapshot.data?.error != null) {
          return Center(
            child: Text("Uh oh! Issue: ${snapshot.data!.error}"),
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

  final _weightColor = Colors.green[400]!;
  final _repsColor = Colors.purple[300]!;
  final _timeColor = Colors.amber[700]!;

  Widget _weightBySet(
    BuildContext context,
    WorkoutLog log,
    List<List<ExerciseLog>> logs,
  ) {
    var localPrefs = context.watch<LocalPrefs>();
    var wd = _getWeightDistribution(logs);
    var wdNormalized = normalizeIntegerList(wd);
    var rd = _getRepsDistribution(logs);
    var rdNormalized = normalizeIntegerList(rd);
    var td = _getTimeDistribution(logs);
    var tdNormalized = normalizeIntegerList(td);
    Widget content = Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    barWidth: 3,
                    color: _weightColor,
                    isCurved: true,
                    preventCurveOverShooting: false,
                    curveSmoothness: 0.2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (p0, p1, p2, p3) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: _weightColor,
                          strokeWidth: 0,
                        );
                      },
                    ),
                    spots: [
                      for (int i = 0; i < wd.length; i++)
                        FlSpot(i + 1, wdNormalized[i].toDouble())
                    ],
                  ),
                  LineChartBarData(
                    barWidth: 3,
                    color: _repsColor,
                    isCurved: true,
                    preventCurveOverShooting: false,
                    curveSmoothness: 0.2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (p0, p1, p2, p3) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: _repsColor,
                          strokeWidth: 0,
                        );
                      },
                    ),
                    spots: [
                      for (int i = 0; i < rd.length; i++)
                        FlSpot(i + 1, rdNormalized[i].toDouble())
                    ],
                  ),
                  LineChartBarData(
                    barWidth: 3,
                    color: _timeColor,
                    isCurved: true,
                    preventCurveOverShooting: false,
                    curveSmoothness: 0.2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (p0, p1, p2, p3) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: _timeColor,
                          strokeWidth: 0,
                        );
                      },
                    ),
                    spots: [
                      for (int i = 0; i < td.length; i++)
                        FlSpot(i + 1, tdNormalized[i].toDouble())
                    ],
                  ),
                ],
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipColor: (spot) {
                      return AppColors.cell(context);
                    },
                    getTooltipItems: (touchedSpots) {
                      List<LineTooltipItem> items = [];
                      for (int i = 0; i < touchedSpots.length; i++) {
                        String text = "";
                        if (i == 0) {
                          text += "Set #${touchedSpots[i].x.round()}\n";
                        }

                        final String colorString =
                            touchedSpots[i].bar.color!.toString();

                        if (colorString == _weightColor.toString()) {
                          text +=
                              "${wd[touchedSpots[i].spotIndex]} ${localPrefs.defaultWeightPost}";
                        } else if (colorString == _repsColor.toString()) {
                          text += "${rd[touchedSpots[i].spotIndex]} Reps";
                        } else if (colorString == _timeColor.toString()) {
                          text += formatHHMMSS(td[touchedSpots[i].spotIndex]);
                        }

                        items.add(
                          LineTooltipItem(
                            text,
                            ttBody(
                              context,
                              color: touchedSpots[i].bar.color,
                            ),
                          ),
                        );
                      }
                      return items;
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(),
                  topTitles: AxisTitles(),
                  leftTitles: AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.round() != value) {
                          return Container();
                        }
                        late String text;
                        if (wd.length > 5) {
                          text = "${value.round()}";
                        } else {
                          text =
                              "${wd[value.round() - 1]} ${localPrefs.defaultWeightPost}";
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.subtext(context),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _barLegendItem(context, "Weight", _weightColor),
            _barLegendItem(context, "Reps", _repsColor),
            _barLegendItem(context, "Time", _timeColor),
          ],
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: content),
      ],
    );
  }

  Widget _barLegendItem(
    BuildContext context,
    String title,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          height: 7,
          width: 7,
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 50,
          child: Text(title,
              style: TextStyle(fontSize: 12), textAlign: TextAlign.center),
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
        // Row(
        //   children: [
        //     Expanded(
        //       child: _cell(
        //         context,
        //         _attributeCell(
        //           context,
        //           "Exercises",
        //           (log.exerciseLogs.length > 3
        //                   ? log.exerciseLogs.length
        //                   : log.exerciseLogs.flattened.length)
        //               .toString(),
        //           vertical: true,
        //         ),
        //       ),
        //     ),
        //     const SizedBox(width: 4),
        //     Expanded(
        //       child: _cell(
        //         context,
        //         _attributeCell(
        //           context,
        //           "Sets",
        //           _getTotalSets(log).toString(),
        //           vertical: true,
        //         ),
        //       ),
        //     ),
        //     const SizedBox(width: 4),
        //     Expanded(
        //       child: _cell(
        //         context,
        //         _attributeCell(
        //           context,
        //           "Reps",
        //           _getTotalReps(log).toString(),
        //           vertical: true,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
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
                  child: _weightBySet(context, log, logs),
                ),

                // const SizedBox(height: 4),
                // Expanded(
                //   child: _barDistribution(context, log),
                // ),
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

  Widget _cell(BuildContext context, Widget value, {double height = 50}) {
    return Container(
      decoration: BoxDecoration(
        // color: AppColors.cell(context)[300],
        borderRadius: BorderRadius.circular(10),
        // border: Border.all(color: AppColors.border(context)),
      ),
      width: double.infinity,
      height: height,
      child: Center(child: value),
    );
  }

  Widget _attributeCell(
    BuildContext context,
    String label,
    String value, {
    bool vertical = false,
  }) {
    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
          Text(label, style: ttcaption(context)),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 0, 8),
            child: Text(label, style: ttcaption(context)),
          ),
        ],
      );
    }
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
        // Center(
        //   child: Wrap(
        //     spacing: 4,
        //     runSpacing: 4,
        //     children: [
        //       for (var i in data)
        //         Row(
        //           children: [
        //             Container(
        //               decoration: BoxDecoration(
        //                 color: ColorUtil.random(i.v1),
        //                 shape: BoxShape.circle,
        //               ),
        //               height: 10,
        //               width: 10,
        //             ),
        //             const SizedBox(width: 4),
        //             Expanded(child: Text(i.v1, style: TextStyle(fontSize: 10))),
        //           ],
        //         ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}
