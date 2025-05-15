import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/local_prefs.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/color.dart';
import 'package:workout_notepad_v2/utils/tuple.dart';
import 'package:workout_notepad_v2/views/logs/post_workout.dart';
import 'package:workout_notepad_v2/views/workouts/logs/wl_cell_alt.dart';

class PreviousWorkout extends StatefulWidget {
  const PreviousWorkout({super.key});

  @override
  State<PreviousWorkout> createState() => _PreviousWorkoutState();
}

class _PreviousWorkoutState extends State<PreviousWorkout> {
  bool _isLoading = true;
  WorkoutLog? _wl;
  List<int> _weightDistribution = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    var db = await DatabaseProvider().database;
    var localPrefs = context.read<LocalPrefs>();

    var response = await db
        .rawQuery("SELECT * FROM workout_log ORDER BY created DESC LIMIT 1");
    if (response.isNotEmpty) {
      _wl = await WorkoutLog.fromJson(response[0]);
      var logs = await _wl!.getExercises(db: db);
      for (var i in logs!) {
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
        _weightDistribution.add(weight);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Section(
      "Latest Workout",
      trailingWidget: Clickable(
        onTap: () {
          if (_wl != null) {
            cupertinoSheet(
              context: context,
              builder: (context) => PostWorkoutSummary(
                workoutLogId: _wl!.workoutLogId,
                onSave: (v) {},
              ),
            );
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
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }
    if (_wl == null) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            "Hey! If you want information here, you must workout!",
            style: ttcaption(context),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    // return _view2(context, _wl!);
    return _view(context, _wl!);
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

  Widget _weightBySet(
    BuildContext context,
    WorkoutLog log,
  ) {
    var localPrefs = context.watch<LocalPrefs>();
    Widget content = Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              barWidth: 3,
              color: Theme.of(context).colorScheme.primary,
              isCurved: true,
              preventCurveOverShooting: false,
              curveSmoothness: 0.2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (p0, p1, p2, p3) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 0,
                  );
                },
              ),
              spots: [
                for (int i = 0; i < _weightDistribution.length; i++)
                  FlSpot(i + 1, _weightDistribution[i].toDouble())
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
                // items.add(
                //   LineTooltipItem(
                //     "Set #${touchedSpots[0].x.round()}",
                //     ttcaption(context),
                //   ),
                // );
                for (int i = 0; i < touchedSpots.length; i++) {
                  items.add(
                    LineTooltipItem(
                      "Set #${touchedSpots[i].x.round()}\n${touchedSpots[i].y.round()} ${localPrefs.defaultWeightPost}",
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
                  if (_weightDistribution.length > 5) {
                    text = "${value.round()}";
                  } else {
                    text =
                        "${_weightDistribution[value.round() - 1]} ${localPrefs.defaultWeightPost}";
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
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: content),
      ],
    );
  }

  Widget _view(BuildContext context, WorkoutLog log) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WorkoutLogCellAlt(
          log: log,
          endContent: Container(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _cell(
                context,
                _attributeCell(
                  context,
                  "Exercises",
                  (log.exerciseLogs.length > 3
                          ? log.exerciseLogs.length
                          : log.exerciseLogs.flattened.length)
                      .toString(),
                  vertical: true,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _cell(
                context,
                _attributeCell(
                  context,
                  "Sets",
                  _getTotalSets(log).toString(),
                  vertical: true,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _cell(
                context,
                _attributeCell(
                  context,
                  "Reps",
                  _getTotalReps(log).toString(),
                  vertical: true,
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _pieChart(
                    context,
                    "Tag Dist.",
                    _getDynamicPieChartData(log),
                    expanded: true,
                    showHeader: false,
                  ),
                ),
                Expanded(
                  child: _weightBySet(context, log),
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

    late Widget legend;
    if (data.length > 4) {
      legend = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border(context)),
        ),
        height: expanded ? double.infinity : 60,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            childAspectRatio: 2.5,
          ),
          padding: EdgeInsets.symmetric(horizontal: 4),
          itemCount: data.length,
          itemBuilder: (context, index) {
            return Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: ColorUtil.random(data[index].v1),
                    shape: BoxShape.circle,
                  ),
                  height: 10,
                  width: 10,
                ),
                const SizedBox(width: 4),
                Expanded(
                    child: Text(data[index].v1, style: ttcaption(context))),
              ],
            );
          },
        ),
      );
    } else {
      legend = SizedBox(
        height: expanded ? double.infinity : 60,
        child: Center(
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (var i in data)
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: ColorUtil.random(i.v1),
                        shape: BoxShape.circle,
                      ),
                      height: 10,
                      width: 10,
                    ),
                    const SizedBox(width: 4),
                    Expanded(child: Text(i.v1, style: ttcaption(context))),
                  ],
                ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cell(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title, style: ttcaption(context)),
            ),
          if (expanded)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(flex: 1, child: content),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: legend),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 80, width: 80, child: content),
                  const SizedBox(width: 16),
                  Flexible(child: legend),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
