import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder_item.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/exercises/logs/recent_exercises.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_builder.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_custom.dart';
import 'package:workout_notepad_v2/views/logs/logs_calendar.dart';
import 'package:workout_notepad_v2/views/logs/logs_default_page.dart';
import 'package:workout_notepad_v2/views/logs/root.dart';
import 'package:workout_notepad_v2/views/profile/paywall.dart';

class LogsHome extends StatefulWidget {
  const LogsHome({super.key});

  @override
  State<LogsHome> createState() => _LogsHomeState();
}

class _LogsHomeState extends State<LogsHome> {
  @override
  Widget build(BuildContext context) {
    return _body(context);
  }

  Widget _body(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);

    return HeaderBar(
      title: "Graphs",
      isLarge: true,
      horizontalSpacing: 0,
      largeTitlePadding: const EdgeInsets.only(left: 16),
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
                  Tuple4(
                    "Recent Exercise Logs",
                    LineIcons.list,
                    Colors.red[200]!,
                    const RecentExercises(),
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
              height: (dmodel.workoutState == null ? 100 : 130),
            ),
          ],
        ),
      ],
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
            showPaywall(context);
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
      "By Category",
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
            showPaywall(context);
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
            showPaywall(context);
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
}
