import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/logs/root.dart';

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
        ContainedList<Tuple4<String, IconData, Color, Widget>>(
          childPadding: EdgeInsets.zero,
          children: [
            Tuple4(
              "Previous Workouts",
              Icons.calendar_month_rounded,
              Colors.green[200]!,
              const LogsPreviousWorkouts(),
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
              "Category Distribution",
              Icons.donut_small_rounded,
              Colors.orange[200]!,
              LogsCategoryDistribution(categories: dmodel.categories),
            ),
            Tuple4(
              "Recently Logged",
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

        SizedBox(
            height: (dmodel.workoutState == null ? 100 : 130) +
                (dmodel.user!.offline ? 30 : 0)),
      ],
    );
  }
}
