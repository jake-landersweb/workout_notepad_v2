import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
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

    var response = await db
        .rawQuery("SELECT * FROM workout_log ORDER BY created DESC LIMIT 1");
    if (response.isNotEmpty) {
      _wl = await WorkoutLog.fromJson(response[0]);
    }

    setState(() {
      _isLoading = false;
    });
    //
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
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cell(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: _body(context),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }
    if (_wl == null) {
      return Center(
        child: Text("No information available.", style: ttcaption(context)),
      );
    }
    return _view(context, _wl!);
  }

  Widget _view(BuildContext context, WorkoutLog log) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WorkoutLogCellAlt(
            log: log,
            endContent: Container(),
          ),
          const SizedBox(height: 8),
          _cell(
            context,
            _attributeCell(
              context,
              "Duration",
              formatHHMMSS(log.duration),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _cell(
                  context,
                  _attributeCell(
                    context,
                    "Exercises",
                    log.exerciseLogs.length.toString(),
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
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Row(
                  //   children: [
                  //     GraphCircle(
                  //       value: _getNumSetsNotWarmup(log),
                  //     ),
                  //     const SizedBox(width: 16),
                  //     Text("% Working Sets", style: ttLabel(context)),
                  //   ],
                  // ),
                  // const SizedBox(height: 8),
                  Expanded(
                    child: _pieChart(
                      context,
                      "Tag Dist.",
                      _getTagsData(log),
                      expanded: true,
                      showHeader: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

  // double _getNumSetsNotWarmup(WorkoutLog log) {
  //   return log.exerciseLogs.fold(
  //         0,
  //         (previousValue, element) =>
  //             previousValue +
  //             element.fold(
  //               0,
  //               (previousValue, element) =>
  //                   previousValue +
  //                   element.metadata.fold(
  //                     0,
  //                     (previousValue, element) =>
  //                         previousValue +
  //                         (element.tags.firstWhereOrNull(
  //                                     (element) => element.title == "Warmup") ==
  //                                 null
  //                             ? 1
  //                             : 0),
  //                   ),
  //             ),
  //       ) /
  //       _getTotalSets(log);
  // }

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

  Widget _cell(BuildContext context, Widget value, {double height = 60}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cell(context)[300],
        border: Border.all(color: AppColors.divider(context)),
        borderRadius: BorderRadius.circular(10),
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
              fontSize: 32,
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

  Widget _pieChart(
    BuildContext context,
    String title,
    List<Tuple2<String, int>> data, {
    bool showHeader = true,
    bool expanded = false,
  }) {
    Widget content = PieChart(
      PieChartData(
        sections: [
          for (var i in data)
            PieChartSectionData(
              value: i.v2.toDouble(),
              color: ColorUtil.random(i.v1),
              title: "",
            ),
        ],
      ),
    );
    Widget legend = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
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
              Text(i.v1, style: ttcaption(context)),
            ],
          ),
      ],
    );
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
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: content),
                      const SizedBox(width: 16),
                      legend,
                    ],
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 80,
                      width: 80,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            for (var i in data)
                              PieChartSectionData(
                                value: i.v2.toDouble(),
                                color: ColorUtil.random(i.v1),
                                title: "",
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    legend,
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
