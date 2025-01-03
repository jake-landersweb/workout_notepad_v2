import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/components/blur_if_not_subscription.dart';
import 'package:workout_notepad_v2/components/expanded_page_view.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder_date.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_range_picker.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_renderer.dart';

class InsightsHome extends StatefulWidget {
  const InsightsHome({super.key});

  @override
  State<InsightsHome> createState() => _InsightsHomeState();
}

class _InsightsHomeState extends State<InsightsHome> {
  late List<Key> _keys;

  @override
  void initState() {
    _keys = _generateKeys();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GraphRangeProvider(
        date: LogBuilderDate(
          dateRangeType: LBDateRange.MONTH,
          dateRangeModifier: 2,
        ),
      ),
      builder: (context, _) {
        return HeaderBar(
          title: "Insights",
          isLarge: true,
          horizontalSpacing: 0,
          largeTitlePadding: const EdgeInsets.only(left: 16),
          children: [
            const SizedBox(height: 16),
            _body(context),
            const SizedBox(height: 100),
          ],
        );
        // return _body(context);
      },
    );
  }

  Widget _body(BuildContext context) {
    var graphRange = context.select(
      (GraphRangeProvider value) => value.getDate,
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
        Section(
          "By Workout",
          headerPadding: const EdgeInsets.fromLTRB(16, 32, 0, 16),
          child: CustomPageView(
            key: _keys[0],
            duration: Duration.zero,
            childHorizontalPadding: 16,
            children: [
              GraphRenderer(
                date: graphRange,
                logBuilder: LogBuilder(
                  title: "Workout Duration Over Time",
                  items: [],
                  column: LBColumn.WORKOUT_DURATION,
                  grouping: LBGrouping.DATE,
                  condensing: LBCondensing.FIRST,
                  weightNormalization: LBWeightNormalization.KG,
                  graphType: LBGraphType.TIMESERIES,
                  showLegend: true,
                  showXAxis: false,
                  showYAxis: true,
                  // backgroundColor: Colors.black,
                  // color: Colors.white,
                ),
              ),
              GraphRenderer(
                date: graphRange,
                logBuilder: LogBuilder(
                  title: "Sets Per Workout",
                  items: [],
                  column: LBColumn.REPS,
                  grouping: LBGrouping.DATE,
                  condensing: LBCondensing.COUNT,
                  weightNormalization: LBWeightNormalization.KG,
                  graphType: LBGraphType.TIMESERIES,
                  showLegend: true,
                  showXAxis: false,
                  showYAxis: true,
                ),
              ),
              BlurIfNotSubscription(
                child: GraphRenderer(
                  date: graphRange,
                  logBuilder: LogBuilder(
                    title: "Reps Per Workout",
                    items: [],
                    column: LBColumn.REPS,
                    grouping: LBGrouping.DATE,
                    condensing: LBCondensing.SUM,
                    weightNormalization: LBWeightNormalization.KG,
                    graphType: LBGraphType.TIMESERIES,
                    showLegend: true,
                    showXAxis: false,
                    showYAxis: true,
                  ),
                ),
              ),
              BlurIfNotSubscription(
                child: GraphRenderer(
                  date: graphRange,
                  logBuilder: LogBuilder(
                    title: "Weight Lifted Per Workout",
                    items: [],
                    column: LBColumn.WEIGHT,
                    grouping: LBGrouping.DATE,
                    condensing: LBCondensing.SUM,
                    weightNormalization: LBWeightNormalization.KG,
                    graphType: LBGraphType.TIMESERIES,
                    showLegend: true,
                    showXAxis: false,
                    showYAxis: true,
                  ),
                ),
              ),
              BlurIfNotSubscription(
                child: GraphRenderer(
                  date: graphRange,
                  logBuilder: LogBuilder(
                    title: "Cardio Time Per Workout",
                    items: [],
                    column: LBColumn.TIME,
                    grouping: LBGrouping.DATE,
                    condensing: LBCondensing.SUM,
                    weightNormalization: LBWeightNormalization.KG,
                    graphType: LBGraphType.TIMESERIES,
                    showLegend: true,
                    showXAxis: false,
                    showYAxis: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        Section(
          "Category Distributions",
          headerPadding: const EdgeInsets.fromLTRB(16, 32, 0, 16),
          child: CustomPageView(
            key: _keys[1],
            duration: Duration.zero,
            childHorizontalPadding: 16,
            children: [
              GraphRenderer(
                date: graphRange,
                logBuilder: LogBuilder(
                  title: "Sets by Category",
                  items: [],
                  column: LBColumn.REPS,
                  grouping: LBGrouping.CATEGORY,
                  condensing: LBCondensing.COUNT,
                  weightNormalization: LBWeightNormalization.KG,
                  graphType: LBGraphType.SPIDER,
                  showLegend: true,
                  showXAxis: false,
                  showYAxis: true,
                ),
              ),
              BlurIfNotSubscription(
                child: GraphRenderer(
                  date: graphRange,
                  logBuilder: LogBuilder(
                    title: "Reps by Category",
                    items: [],
                    column: LBColumn.REPS,
                    grouping: LBGrouping.CATEGORY,
                    condensing: LBCondensing.SUM,
                    weightNormalization: LBWeightNormalization.KG,
                    graphType: LBGraphType.PIE,
                    showLegend: true,
                    showXAxis: false,
                    showYAxis: true,
                  ),
                ),
              ),
              BlurIfNotSubscription(
                child: GraphRenderer(
                  date: graphRange,
                  logBuilder: LogBuilder(
                    title: "Weight by Category",
                    items: [],
                    column: LBColumn.WEIGHT,
                    grouping: LBGrouping.CATEGORY,
                    condensing: LBCondensing.SUM,
                    weightNormalization: LBWeightNormalization.KG,
                    graphType: LBGraphType.PIE,
                    showLegend: true,
                    showXAxis: false,
                    showYAxis: true,
                  ),
                ),
              ),
              BlurIfNotSubscription(
                child: GraphRenderer(
                  date: graphRange,
                  logBuilder: LogBuilder(
                    title: "Time by Category",
                    items: [],
                    column: LBColumn.TIME,
                    grouping: LBGrouping.CATEGORY,
                    condensing: LBCondensing.SUM,
                    weightNormalization: LBWeightNormalization.KG,
                    graphType: LBGraphType.PIE,
                    showLegend: true,
                    showXAxis: false,
                    showYAxis: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        Section(
          "Tag Distributions",
          headerPadding: const EdgeInsets.fromLTRB(16, 32, 0, 16),
          child: CustomPageView(
            key: _keys[2],
            duration: Duration.zero,
            childHorizontalPadding: 16,
            children: [
              BlurIfNotSubscription(
                child: GraphRenderer(
                  date: graphRange,
                  logBuilder: LogBuilder(
                    title: "Sets By Tag",
                    items: [],
                    column: LBColumn.REPS,
                    grouping: LBGrouping.TAG,
                    condensing: LBCondensing.COUNT,
                    weightNormalization: LBWeightNormalization.KG,
                    graphType: LBGraphType.PIE,
                    showLegend: true,
                    showXAxis: false,
                    showYAxis: true,
                  ),
                ),
              ),
              BlurIfNotSubscription(
                child: GraphRenderer(
                  date: graphRange,
                  logBuilder: LogBuilder(
                    title: "Reps By Tag",
                    items: [],
                    column: LBColumn.REPS,
                    grouping: LBGrouping.TAG,
                    condensing: LBCondensing.SUM,
                    weightNormalization: LBWeightNormalization.KG,
                    graphType: LBGraphType.PIE,
                    showLegend: true,
                    showXAxis: false,
                    showYAxis: true,
                  ),
                ),
              ),
              BlurIfNotSubscription(
                child: GraphRenderer(
                  date: graphRange,
                  logBuilder: LogBuilder(
                    title: "Weight By Tag",
                    items: [],
                    column: LBColumn.WEIGHT,
                    grouping: LBGrouping.TAG,
                    condensing: LBCondensing.SUM,
                    weightNormalization: LBWeightNormalization.KG,
                    graphType: LBGraphType.PIE,
                    showLegend: true,
                    showXAxis: false,
                    showYAxis: true,
                  ),
                ),
              ),
              BlurIfNotSubscription(
                child: GraphRenderer(
                  date: graphRange,
                  logBuilder: LogBuilder(
                    title: "Time By Tag",
                    items: [],
                    column: LBColumn.TIME,
                    grouping: LBGrouping.TAG,
                    condensing: LBCondensing.SUM,
                    weightNormalization: LBWeightNormalization.KG,
                    graphType: LBGraphType.PIE,
                    showLegend: true,
                    showXAxis: false,
                    showYAxis: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        Section(
          "Max Weight",
          headerPadding: const EdgeInsets.fromLTRB(16, 32, 0, 16),
          child: CustomPageView(
            duration: Duration.zero,
            childHorizontalPadding: 16,
            children: [
              BlurIfNotSubscription(
                child: GraphRenderer(
                  date: graphRange,
                  logBuilder: LogBuilder(
                    title: "Max Weight By Category",
                    items: [],
                    column: LBColumn.WEIGHT,
                    grouping: LBGrouping.CATEGORY,
                    condensing: LBCondensing.MAX,
                    weightNormalization: LBWeightNormalization.KG,
                    graphType: LBGraphType.TABLE,
                    showLegend: true,
                    showXAxis: false,
                    showYAxis: true,
                  ),
                ),
              ),
              BlurIfNotSubscription(
                child: GraphRenderer(
                  date: graphRange,
                  logBuilder: LogBuilder(
                    title: "Max Weight By Tag",
                    items: [],
                    column: LBColumn.WEIGHT,
                    grouping: LBGrouping.TAG,
                    condensing: LBCondensing.MAX,
                    weightNormalization: LBWeightNormalization.KG,
                    graphType: LBGraphType.TABLE,
                    showLegend: true,
                    showXAxis: false,
                    showYAxis: true,
                  ),
                ),
              ),
              BlurIfNotSubscription(
                child: GraphRenderer(
                  date: graphRange,
                  logBuilder: LogBuilder(
                    title: "Max Weight By Exercise",
                    items: [],
                    column: LBColumn.WEIGHT,
                    grouping: LBGrouping.EXERCISE,
                    condensing: LBCondensing.MAX,
                    weightNormalization: LBWeightNormalization.KG,
                    graphType: LBGraphType.TABLE,
                    showLegend: true,
                    showXAxis: false,
                    showYAxis: true,
                  ),
                ),
              ),
            ],
          ),
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
      ValueKey(uuid.v4()),
    ];
  }
}
