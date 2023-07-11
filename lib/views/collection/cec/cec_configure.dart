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

class CECConfigure extends StatefulWidget {
  const CECConfigure({super.key});

  @override
  State<CECConfigure> createState() => _CECConfigureState();
}

class _CECConfigureState extends State<CECConfigure> {
  @override
  Widget build(BuildContext context) {
    var cmodel = context.read<CECModel>();
    var dmodel = context.read<DataModel>();
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Now, select the type of collection you would like to use.",
                  style: ttLabel(context),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ContainedList<
                    Tuple4<String, IconData, Color, CollectionType>>(
                  childPadding: EdgeInsets.zero,
                  leadingPadding: 0,
                  trailingPadding: 0,
                  children: [
                    Tuple4(
                      "Repeat",
                      Icons.restart_alt,
                      Colors.red,
                      CollectionType.repeat,
                    ),
                    Tuple4(
                      "Days of the Week",
                      Icons.view_week_outlined,
                      Colors.green,
                      CollectionType.days,
                    ),
                    Tuple4(
                      "Scheduled",
                      Icons.calendar_month_rounded,
                      Colors.blue,
                      CollectionType.schedule,
                    ),
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
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: WrappedButton(
                  title: "Re-Order",
                  icon: Icons.toc_rounded,
                  center: true,
                  rowAxisSize: MainAxisSize.max,
                  onTap: () {
                    cupertinoSheet(
                      context: context,
                      enableDrag: false,
                      builder: (context) => const CECOrder(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: WrappedButton(
                  title:
                      "Start Date: ${DateFormat('MMMM d').format(cmodel.collection.startDate)}",
                  icon: Icons.calendar_month,
                  iconBg: Colors.orange,
                  center: true,
                  rowAxisSize: MainAxisSize.max,
                  onTap: () {
                    cupertinoSheet(
                      context: context,
                      builder: (context) => HeaderBar.sheet(
                          title: "Start Date",
                          canScroll: false,
                          children: [
                            const SizedBox(height: 70),
                            SfCalendar(
                              view: CalendarView.month,
                              initialSelectedDate: cmodel.collection.startDate,
                              appointmentTextStyle:
                                  const TextStyle(fontSize: 24),
                              onTap: (calendarTapDetails) {
                                cmodel.collection.startDate =
                                    calendarTapDetails.date!;
                                cmodel.refresh();
                                Navigator.of(context).pop();
                              },
                            ),
                          ]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Container(
                color: Colors.black.withOpacity(0.05),
                width: double.infinity,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _getBody(context, cmodel),
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getBody(BuildContext context, CECModel cmodel) {
    switch (cmodel.collection.collectionType) {
      case CollectionType.repeat:
        return Column(
          children: [
            for (int i = 0; i < cmodel.collection.items.length; i++)
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cell(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              cmodel.collection.items[i].workout!.workout.title,
                              textAlign: TextAlign.center,
                              style: ttLabel(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.arrow_downward,
                    size: 50,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _RepeatDayPicker(
                      val: cmodel.collection.items[i].daysBreak,
                      onChanged: (val) {
                        cmodel.collection.items[i].daysBreak = val;
                        setState(() {
                          cmodel.refresh();
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Icon(
                      Icons.arrow_downward,
                      size: 50,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cell(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.replay,
                      size: 50,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Repeat",
                  style: ttLabel(context),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 75),
                  child: NumberPicker(
                    key: ValueKey(cmodel.collection.numRepeats),
                    intialValue: cmodel.collection.numRepeats,
                    textFontSize: 30,
                    showPicker: false,
                    maxValue: 25,
                    onChanged: (v) {
                      cmodel.collection.numRepeats = v;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Times.",
                  style: ttLabel(context),
                ),
              ],
            ),
          ],
        );
      case CollectionType.days:
        return Container();
      case CollectionType.schedule:
        return Container();
    }
  }
}

class _RepeatDayPicker extends StatelessWidget {
  const _RepeatDayPicker({
    super.key,
    required this.val,
    required this.onChanged,
    this.maxVal = 7,
  });
  final int val;
  final Function(int val) onChanged;
  final int maxVal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _cell(
                context: context,
                icon: Icons.add_rounded,
                fg: Colors.white,
                bg: Theme.of(context).colorScheme.primary,
                onTap: () {
                  if (val < maxVal) {
                    onChanged(val + 1);
                  }
                },
              ),
              _cell(
                context: context,
                icon: Icons.remove_rounded,
                fg: Theme.of(context).colorScheme.primary,
                bg: AppColors.cell(context),
                onTap: () {
                  if (val > 0) {
                    onChanged(val - 1);
                  }
                },
              )
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cell(context),
            borderRadius: BorderRadius.circular(10),
          ),
          height: 50,
          width: 150,
          child: Center(
            child: Text(title, style: ttLabel(context)),
          ),
        ),
      ],
    );
  }

  String get title {
    switch (val) {
      case 0:
        return "Same Day";
      case 1:
        return "Next Day";
      default:
        return "${val - 1} Day break";
    }
  }

  Widget _cell({
    required BuildContext context,
    required IconData icon,
    required Color fg,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return Clickable(
      onTap: onTap,
      child: Container(
        color: bg,
        width: 50,
        height: 25,
        child: Center(child: Icon(icon, color: fg)),
      ),
    );
  }
}
