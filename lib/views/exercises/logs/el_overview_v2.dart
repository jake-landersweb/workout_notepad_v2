import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/components/expanded_page_view.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder_date.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder_item.dart';
import 'package:workout_notepad_v2/utils/color.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_range_picker.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_renderer.dart';

class ElOverviewV2 extends StatefulWidget {
  const ElOverviewV2({
    super.key,
    required this.exercise,
    this.colorOverride,
  });
  final Exercise exercise;
  final Color? colorOverride;

  @override
  State<ElOverviewV2> createState() => ElOverviewV2State();
}

class ElOverviewV2State extends State<ElOverviewV2> {
  late List<Key> _keys;
  late LogBuilderItem _defaultCondition;
  late LBWeightNormalization _weightNormalization;

  @override
  void initState() {
    _defaultCondition = LogBuilderItem(
      column: LBIColumn.EXERCISE_ID,
      modifier: LBIModifier.EQUALS,
      values: widget.exercise.exerciseId,
    );
    _keys = _generateKeys();
    _weightNormalization = LBWeightNormalization.LBS;
    super.initState();
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
    var range = context.select(
      (GraphRangeProvider value) => value.getDate,
    );

    return HeaderBar.sheet(
      title: widget.exercise.title,
      leading: [CloseButton2()],
      horizontalSpacing: 0,
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: GraphRangeView(
                date: range,
                onSave: ((_, date) {
                  setState(() {
                    context.read<GraphRangeProvider>().setDate(date);
                    _keys = _generateKeys();
                  });
                }),
              ),
            ),
            if (widget.exercise.type == ExerciseType.weight)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedPicker(
                  titles: ["lbs", "kg"],
                  style: SegmentedPickerStyle(
                    height: 45,
                    backgroundColor: AppColors.cell(context),
                  ),
                  onSelection: (val) {
                    setState(() {
                      _weightNormalization = val;
                      _keys = _generateKeys();
                    });
                  },
                  selections: LBWeightNormalization.values,
                  selection: _weightNormalization,
                ),
              ),
            Section(
              "Metrics Over Time",
              key: _keys[0],
              allowsCollapse: true,
              initOpen: true,
              headerPadding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.exercise.type == ExerciseType.weight)
                    CustomPageView(
                      duration: Duration.zero,
                      childHorizontalPadding: 16,
                      children: [
                        GraphRenderer(
                          logBuilder: LogBuilder(
                            weightNormalization: _weightNormalization,
                            color: widget.colorOverride,
                            title: "Avg Weight Over Time",
                            date: range,
                            grouping: LBGrouping.DATE,
                            condensing: LBCondensing.AVERAGE,
                            graphType: LBGraphType.TIMESERIES,
                            items: [_defaultCondition],
                          ),
                        ),
                        GraphRenderer(
                          logBuilder: LogBuilder(
                            weightNormalization: _weightNormalization,
                            color: widget.colorOverride,
                            title: "Max Weight Over Time",
                            date: range,
                            grouping: LBGrouping.DATE,
                            condensing: LBCondensing.MAX,
                            graphType: LBGraphType.TIMESERIES,
                            items: [_defaultCondition],
                          ),
                        ),
                        GraphRenderer(
                          logBuilder: LogBuilder(
                            weightNormalization: _weightNormalization,
                            color: widget.colorOverride,
                            title: "Min Weight Over Time",
                            date: range,
                            grouping: LBGrouping.DATE,
                            condensing: LBCondensing.MIN,
                            graphType: LBGraphType.TIMESERIES,
                            items: [_defaultCondition],
                          ),
                        ),
                      ],
                    )
                  else if ([ExerciseType.duration, ExerciseType.timed]
                      .contains(widget.exercise.type))
                    CustomPageView(
                      duration: Duration.zero,
                      childHorizontalPadding: 16,
                      children: [
                        GraphRenderer(
                          logBuilder: LogBuilder(
                            weightNormalization: _weightNormalization,
                            color: widget.colorOverride,
                            title: "Avg Duration Over Time",
                            date: range,
                            grouping: LBGrouping.DATE,
                            condensing: LBCondensing.AVERAGE,
                            graphType: LBGraphType.TIMESERIES,
                            column: LBColumn.TIME,
                            items: [_defaultCondition],
                          ),
                        ),
                        GraphRenderer(
                          logBuilder: LogBuilder(
                            weightNormalization: _weightNormalization,
                            color: widget.colorOverride,
                            title: "Max Duration Over Time",
                            date: range,
                            grouping: LBGrouping.DATE,
                            condensing: LBCondensing.MAX,
                            graphType: LBGraphType.TIMESERIES,
                            column: LBColumn.TIME,
                            items: [_defaultCondition],
                          ),
                        ),
                        GraphRenderer(
                          logBuilder: LogBuilder(
                            weightNormalization: _weightNormalization,
                            color: widget.colorOverride,
                            title: "Min Duration Over Time",
                            date: range,
                            grouping: LBGrouping.DATE,
                            condensing: LBCondensing.MIN,
                            graphType: LBGraphType.TIMESERIES,
                            column: LBColumn.TIME,
                            items: [_defaultCondition],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 32),
                  CustomPageView(
                    duration: Duration.zero,
                    childHorizontalPadding: 16,
                    children: [
                      GraphRenderer(
                        logBuilder: LogBuilder(
                          weightNormalization: _weightNormalization,
                          color: widget.colorOverride,
                          title: "Avg Reps Over Time",
                          date: range,
                          grouping: LBGrouping.DATE,
                          condensing: LBCondensing.AVERAGE,
                          graphType: LBGraphType.TIMESERIES,
                          column: LBColumn.REPS,
                          items: [_defaultCondition],
                        ),
                      ),
                      GraphRenderer(
                        logBuilder: LogBuilder(
                          weightNormalization: _weightNormalization,
                          color: widget.colorOverride,
                          title: "Max Reps Over Time",
                          date: range,
                          grouping: LBGrouping.DATE,
                          condensing: LBCondensing.MAX,
                          graphType: LBGraphType.TIMESERIES,
                          column: LBColumn.REPS,
                          items: [_defaultCondition],
                        ),
                      ),
                      GraphRenderer(
                        logBuilder: LogBuilder(
                          weightNormalization: _weightNormalization,
                          color: widget.colorOverride,
                          title: "Min Reps Over Time",
                          date: range,
                          grouping: LBGrouping.DATE,
                          condensing: LBCondensing.MIN,
                          graphType: LBGraphType.TIMESERIES,
                          column: LBColumn.REPS,
                          items: [_defaultCondition],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Section(
              "Metrics Over Sets",
              key: _keys[1],
              allowsCollapse: true,
              initOpen: true,
              headerPadding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.exercise.type == ExerciseType.weight)
                    CustomPageView(
                      duration: Duration.zero,
                      childHorizontalPadding: 16,
                      children: [
                        GraphRenderer(
                          logBuilder: LogBuilder(
                            weightNormalization: _weightNormalization,
                            color: widget.colorOverride,
                            title: "Avg Weight Over Set",
                            date: range,
                            grouping: LBGrouping.SET,
                            condensing: LBCondensing.AVERAGE,
                            graphType: LBGraphType.BAR,
                            items: [_defaultCondition],
                          ),
                        ),
                        GraphRenderer(
                          logBuilder: LogBuilder(
                            weightNormalization: _weightNormalization,
                            color: widget.colorOverride,
                            title: "Max Weight Over Set",
                            date: range,
                            grouping: LBGrouping.SET,
                            condensing: LBCondensing.MAX,
                            graphType: LBGraphType.BAR,
                            items: [_defaultCondition],
                          ),
                        ),
                        GraphRenderer(
                          logBuilder: LogBuilder(
                            weightNormalization: _weightNormalization,
                            color: widget.colorOverride,
                            title: "Min Weight Over Set",
                            date: range,
                            grouping: LBGrouping.SET,
                            condensing: LBCondensing.MIN,
                            graphType: LBGraphType.BAR,
                            items: [_defaultCondition],
                          ),
                        ),
                      ],
                    )
                  else if ([ExerciseType.duration, ExerciseType.timed]
                      .contains(widget.exercise.type))
                    CustomPageView(
                      duration: Duration.zero,
                      childHorizontalPadding: 16,
                      children: [
                        GraphRenderer(
                          logBuilder: LogBuilder(
                            weightNormalization: _weightNormalization,
                            color: widget.colorOverride,
                            title: "Avg Duration Over Set",
                            date: range,
                            grouping: LBGrouping.SET,
                            condensing: LBCondensing.AVERAGE,
                            graphType: LBGraphType.BAR,
                            column: LBColumn.TIME,
                            items: [_defaultCondition],
                          ),
                        ),
                        GraphRenderer(
                          logBuilder: LogBuilder(
                            weightNormalization: _weightNormalization,
                            color: widget.colorOverride,
                            title: "Max Duration Over Set",
                            date: range,
                            grouping: LBGrouping.SET,
                            condensing: LBCondensing.MAX,
                            graphType: LBGraphType.BAR,
                            column: LBColumn.TIME,
                            items: [_defaultCondition],
                          ),
                        ),
                        GraphRenderer(
                          logBuilder: LogBuilder(
                            weightNormalization: _weightNormalization,
                            color: widget.colorOverride,
                            title: "Min Duration Over SET",
                            date: range,
                            grouping: LBGrouping.SET,
                            condensing: LBCondensing.MIN,
                            graphType: LBGraphType.BAR,
                            column: LBColumn.TIME,
                            items: [_defaultCondition],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 32),
                  CustomPageView(
                    duration: Duration.zero,
                    childHorizontalPadding: 16,
                    children: [
                      GraphRenderer(
                        logBuilder: LogBuilder(
                          weightNormalization: _weightNormalization,
                          color: widget.colorOverride,
                          title: "Avg Reps Over Set",
                          date: range,
                          grouping: LBGrouping.SET,
                          condensing: LBCondensing.AVERAGE,
                          graphType: LBGraphType.BAR,
                          column: LBColumn.REPS,
                          items: [_defaultCondition],
                        ),
                      ),
                      GraphRenderer(
                        logBuilder: LogBuilder(
                          weightNormalization: _weightNormalization,
                          color: widget.colorOverride,
                          title: "Max Reps Over Set",
                          date: range,
                          grouping: LBGrouping.SET,
                          condensing: LBCondensing.MAX,
                          graphType: LBGraphType.BAR,
                          column: LBColumn.REPS,
                          items: [_defaultCondition],
                        ),
                      ),
                      GraphRenderer(
                        logBuilder: LogBuilder(
                          weightNormalization: _weightNormalization,
                          color: widget.colorOverride,
                          title: "Min Reps Over Set",
                          date: range,
                          grouping: LBGrouping.SET,
                          condensing: LBCondensing.MIN,
                          graphType: LBGraphType.BAR,
                          column: LBColumn.REPS,
                          items: [_defaultCondition],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Section(
              "Advanced Metrics",
              key: _keys[2],
              allowsCollapse: true,
              initOpen: true,
              headerPadding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomPageView(
                    duration: Duration.zero,
                    childHorizontalPadding: 16,
                    children: [
                      GraphRenderer(
                        logBuilder: LogBuilder(
                          weightNormalization: _weightNormalization,
                          color: widget.colorOverride,
                          title: "Tag Distribution",
                          date: range,
                          grouping: LBGrouping.TAG,
                          condensing: LBCondensing.COUNT,
                          graphType: LBGraphType.PIE,
                          column: LBColumn.REPS,
                          items: [_defaultCondition],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ],
    );
  }

  List<Key> _generateKeys() {
    const uuid = Uuid();
    return [
      ValueKey(uuid.v4()),
      ValueKey(uuid.v4()),
      ValueKey(uuid.v4()),
    ];
  }
}
