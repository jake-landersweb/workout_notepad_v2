import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/env.dart';
import 'package:workout_notepad_v2/model/getDB.dart';
import 'package:workout_notepad_v2/model/local_prefs.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/exercises/category_cell.dart';
import 'package:workout_notepad_v2/views/exercises/logs/el_cell.dart';
import 'package:share_plus/share_plus.dart';
import 'package:workout_notepad_v2/views/workouts/logs/wl_edit.dart';

class WorkoutSummaryModel extends ChangeNotifier {
  late WorkoutLog wl;

  // statis data
  late String duration;
  late int totalExercises;
  late int totalSets;
  late int totalReps;
  late int totalWeight;

  // graphs
  List<Tuple2<String, int>> tags = [];
  List<Tuple2<String, int>> exerciseTypes = [];
  List<int> weightDistribution = [];
  List<String> categories = [];

  WorkoutSummaryModel({required BuildContext context, required this.wl}) {
    setData(context);
  }

  void setData(BuildContext context) {
    var localPrefs = context.read<LocalPrefs>();
    tags = [];
    exerciseTypes = [];
    weightDistribution = [];
    categories = [];
    duration = formatHHMMSS(wl.duration);
    totalExercises = wl.exerciseLogs.length;

    totalSets =
        wl.exerciseLogs.map((v1) => v1.map((v2) => v2.metadata.length).sum).sum;

    totalReps = wl.exerciseLogs
        .map((v1) => v1.map((v2) => v2.metadata.map((v3) => v3.reps).sum).sum)
        .sum;

    // calculated later
    totalWeight = 0;

    for (var i in wl.exerciseLogs) {
      var weight = 0;
      for (var j in i) {
        // create type list
        var tmpType = exerciseTypes.firstWhereOrNull(
            (element) => element.v1 == exerciseTypeTitle(j.type));
        if (tmpType == null) {
          exerciseTypes.add(Tuple2(exerciseTypeTitle(j.type), 1));
        } else {
          tmpType.v2 += 1;
        }

        // create tag list
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

        // total weight
        if (j.metadata.isNotEmpty) {
          if (localPrefs.defaultWeightPost == "lbs") {
            if (j.metadata[0].weightPost == "lbs") {
              weight += j.metadata.map((e) => e.weight).sum;
            } else {
              weight +=
                  (j.metadata.map((e) => e.weight).sum * KG_TO_LBS_CONVERSTION)
                      .toInt();
            }
          } else {
            if (j.metadata[0].weightPost == "lbs") {
              weight +=
                  (j.metadata.map((e) => e.weight).sum / KG_TO_LBS_CONVERSTION)
                      .toInt();
            } else {
              weight += j.metadata.map((e) => e.weight).sum;
            }
          }
        }

        // categories
        categories.add(j.category);
      }
      weightDistribution.add(weight);
      totalWeight += weight;
    }

    // compose categories
    categories = categories.toSet().toList();
  }
}

enum _ViewType { full, square }

class PostWorkoutSummary extends StatefulWidget {
  const PostWorkoutSummary({
    super.key,
    required this.workoutLogId,
    this.onSave,
  });
  final String workoutLogId;
  final void Function(WorkoutLog wl)? onSave;

  @override
  State<PostWorkoutSummary> createState() => _PostWorkoutSummaryState();
}

