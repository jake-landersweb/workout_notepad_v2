import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/components/blur_if_not_subscription.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/close_button.dart';
import 'package:workout_notepad_v2/components/cupertino_sheet.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/components/loading_indicator.dart';
import 'package:workout_notepad_v2/components/wrapped_button.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder_date.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder_item.dart';
import 'package:workout_notepad_v2/data/root.dart';

import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/image.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/exercises/logs/el_overview_v2.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_range_picker.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_renderer.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:flutter_animate/flutter_animate.dart';

class ExerciseDetail extends StatefulWidget {
  const ExerciseDetail({
    super.key,
    this.exercise,
    this.exerciseId,
    this.showEdit = true,
  });
  final Exercise? exercise;
  final String? exerciseId;
  final bool showEdit;

  @override
  State<ExerciseDetail> createState() => _ExerciseDetailState();
}

class _ExerciseDetailState extends State<ExerciseDetail> {
  AppFile? _file;
  Exercise? _exercise;
  bool _loading = true;
  bool _err = false;

  late List<Key> _keys;

  @override
  void initState() {
    assert(widget.exercise != null || widget.exerciseId != null,
        "BOTH CANNOT BE NULL");
    if (widget.exercise != null) {
      _exercise = widget.exercise;
    }
    _keys = _generateKeys();
    _init();
    super.initState();
    print("exerciseId: ${widget.exercise?.exerciseId}");
  }

