import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/collection/cec/root.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:intl/intl.dart';

class CECBasic extends StatefulWidget {
  const CECBasic({super.key});

  @override
  State<CECBasic> createState() => _CECBasicState();
}

class _CECBasicState extends State<CECBasic> {
  @override
  Widget build(BuildContext context) {
    var cmodel = context.read<CECModel>();
    var dmodel = context.read<DataModel>();
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "First, select the collection type you would like to use and the start date.",
                style: ttLabel(context),
              ),
              const SizedBox(height: 16),
              WrappedButton(
                title:
                    "Start Date: ${DateFormat('MMMM d').format(cmodel.collection.startDate)}",
                icon: Icons.calendar_month,
                iconBg: Colors.indigo,
                rowAxisSize: MainAxisSize.max,
                onTap: () {
                  cupertinoSheet(
                    context: context,
                    builder: (context) => HeaderBar.sheet(
                      title: "Start Date",
                      canScroll: false,
                      horizontalSpacing: 0,
                      trailing: const [CancelButton(title: "Done")],
                      children: [
                        const SizedBox(height: 70),
                        SfCalendar(
                          view: CalendarView.month,
                          initialSelectedDate: cmodel.collection.startDate,
                          appointmentTextStyle: const TextStyle(fontSize: 24),
                          onTap: (calendarTapDetails) {
                            cmodel.collection.startDate =
                                calendarTapDetails.date!;
                            cmodel.refresh();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              ContainedList<Tuple4<String, IconData, Color, CollectionType>>(
                childPadding: EdgeInsets.zero,
                leadingPadding: 0,
                trailingPadding: 0,
                children: [
                  Tuple4(
                    "Repeat",
                    Icons.restart_alt,
                    Colors.purple,
                    CollectionType.repeat,
                  ),
                  Tuple4(
                    "Days of the Week",
                    Icons.view_week_outlined,
                    Colors.green,
                    CollectionType.days,
                  ),
                  // Tuple4(
                  //   "Scheduled",
                  //   Icons.calendar_month_rounded,
                  //   Colors.blue,
                  //   CollectionType.schedule,
                  // ),
                ],
                onChildTap: (context, item, index) {
                  cmodel.collection.collectionType = item.v4;
                  setState(() {
                    cmodel.refresh();
                  });
                },
                childBuilder: (context, item, index) {
                  return WrappedButton(
                    title: item.v1,
                    icon: item.v2,
                    iconBg: item.v4 == cmodel.collection.collectionType
                        ? item.v3
                        : AppColors.cell(context)[600],
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.text(context).withOpacity(0.5),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _description(cmodel),
                      style: TextStyle(
                        color: AppColors.text(context).withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _description(CECModel cmodel) {
    switch (cmodel.collection.collectionType) {
      case CollectionType.repeat:
        return "Order your workouts, select how many days of rest between each workout, and choose how many times to repeat this cycle.";
      case CollectionType.days:
        return "Select which workout(s) you will do on each day of the week, along with how many weeks the collection will last.";
      case CollectionType.schedule:
        throw "unimplemented";
    }
  }

  Widget _workoutCell(
      BuildContext context, CECModel cmodel, WorkoutCategories wc) {
    var selected =
        cmodel.workoutIds.any((element) => element == wc.workout.workoutId);
    return WorkoutCellSmall(
      wc: wc,
      bg: AppColors.cell(context),
      endWidget: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            Expanded(
              child: WrappedButton(
                title: "Details",
                center: true,
                bg: AppColors.cell(context)[500],
                onTap: () {
                  cupertinoSheet(
                    context: context,
                    builder: (context) => WorkoutDetail.small(workout: wc),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: WrappedButton(
                title: selected ? "Selected" : "Select",
                icon: selected ? Icons.check : null,
                fg: selected ? Colors.white : AppColors.text(context),
                bg: selected
                    ? Theme.of(context).colorScheme.primary
                    : AppColors.cell(context)[500],
                iconBg: Colors.transparent,
                iconFg: Colors.white,
                iconSpacing: 4,
                center: true,
                rowAxisSize: MainAxisSize.max,
                onTap: () {
                  if (selected) {
                    cmodel.collection.items.removeWhere((element) =>
                        element.workout!.workout.workoutId ==
                        wc.workout.workoutId);
                  } else {
                    if (cmodel.collection.items.length >= 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              "You can only have a maximum of 10 workouts in a collection."),
                          backgroundColor: Colors.red[300],
                        ),
                      );
                      return;
                    }
                    cmodel.collection.items.add(
                      CollectionItem.fromWorkout(
                        collectionId: cmodel.collection.collectionId,
                        wc: wc,
                      ),
                    );
                  }
                  cmodel.refresh();
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