class _PostWorkoutSummaryState extends State<PostWorkoutSummary> {
  WorkoutLog? _workoutLog;
  final GlobalKey _reportKey = GlobalKey();
  bool _isLoading = false;
  _ViewType _viewType = _ViewType.full;
  bool _refresh = false;

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(onGenerateRoute: (RouteSettings settings) {
      return MaterialPageRoute(builder: (context) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            HeaderBar.sheet(
              title: "Summary",
              leading: const [CloseButton2(useRoot: true)],
              trailing: [
                if (widget.onSave != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: EditButton(onTap: () {
                      cupertinoSheet(
                        context: context,
                        builder: (context) => WLEdit(
                            wl: _workoutLog!,
                            onSave: (v) async {
                              widget.onSave!(v);
                              await _init();
                              await Future.delayed(
                                  const Duration(milliseconds: 50));
                              setState(() {
                                _refresh = true;
                              });
                            }),
                      );
                    }),
                  )
              ],
              horizontalSpacing: 0,
              children: [
                if (_workoutLog != null) _body(context, _workoutLog!),
              ],
            ),
            // action buttons
            Padding(
              padding: EdgeInsets.fromLTRB(
                  8, 0, 8, MediaQuery.of(context).padding.bottom + 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Clickable(
                    onTap: () {
                      if (_viewType == _ViewType.full) {
                        setState(() {
                          _viewType = _ViewType.square;
                        });
                      } else {
                        setState(() {
                          _viewType = _ViewType.full;
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.cell(context)[100],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 5,
                            blurRadius: 7,
                          ),
                        ],
                      ),
                      height: MediaQuery.of(context).size.width * 0.15,
                      width: MediaQuery.of(context).size.width * 0.15,
                      child: Center(
                        child: Icon(_viewType == _ViewType.square
                            ? Icons.crop_square_rounded
                            : Icons.crop_portrait),
                      ),
                    ),
                  ),
                  Clickable(
                    onTap: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      await _share(context);
                      setState(() {
                        _isLoading = false;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 5,
                            blurRadius: 7,
                          ),
                        ],
                      ),
                      height: MediaQuery.of(context).size.width * 0.15,
                      width: MediaQuery.of(context).size.width * 0.15,
                      child: Center(
                        child: _isLoading
                            ? LoadingIndicator(color: Colors.white)
                            : Padding(
                                padding: EdgeInsets.only(bottom: 3.0),
                                child: Icon(
                                  Icons.ios_share_rounded,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      });
    });
  }

  Widget _body(BuildContext context, WorkoutLog wl) {
    return ChangeNotifierProvider(
      create: (context) => WorkoutSummaryModel(context: context, wl: wl),
      builder: (context, child) => _content(context),
    );
  }

  Widget _content(BuildContext context) {
    var model = Provider.of<WorkoutSummaryModel>(context);
    if (_refresh) {
      _refresh = false;
      model.wl = _workoutLog!;
      model.setData(context);
    }
    return RepaintBoundary(
      key: _reportKey,
      child: _view(context, model),
    );
  }

  Widget _view(BuildContext context, WorkoutSummaryModel model) {
    var localPrefs = context.watch<LocalPrefs>();
    switch (_viewType) {
      case _ViewType.full:
        return Container(
          color: AppColors.background(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(model.wl.title, style: ttTitle(context, size: 32)),
                const SizedBox(height: 8),
                Column(
                  children: [
                    _cell(
                      context,
                      _attributeCell(
                        context,
                        "Total Time",
                        model.duration,
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
                              model.totalExercises.toString(),
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
                              model.totalSets.toString(),
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
                              model.totalReps.toString(),
                              vertical: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (model.totalWeight > 0)
                      _cell(
                        context,
                        _attributeCell(
                          context,
                          "Total ${localPrefs.defaultWeightPost}",
                          model.totalWeight.toString(),
                        ),
                      ),
                  ],
                ),
                // categories
                if (model.categories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.cell(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                Text("Categories", style: ttcaption(context)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (int i = 0;
                                    i < model.categories.length;
                                    i++)
                                  CategoryCell(categoryId: model.categories[i])
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (model.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _pieChart(context, "Tag Dist.", model.tags),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _weightBySet(context, model),
                ),
                if (model.exerciseTypes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _pieChart(
                        context, "Exercise Type Dist.", model.exerciseTypes),
                  ),
                if (!_isLoading)
                  Section(
                    "Raw Logs",
                    child: Column(
                      children: [
                        for (var i in model.wl.exerciseLogs)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.cell(context),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  for (var j in i)
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                      child: Section(
                                        j.title,
                                        headerPadding:
                                            const EdgeInsets.fromLTRB(
                                                0, 8, 0, 8),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.cell(context),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ELCell(
                                                log: j,
                                                showDate: false,
                                                // backgroundColor: AppColors.cell(context)[50],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  const SizedBox(height: 16),
              ],
            ),
          ),
        );
      case _ViewType.square:
        return _squareContent(context, model);
    }
  }

  Widget _squareContent(BuildContext context, WorkoutSummaryModel model) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        color: AppColors.background(context),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(model.wl.title, style: ttTitle(context, size: 24)),
              const SizedBox(height: 8),
              Expanded(
                child: _cell(
                  context,
                  _attributeCell(context, "Total Time", model.duration),
                  height: double.infinity,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _cell(
                        context,
                        _attributeCell(
                          context,
                          "Exercises",
                          model.totalExercises.toString(),
                          vertical: true,
                        ),
                        height: double.infinity,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 2,
                      child: _cell(
                        context,
                        _pieChart(
                          context,
                          "Tag Dist.",
                          model.tags,
                          showHeader: false,
                          expanded: true,
                        ),
                        height: double.infinity,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _cell(
                        context,
                        _weightBySet(
                          context,
                          model,
                          showHeader: false,
                          expanded: true,
                        ),
                        height: double.infinity,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 1,
                      child: _cell(
                        context,
                        _attributeCell(
                          context,
                          "Sets",
                          model.totalSets.toString(),
                          vertical: true,
                        ),
                        height: double.infinity,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cell(BuildContext context, Widget value, {double height = 75}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cell(context),
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
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
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
                    mainAxisSize: MainAxisSize.min,
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
                      height: 100,
                      width: 100,
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

  Widget _weightBySet(
    BuildContext context,
    WorkoutSummaryModel model, {
    bool showHeader = true,
    bool expanded = false,
  }) {
    Widget content = Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
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
                for (int i = 0; i < model.weightDistribution.length; i++)
                  FlSpot(i + 1, model.weightDistribution[i].toDouble())
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
                for (var i in touchedSpots) {
                  items.add(
                    LineTooltipItem(
                      "Set #${i.x.round()}\n${i.y.round()} lbs",
                      ttBody(
                        context,
                        color: i.bar.color,
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
                  return Text(
                    "${model.weightDistribution[value.round() - 1]}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subtext(context),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
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
              child: Text("Weight by Set", style: ttcaption(context)),
            ),
          if (expanded)
            Expanded(child: content)
          else
            SizedBox(height: 110, child: content),
        ],
      ),
    );
  }

  Future<void> _share(BuildContext context) async {
    File? file;
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_reportKey.currentContext == null) {
        throw "The current context was null";
      }

      // render image
      RenderRepaintBoundary boundary = _reportKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 5);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw "The byteData was null";
      }
      Uint8List pngBytes = byteData.buffer.asUint8List();

      // write to tmp file
      var tmpDir = await getTemporaryDirectory();
      var path = "${tmpDir.path}/sharedWorkout.png";
      file = File(path);
      await file.writeAsBytes(pngBytes);

      // share the file
      final result = await Share.shareXFiles(
        [XFile(path)],
        text: 'My post workout summary from: https://workoutnotepad.co',
      );
      switch (result.status) {
        case ShareResultStatus.success:
          snackbarStatus(context, "Successfully shared your workout.");
          break;
        case ShareResultStatus.dismissed:
          // TODO: Handle this case.
          break;
        case ShareResultStatus.unavailable:
          throw "There was an issue sharing the workout";
      }

      // delete the file
      await file.delete();
    } catch (e, s) {
      print(e);
      print(s);
      snackbarErr(context, "There was an issue sharing your workout");
      if (file != null) {
        await file.delete();
      }
    }
  }

  Future<void> _init() async {
    late WorkoutLog wl;
    var db = await DatabaseProvider().database;
    var response = await db.rawQuery(
        "SELECT * FROM workout_log WHERE workoutLogId = '${widget.workoutLogId}'");
    wl = await WorkoutLog.fromJson(response[0]);

    setState(() {
      _workoutLog = wl;
    });
  }
}