  Future<void> _init() async {
    try {
      if (_exercise == null) {
        var db = await DatabaseProvider().database;
        var response = await db.rawQuery(
            "SELECT * FROM exercise WHERE exerciseId = ?", [widget.exerciseId]);
        if (response.isEmpty) {
          setState(() {
            _err = true;
          });
          return;
        }
        _exercise = Exercise.fromJson(response[0]);
      }
      setState(() {
        _loading = false;
      });
      if (_exercise!.filename?.isNotEmpty ?? false) {
        _file = await AppFile.fromFilename(filename: _exercise!.filename!);
        setState(() {});
      }
    } catch (e) {
      print(e);
      NewrelicMobile.instance.recordError(
        e,
        StackTrace.current,
        attributes: {"err_code": "exercise_detail_render"},
      );
      setState(() {
        _err = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GraphRangeProvider(
          date: LogBuilderDate(dateRangeType: LBDateRange.MONTH)),
      builder: (context, _) {
        return _build(context);
        // return _body(context);
      },
    );
  }

  Widget _build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);

    return HeaderBar.sheet(
      // title: _exercise?.title ?? "Loading",
      title: "",
      crossAxisAlignment: CrossAxisAlignment.center,
      isFluid: false,
      itemSpacing: 16,
      horizontalSpacing: 0,
      leading: const [comp.CloseButton2()],
      trailing: [
        if (widget.showEdit)
          comp.EditButton(
            onTap: () {
              comp.cupertinoSheet(
                context: context,
                builder: (context) => CEERoot(
                  isCreate: false,
                  exercise: widget.exercise,
                  onAction: (_) {
                    // close the detail screen
                    Navigator.of(context).pop();
                  },
                ),
              );
            },
          )
      ],
      children: [
        _body(context, dmodel),
      ],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    if (_err) {
      return const Center(
        child: Text("There was an unknown issue"),
      );
    } else if (_loading) {
      return Center(
        child: LoadingIndicator(
          color: dmodel.color,
        ),
      );
    } else if (_exercise == null) {
      return const Center(
        child: Text("There was an unknown issue"),
      );
    } else {
      return _content(context, dmodel, _exercise!);
    }
  }

  Widget _content(BuildContext context, DataModel dmodel, Exercise e) {
    var graphRange = context.select(
      (GraphRangeProvider value) => value.getDate,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (e.category.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CategoryCell(
                          categoryId: e.category,
                          backgroundColor: AppColors.cell(context),
                        ),
                      ),
                    if (e.difficulty.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.cell(context)[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          height: 32,
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                e.difficulty.toUpperCase(),
                                style: ttcaption(context, color: dmodel.color),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (_file != null && _file?.type != AppFileType.none)
                Clickable(
                  onTap: () {
                    cupertinoSheet(
                      context: context,
                      builder: (context) => HeaderBar.sheet(
                        title: "",
                        leading: [CloseButton2()],
                        children: [
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 16, 16, 16),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: _file!.getRenderer(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cell(context),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      LineIcons.photoVideo,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _exercise?.title ?? "",
                  style: ttTitle(context, size: 24),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (e.description.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Text(e.description, style: ttLabel(context)),
            ),
          ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ExerciseItemGoup(exercise: e),
        )
            .animate(delay: (50 * 2).ms)
            .slideY(
                begin: 0.25,
                curve: Sprung(36),
                duration: const Duration(milliseconds: 500))
            .fadeIn(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: GraphRangeView(
            date: graphRange,
            onSave: ((_, date) {
              setState(() {
                context.read<GraphRangeProvider>().setDate(date);
                _keys = _generateKeys();
              });
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GraphRenderer(
            key: _keys[0],
            date: graphRange,
            logBuilder: _mainStatPanel(context, dmodel, e),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            _actions(context, dmodel, e),
          ],
        ),
      ],
    );
  }

  LogBuilder _mainStatPanel(
      BuildContext context, DataModel dmodel, Exercise e) {
    switch (e.type) {
      case ExerciseType.weight:
        return LogBuilder(
          title: "Avg Weight",
          items: [
            LogBuilderItem(
              addition: LBIAddition.AND,
              column: LBIColumn.EXERCISE_ID,
              modifier: LBIModifier.EQUALS,
              values: e.exerciseId,
            )
          ],
          column: LBColumn.WEIGHT,
          grouping: LBGrouping.DATE,
          condensing: LBCondensing.AVERAGE,
          graphType: LBGraphType.TIMESERIES,
          showLegend: true,
          showXAxis: true,
          showYAxis: true,
          showTitle: true,
          // backgroundColor: Colors.black,
          // color: Colors.white,
        );
      case ExerciseType.timed:
      case ExerciseType.duration:
        return LogBuilder(
          title: "Avg Time",
          items: [
            LogBuilderItem(
              addition: LBIAddition.AND,
              column: LBIColumn.EXERCISE_ID,
              modifier: LBIModifier.EQUALS,
              values: e.exerciseId,
            )
          ],
          column: LBColumn.TIME,
          grouping: LBGrouping.DATE,
          condensing: LBCondensing.AVERAGE,
          graphType: LBGraphType.TIMESERIES,
          showLegend: true,
          showXAxis: true,
          showYAxis: true,
          showTitle: true,
        );
      default:
        return LogBuilder(
          title: "Avg Reps",
          items: [
            LogBuilderItem(
              addition: LBIAddition.AND,
              column: LBIColumn.EXERCISE_ID,
              modifier: LBIModifier.EQUALS,
              values: e.exerciseId,
            )
          ],
          column: LBColumn.REPS,
          grouping: LBGrouping.DATE,
          condensing: LBCondensing.AVERAGE,
          graphType: LBGraphType.TIMESERIES,
          showLegend: true,
          showXAxis: true,
          showYAxis: true,
          showTitle: true,
        );
    }
  }

  List<Key> _generateKeys() {
    const uuid = Uuid();
    return [
      ValueKey(uuid.v4()),
    ];
  }

  Widget _actions(BuildContext context, DataModel dmodel, Exercise e) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _actionCell(
              context: context,
              icon: Icons.sticky_note_2_rounded,
              title: "View Graphs",
              description: "View graph dashboard",
              onTap: () {
                cupertinoSheet(
                  context: context,
                  builder: (context) => BlurIfNotSubscription(
                    child: ElOverviewV2(exercise: e),
                  ),
                );
              },
              index: 2,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _actionCell(
              context: context,
              icon: Icons.data_array,
              title: "Raw Data",
              description: "View the raw log data",
              onTap: () {
                showMaterialModalBottomSheet(
                  context: context,
                  enableDrag: true,
                  builder: (context) => ExerciseLogs(exerciseId: e.exerciseId),
                );
              },
              index: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCell({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required int index,
  }) {
    final bgColor = AppColors.cell(context);
    final textColor = AppColors.text(context);
    final iconColor = Theme.of(context).colorScheme.primary;
    return Clickable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        constraints: BoxConstraints(
          // maxWidth: MediaQuery.of(context).size.width / 2.5,
          minHeight: MediaQuery.of(context).size.width / 3,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: iconColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: ttLabel(
                  context,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: ttBody(
                  context,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (25 * index).ms)
        .slideX(
            begin: 0.25,
            curve: Sprung(36),
            duration: const Duration(milliseconds: 500))
        .fadeIn();
  }
}
