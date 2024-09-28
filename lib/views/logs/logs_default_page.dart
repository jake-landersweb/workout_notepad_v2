import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/components/expanded_page_view.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder_date.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder_item.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_range_picker.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_renderer.dart';

class DefaultLogPage extends StatefulWidget {
  const DefaultLogPage({
    super.key,
    required this.title,
    required this.defaultCondition,
    this.colorOverride,
  });
  final String title;
  final LogBuilderItem defaultCondition;
  final Color? colorOverride;

  @override
  State<DefaultLogPage> createState() => _DefaultLogPageState();
}

class _DefaultLogPageState extends State<DefaultLogPage> {
  late LogBuilderItem _defaultCondition;
  late List<Key> _keys;
  late LBWeightNormalization _weightNormalization;

  @override
  void initState() {
    _defaultCondition = widget.defaultCondition;
    _weightNormalization = LBWeightNormalization.LBS;
    _keys = _generateKeys();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (context) => GraphRangeProvider(
          date: LogBuilderDate(
            dateRangeType: LBDateRange.MONTH,
            dateRangeModifier: 1,
          ),
          // dateRangeType: LBDateRange.MONTH,
          // dateRangeModifier: 6),
        ),
        builder: ((context, child) => _body(context)),
      ),
    );
  }

  Widget _body(BuildContext context) {
    var range = context.select((GraphRangeProvider value) => value.getDate);
    return HeaderBar(
      title: widget.title.capitalize(),
      horizontalSpacing: 0,
      leading: const [BackButton2()],
      children: [
        Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
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
              "OverView",
              key: _keys[0],
              headerPadding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: CustomPageView(
                duration: Duration.zero,
                childHorizontalPadding: 16,
                children: [
                  GraphRenderer(
                    logBuilder: LogBuilder(
                      weightNormalization: _weightNormalization,
                      color: widget.colorOverride,
                      title: "MAX WEIGHT By EXERCISE",
                      date: range,
                      grouping: LBGrouping.EXERCISE,
                      condensing: LBCondensing.MAX,
                      graphType: LBGraphType.BAR,
                      items: [_defaultCondition],
                    ),
                  ),
                  GraphRenderer(
                    logBuilder: LogBuilder(
                      weightNormalization: _weightNormalization,
                      color: widget.colorOverride,
                      title: "Tag Distribution",
                      date: range,
                      grouping: LBGrouping.TAG,
                      condensing: LBCondensing.COUNT,
                      graphType: LBGraphType.PIE,
                      items: [_defaultCondition],
                    ),
                  ),
                  GraphRenderer(
                    logBuilder: LogBuilder(
                      weightNormalization: _weightNormalization,
                      color: widget.colorOverride,
                      title: "Sets Distribution",
                      date: range,
                      grouping: LBGrouping.EXERCISE,
                      condensing: LBCondensing.COUNT,
                      graphType: LBGraphType.BAR,
                      items: [_defaultCondition],
                    ),
                  ),
                ],
              ),
            ),
            Section(
              "Metrics Over Time",
              key: _keys[1],
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
                  const SizedBox(height: 32),
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
                ],
              ),
            ),
            Section(
              "Stat Panels",
              key: _keys[2],
              allowsCollapse: true,
              initOpen: false,
              headerPadding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: Column(
                children: [
                  CustomPageView(
                    duration: Duration.zero,
                    childHorizontalPadding: 16,
                    children: [
                      GraphRenderer(
                        logBuilder: LogBuilder(
                          weightNormalization: _weightNormalization,
                          color: widget.colorOverride,
                          title: "Max Weight Lifted",
                          date: range,
                          grouping: LBGrouping.NONE,
                          condensing: LBCondensing.MAX,
                          column: LBColumn.WEIGHT,
                          graphType: LBGraphType.PANEL,
                          items: [_defaultCondition],
                        ),
                      ),
                      GraphRenderer(
                        logBuilder: LogBuilder(
                          weightNormalization: _weightNormalization,
                          color: widget.colorOverride,
                          title: "Avg Weight Lifted",
                          date: range,
                          grouping: LBGrouping.NONE,
                          condensing: LBCondensing.AVERAGE,
                          column: LBColumn.WEIGHT,
                          graphType: LBGraphType.PANEL,
                          items: [_defaultCondition],
                        ),
                      ),
                      GraphRenderer(
                        logBuilder: LogBuilder(
                          weightNormalization: _weightNormalization,
                          color: widget.colorOverride,
                          title: "Min Weight Lifted",
                          date: range,
                          grouping: LBGrouping.NONE,
                          condensing: LBCondensing.MIN,
                          column: LBColumn.WEIGHT,
                          graphType: LBGraphType.PANEL,
                          items: [_defaultCondition],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomPageView(
                    duration: Duration.zero,
                    childHorizontalPadding: 16,
                    children: [
                      GraphRenderer(
                        logBuilder: LogBuilder(
                          weightNormalization: _weightNormalization,
                          color: widget.colorOverride,
                          title: "Max Reps",
                          date: range,
                          grouping: LBGrouping.NONE,
                          condensing: LBCondensing.MAX,
                          column: LBColumn.REPS,
                          graphType: LBGraphType.PANEL,
                          items: [_defaultCondition],
                        ),
                      ),
                      GraphRenderer(
                        logBuilder: LogBuilder(
                          weightNormalization: _weightNormalization,
                          color: widget.colorOverride,
                          title: "Avg Reps",
                          date: range,
                          grouping: LBGrouping.NONE,
                          condensing: LBCondensing.AVERAGE,
                          column: LBColumn.REPS,
                          graphType: LBGraphType.PANEL,
                          items: [_defaultCondition],
                        ),
                      ),
                      GraphRenderer(
                        logBuilder: LogBuilder(
                          weightNormalization: _weightNormalization,
                          color: widget.colorOverride,
                          title: "Min Reps",
                          date: range,
                          grouping: LBGrouping.NONE,
                          condensing: LBCondensing.MIN,
                          column: LBColumn.REPS,
                          graphType: LBGraphType.PANEL,
                          items: [_defaultCondition],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomPageView(
                    duration: Duration.zero,
                    childHorizontalPadding: 16,
                    children: [
                      GraphRenderer(
                        logBuilder: LogBuilder(
                          weightNormalization: _weightNormalization,
                          color: widget.colorOverride,
                          title: "Max Duration",
                          date: range,
                          grouping: LBGrouping.NONE,
                          condensing: LBCondensing.MAX,
                          column: LBColumn.TIME,
                          graphType: LBGraphType.PANEL,
                          items: [_defaultCondition],
                        ),
                      ),
                      GraphRenderer(
                        logBuilder: LogBuilder(
                          weightNormalization: _weightNormalization,
                          color: widget.colorOverride,
                          title: "Avg Duration",
                          date: range,
                          grouping: LBGrouping.NONE,
                          condensing: LBCondensing.AVERAGE,
                          column: LBColumn.TIME,
                          graphType: LBGraphType.PANEL,
                          items: [_defaultCondition],
                        ),
                      ),
                      GraphRenderer(
                        logBuilder: LogBuilder(
                          weightNormalization: _weightNormalization,
                          color: widget.colorOverride,
                          title: "Min Duration",
                          date: range,
                          grouping: LBGrouping.NONE,
                          condensing: LBCondensing.MIN,
                          column: LBColumn.TIME,
                          graphType: LBGraphType.PANEL,
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
