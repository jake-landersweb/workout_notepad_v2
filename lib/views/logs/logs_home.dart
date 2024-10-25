import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/components/blur_if_not_subscription.dart';
import 'package:workout_notepad_v2/components/expanded_page_view.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder_item.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/exercises/logs/recent_exercises.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_builder.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_custom.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_range_picker.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_renderer.dart';
import 'package:workout_notepad_v2/views/logs/logs_calendar.dart';
import 'package:workout_notepad_v2/views/logs/logs_default_page.dart';
import 'package:workout_notepad_v2/views/logs/root.dart';
import 'package:workout_notepad_v2/views/profile/subscriptions.dart';
import 'package:workout_notepad_v2/views/root.dart';

class LogsHome extends StatefulWidget {
  const LogsHome({super.key});

  @override
  State<LogsHome> createState() => _LogsHomeState();
}

class _LogsHomeState extends State<LogsHome> {
  late List<Key> _keys;

  @override
  void initState() {
    _keys = _generateKeys();
    _getRecentExercises();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GraphRangeProvider(),
      builder: (context, _) {
        return _body(context);
        // return _body(context);
      },
    );
  }

  Widget _body(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    var graphRange = context.select(
      (GraphRangeProvider value) => value.getDate,
    );

    return HeaderBar(
      title: "Log Dashboard",
      isLarge: true,
      horizontalSpacing: 0,
      largeTitlePadding: const EdgeInsets.only(left: 16),
      refreshable: true,
      onRefresh: () async {
        await _getRecentExercises();
        setState(() {
          _keys = _generateKeys();
        });
      },
      trailing: [
        AddButton(
          onTap: () {
            cupertinoSheet(
              context: context,
              builder: (context) => const GraphBuilder(),
            );
          },
        )
      ],
      children: [
        Column(
          children: [
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
            CustomPageView(
              key: _keys[0],
              duration: Duration.zero,
              childHorizontalPadding: 16,
              children: [
                GraphRenderer(
                  date: graphRange,
                  logBuilder: LogBuilder(
                    title: "Workout Duration",
                    items: [],
                    column: LBColumn.WORKOUT_DURATION,
                    grouping: LBGrouping.DATE,
                    condensing: LBCondensing.FIRST,
                    weightNormalization: LBWeightNormalization.KG,
                    graphType: LBGraphType.BAR,
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
                    title: "Reps Over Time",
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
                BlurIfNotSubscription(
                  child: GraphRenderer(
                    date: graphRange,
                    logBuilder: LogBuilder(
                      title: "Weight Lifted Over Time",
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
                      title: "Type Distribution",
                      items: [],
                      column: LBColumn.REPS,
                      grouping: LBGrouping.CATEGORY,
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
                      title: "Tag Distribution",
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
                      title: "Exercise Distribution",
                      items: [],
                      column: LBColumn.REPS,
                      grouping: LBGrouping.EXERCISE,
                      condensing: LBCondensing.COUNT,
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
            Section(
              "Recent Exercises",
              headerPadding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              trailingWidget: Opacity(
                opacity: 0.7,
                child: Clickable(
                  onTap: () {
                    navigate(
                      context: context,
                      builder: (context) => RecentExercises(),
                    );
                  },
                  child: const Row(
                    children: [
                      Text("All"),
                      Icon(Icons.arrow_right_alt),
                    ],
                  ),
                ),
              ),
              child: _recentExercisesView(context),
            ),
            _customGraphs(context),
            _category(context),
            _tag(context),
            // most logged for all types (2x2)
            Section(
              "Other",
              headerPadding: const EdgeInsets.fromLTRB(16, 32, 0, 16),
              child: ContainedList<Tuple4<String, IconData, Color, Widget>>(
                childPadding: EdgeInsets.zero,
                children: [
                  Tuple4(
                    "Workout logs Calendar",
                    Icons.calendar_month_rounded,
                    Colors.blue[200]!,
                    const LogsCalendar(),
                  ),
                  Tuple4(
                    "Raw Workout Logs",
                    Icons.list,
                    Colors.green[200]!,
                    const LogsPreviousWorkouts(),
                  ),
                ],
                onChildTap: (context, item, index) =>
                    navigate(context: context, builder: (context) => item.v4),
                childBuilder: (context, item, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: WrappedButton(
                          title: item.v1,
                          icon: item.v2,
                          iconBg: item.v3,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.subtext(context),
                      ),
                      const SizedBox(width: 4),
                    ],
                  );
                },
              ),
            ),
            // Section(
            //   "Advanced",
            //   headerPadding: const EdgeInsets.fromLTRB(16, 32, 0, 16),
            //   child: ContainedList<Tuple4<String, IconData, Color, Widget>>(
            //     childPadding: EdgeInsets.zero,
            //     children: [
            //       Tuple4(
            //         "Workouts Breakdown",
            //         Icons.analytics_rounded,
            //         Colors.deepOrange[200]!,
            //         const LogsWorkoutsBreakdown(),
            //       ),
            //       Tuple4(
            //         "My Max Sets",
            //         Icons.speed_rounded,
            //         Colors.red[200]!,
            //         const LogsMaxSets(),
            //       ),
            //       Tuple4(
            //         "Exercise Type Distribution",
            //         Icons.donut_small_rounded,
            //         Colors.blue[200]!,
            //         const LogsTypeDistribution(),
            //       ),
            //       Tuple4(
            //         "Categories Overview",
            //         Icons.donut_small_rounded,
            //         Colors.orange[200]!,
            //         LogsCategoryDistribution(categories: dmodel.categories),
            //       ),
            //     ],
            //     onChildTap: (context, item, index) {
            //       if (dmodel.hasValidSubscription()) {
            //         navigate(context: context, builder: (context) => item.v4);
            //       } else {
            //         cupertinoSheet(
            //           context: context,
            //           builder: (context) => const Subscriptions(),
            //         );
            //       }
            //     },
            //     childBuilder: (context, item, index) {
            //       return Row(
            //         children: [
            //           Expanded(
            //             child: WrappedButton(
            //               title: item.v1,
            //               icon: item.v2,
            //               iconBg: item.v3,
            //             ),
            //           ),
            //           Icon(
            //             dmodel.hasValidSubscription()
            //                 ? Icons.chevron_right_rounded
            //                 : Icons.lock_rounded,
            //             color: AppColors.subtext(context),
            //           ),
            //           const SizedBox(width: 4),
            //         ],
            //       );
            //     },
            //   ),
            // ),

            SizedBox(
              height: (dmodel.workoutState == null ? 100 : 130) +
                  (dmodel.user!.offline ? 30 : 0),
            ),
          ],
        ),
      ],
    );
  }

  Widget _recentExercisesView(BuildContext context) {
    DataModel dmodel = context.watch();

    if (_isLoadingExercies) {
      return LoadingIndicator();
    }

    if (_recentExercises.isEmpty) {
      return Text("Empty");
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          for (var i in _recentExercises)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExerciseCell(
                  exercise: i,
                  onTap: () {
                    cupertinoSheet(
                      context: context,
                      builder: (context) => ExerciseDetail(exercise: i),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _customGraphs(BuildContext context) {
    DataModel dmodel = context.watch();
    return Section(
      "Custom Graphs",
      headerPadding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      allowsCollapse: true,
      initOpen: true,
      child: ContainedList<Tuple3<IconData, String, Widget>>(
        childPadding: const EdgeInsets.only(left: 16),
        children: [
          Tuple3(LineIcons.barChart, "All", const CustomGraphs()),
          // Tuple3(LineIcons.pieChart, "By Graph Type", const CustomGraphs()),
          // Tuple3(LineIcons.lineChart, "By Grouping", const CustomGraphs()),
        ],
        onChildTap: (context, item, index) {
          if (dmodel.hasValidSubscription()) {
            navigate(
              context: context,
              builder: (context) => item.v3,
            );
          } else {
            cupertinoSheet(
              context: context,
              builder: (context) => const Subscriptions(),
            );
          }
        },
        childBuilder: (context, item, index) {
          return ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: ColorUtil.random(item.v2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  height: 30,
                  width: 30,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(
                      item.v1,
                      // color: getSwatch(ColorUtil.random(item.v2))[700],
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.v2.capitalize(),
                    style: ttLabel(context),
                  ),
                ),
                Icon(
                  dmodel.hasValidSubscription()
                      ? Icons.chevron_right_rounded
                      : Icons.lock_rounded,
                  color: AppColors.subtext(context),
                ),
                const SizedBox(width: 4),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _category(BuildContext context) {
    DataModel dmodel = context.watch();
    return Section(
      "Category",
      headerPadding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      allowsCollapse: true,
      initOpen: true,
      child: ContainedList<Category>(
        childPadding: const EdgeInsets.only(left: 16),
        children: dmodel.categories,
        onChildTap: (context, item, index) {
          if (dmodel.hasValidSubscription()) {
            navigate(
              context: context,
              builder: (context) => DefaultLogPage(
                title: item.title,
                defaultCondition: LogBuilderItem(
                  column: LBIColumn.CATEGORY,
                  modifier: LBIModifier.EQUALS,
                  values: item.title,
                ),
              ),
            );
          } else {
            cupertinoSheet(
              context: context,
              builder: (context) => const Subscriptions(),
            );
          }
        },
        childBuilder: (context, item, index) {
          return ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cell(context)[500],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  height: 30,
                  width: 30,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: getImageIcon(item.icon),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title.capitalize(),
                    style: ttLabel(context),
                  ),
                ),
                Icon(
                  dmodel.hasValidSubscription()
                      ? Icons.chevron_right_rounded
                      : Icons.lock_rounded,
                  color: AppColors.subtext(context),
                ),
                const SizedBox(width: 4),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _tag(BuildContext context) {
    DataModel dmodel = context.watch();
    return Section(
      "By Tag",
      headerPadding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      allowsCollapse: true,
      initOpen: true,
      child: ContainedList<Tag>(
        childPadding: const EdgeInsets.only(left: 16),
        children: dmodel.tags,
        onChildTap: (context, item, index) {
          if (dmodel.hasValidSubscription()) {
            navigate(
              context: context,
              builder: (context) => DefaultLogPage(
                title: "Tag: ${item.title}",
                defaultCondition: LogBuilderItem(
                  column: LBIColumn.TAGS,
                  modifier: LBIModifier.CONTAINS,
                  values: item.title,
                ),
                colorOverride: ColorUtil.random(item.title),
              ),
            );
          } else {
            cupertinoSheet(
              context: context,
              builder: (context) => const Subscriptions(),
            );
          }
        },
        childBuilder: (context, item, index) {
          return ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: ColorUtil.random(item.title),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  height: 30,
                  width: 30,
                  child: Center(
                    child: Text(
                      "#",
                      style: ttLabel(
                        context,
                        color: getSwatch(ColorUtil.random(item.title))[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title.capitalize(),
                    style: ttLabel(context),
                  ),
                ),
                Icon(
                  dmodel.hasValidSubscription()
                      ? Icons.chevron_right_rounded
                      : Icons.lock_rounded,
                  color: AppColors.subtext(context),
                ),
                const SizedBox(width: 4),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Key> _generateKeys() {
    const uuid = Uuid();
    return [
      ValueKey(uuid.v4()),
      // ValueKey(uuid.v4()),
      // ValueKey(uuid.v4()),
    ];
  }

  bool _isLoadingExercies = true;
  List<Exercise> _recentExercises = [];
  Future<void> _getRecentExercises() async {
    setState(() {
      _isLoadingExercies = true;
      _recentExercises.clear();
    });
    try {
      var db = await DatabaseProvider().database;
      var response = await db.rawQuery("""
            SELECT e.* FROM exercise_log el
            JOIN exercise e ON el.exerciseId = e.exerciseId
            ORDER BY el.created DESC LIMIT 5
          """);
      for (var i in response) {
        _recentExercises.add(Exercise.fromJson(i));
      }
    } catch (e) {
      print(e);
      NewrelicMobile.instance.recordError(
        e,
        StackTrace.current,
        attributes: {"err_code": "logs_recent_exercises"},
      );
    }
    setState(() {
      _isLoadingExercies = false;
    });
  }
}
