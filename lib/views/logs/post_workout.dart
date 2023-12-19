import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/model/getDB.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/exercises/category_cell.dart';
import 'package:workout_notepad_v2/views/exercises/logs/el_cell.dart';
import 'package:share_plus/share_plus.dart';
import 'package:workout_notepad_v2/views/workouts/logs/wl_edit.dart';
import 'dart:math' as math;

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

  WorkoutSummaryModel({required this.wl}) {
    setData();
  }

  void setData() {
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
    totalWeight = wl.exerciseLogs
        .map((v1) => v1
            .map((v2) => v2.metadata.map((v3) => v3.weight * v3.reps).sum)
            .sum)
        .sum;

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
        weight += j.metadata.map((e) => e.weight).sum;

        // categories
        categories.add(j.category);
      }
      weightDistribution.add(weight);
    }

    // compose categories
    categories = categories.toSet().toList();
  }
}

enum _LoadingType { none, standard, square, full }

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
  _LoadingType _loadingType = _LoadingType.none;
  bool _refresh = false;

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderBar.sheet(
      title: "Summary",
      leading: const [CloseButton2()],
      trailing: [
        Clickable(
          onTap: () async {
            showModalBottomSheet(
              context: context,
              builder: (context) => Container(
                color: AppColors.background(context),
                width: double.infinity,
                child: SafeArea(
                  top: false,
                  bottom: true,
                  child: SizedBox(
                    height: 100,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        children: [
                          _exportCell(
                            context,
                            Icons.crop_square_rounded,
                            "Square",
                            _LoadingType.square,
                          ),
                          _exportCell(
                            context,
                            Icons.crop_portrait,
                            "Rect",
                            _LoadingType.standard,
                          ),
                          // _exportCell(
                          //   context,
                          //   Icons.crop_16_9_rounded,
                          //   "Full",
                          //   _LoadingType.full,
                          //   angle: math.pi / 2,
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          child: _loadingType != _LoadingType.none
              ? LoadingIndicator(color: Theme.of(context).colorScheme.primary)
              : Icon(
                  Icons.ios_share_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
        ),
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
                      await Future.delayed(const Duration(milliseconds: 50));
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
    );
  }

  Widget _body(BuildContext context, WorkoutLog wl) {
    return ChangeNotifierProvider(
      create: (context) => WorkoutSummaryModel(wl: wl),
      builder: (context, child) => _content(context),
    );
  }

  Widget _content(BuildContext context) {
    var model = Provider.of<WorkoutSummaryModel>(context);
    if (_refresh) {
      _refresh = false;
      model.wl = _workoutLog!;
      model.setData();
    }
    return RepaintBoundary(
      key: _reportKey,
      child: _loadingType == _LoadingType.square
          ? _squareContent(context, model)
          : Container(
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
                              "Total lbs",
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
                                child: Text("Categories",
                                    style: ttcaption(context)),
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
                                      CategoryCell(
                                          categoryId: model.categories[i])
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
                        child: _pieChart(context, "Exercise Type Dist.",
                            model.exerciseTypes),
                      ),
                    if (_loadingType == _LoadingType.full ||
                        _loadingType == _LoadingType.none)
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
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 0, 8, 8),
                                          child: Section(
                                            j.title,
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
            ),
    );
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
              spots: [
                for (int i = 0; i < model.weightDistribution.length; i++)
                  FlSpot(i + 1, model.weightDistribution[i].toDouble())
              ],
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              tooltipBgColor: AppColors.cell(context),
              getTooltipItems: (touchedSpots) {
                List<LineTooltipItem> items = [];
                items.add(
                  LineTooltipItem(
                    "Set #${touchedSpots[0].x.round()}",
                    ttcaption(context),
                  ),
                );
                for (var i in touchedSpots) {
                  items.add(
                    LineTooltipItem(
                      "${i.y.round()} lbs",
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

  Widget _exportCell(
      BuildContext context, IconData icon, String title, _LoadingType lt,
      {double angle = 0}) {
    return Expanded(
      child: Clickable(
        onTap: () async {
          setState(() {
            _loadingType = lt;
          });
          await _share(context);
          setState(() {
            _loadingType = _LoadingType.none;
          });
          Navigator.of(context).pop();
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cell(context),
          ),
          height: double.infinity,
          width: double.infinity,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.rotate(
                  angle: angle,
                  child: Icon(
                    icon,
                    size: 32,
                    color: AppColors.subtext(context),
                  ),
                ),
                Text(title, style: ttcaption(context)),
              ],
            ),
          ),
        ),
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
      final result =
          await Share.shareXFiles([XFile(path)], text: 'Look at my workout!');
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
