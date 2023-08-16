import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/logs/logs_cat_indiv.dart';
import 'package:workout_notepad_v2/views/logs/root.dart';
import 'package:workout_notepad_v2/views/profile/subscriptions.dart';

class LogsHome extends StatefulWidget {
  const LogsHome({super.key});

  @override
  State<LogsHome> createState() => _LogsHomeState();
}

class _LogsHomeState extends State<LogsHome> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return HeaderBar(
      title: "Logs Overview",
      isLarge: true,
      horizontalSpacing: 0,
      largeTitlePadding: const EdgeInsets.only(left: 16),
      children: [
        const SizedBox(height: 16),
        // most logged for all types (2x2)
        Section(
          "Basic",
          headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
          child: ContainedList<Tuple4<String, IconData, Color, Widget>>(
            childPadding: EdgeInsets.zero,
            children: [
              Tuple4(
                "Workout Logs",
                Icons.calendar_month_rounded,
                Colors.green[200]!,
                const LogsPreviousWorkouts(),
              ),
              Tuple4(
                "Recent Exercises",
                Icons.update_rounded,
                Colors.purple[200]!,
                Container(),
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
        Section(
          "Advanced",
          headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
          child: ContainedList<Tuple4<String, IconData, Color, Widget>>(
            childPadding: EdgeInsets.zero,
            children: [
              Tuple4(
                "Workouts Breakdown",
                Icons.analytics_rounded,
                Colors.deepOrange[200]!,
                const LogsWorkoutsBreakdown(),
              ),
              Tuple4(
                "My Max Sets",
                Icons.speed_rounded,
                Colors.red[200]!,
                const LogsMaxSets(),
              ),
              Tuple4(
                "Exercise Type Distribution",
                Icons.donut_small_rounded,
                Colors.blue[200]!,
                const LogsTypeDistribution(),
              ),
              Tuple4(
                "Categories Overview",
                Icons.donut_small_rounded,
                Colors.orange[200]!,
                LogsCategoryDistribution(categories: dmodel.categories),
              ),
            ],
            onChildTap: (context, item, index) {
              if (dmodel.user!.subscriptionType ==
                  SubscriptionType.wn_premium) {
                navigate(context: context, builder: (context) => item.v4);
              } else {
                cupertinoSheet(
                  context: context,
                  builder: (context) => const Subscriptions(),
                );
              }
            },
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
                    dmodel.user!.subscriptionType == SubscriptionType.wn_premium
                        ? Icons.chevron_right_rounded
                        : Icons.lock_rounded,
                    color: AppColors.subtext(context),
                  ),
                  const SizedBox(width: 4),
                ],
              );
            },
          ),
        ),
        Section(
          "Category",
          headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
          child: ContainedList<Category>(
            childPadding: const EdgeInsets.only(left: 16),
            children: dmodel.categories,
            onChildTap: (context, item, index) {
              if (dmodel.user!.subscriptionType ==
                  SubscriptionType.wn_premium) {
                navigate(
                  context: context,
                  builder: (context) => LogsCategoryIndividual(category: item),
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
                      dmodel.user!.subscriptionType ==
                              SubscriptionType.wn_premium
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
        ),

        SizedBox(
            height: (dmodel.workoutState == null ? 100 : 130) +
                (dmodel.user!.offline ? 30 : 0)),
      ],
    );
  }
}
