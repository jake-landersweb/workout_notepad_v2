import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/functions.dart';
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
                  "Now, select your workouts and compose your collection. You will not be able to change this after creation.",
                  style: ttLabel(context),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ContainedList<
                    Tuple4<String, IconData, Color, VoidCallback>>(
                  childPadding: EdgeInsets.zero,
                  leadingPadding: 0,
                  trailingPadding: 0,
                  children: [
                    if (cmodel.collection.collectionType ==
                        CollectionType.repeat)
                      Tuple4(
                        "Re-Order",
                        Icons.restart_alt,
                        Colors.orange,
                        () {
                          cupertinoSheet(
                            context: context,
                            enableDrag: false,
                            builder: (context) => const CECOrder(),
                          );
                        },
                      ),
                    Tuple4(
                      "Start Date: ${DateFormat('MMMM d').format(cmodel.collection.startDate)}",
                      Icons.calendar_month,
                      Colors.indigo,
                      () {
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
                                initialSelectedDate:
                                    cmodel.collection.startDate,
                                appointmentTextStyle:
                                    const TextStyle(fontSize: 24),
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
                    Tuple4(
                      "View Preview",
                      Icons.image_outlined,
                      Colors.teal,
                      () {
                        cupertinoSheet(
                          context: context,
                          builder: (context) => HeaderBar.sheet(
                            title: "Collection Preview",
                            canScroll: false,
                            horizontalSpacing: 0,
                            trailing: const [CancelButton(title: "Done")],
                            children: const [
                              SizedBox(height: 70),
                              Expanded(child: CECPreview()),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  onChildTap: (context, item, index) {
                    item.v4();
                  },
                  childBuilder: (context, item, index) {
                    return WrappedButton(
                      title: item.v1,
                      icon: item.v2,
                      iconBg: item.v3,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _getBody(context, cmodel),
                  ),
                ],
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
                  WorkoutCellSmall(wc: cmodel.collection.items[i].workout!),
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
            const SizedBox(height: 16),
            _selectWorkout(context, cmodel),
          ],
        );
      case CollectionType.days:
        return Column(
          children: [
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
                  "Repeat for",
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
                  "Weeks.",
                  style: ttLabel(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(
              color: AppColors.text(context).withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < 7; i++)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dayCell(context: context, cmodel: cmodel, day: i),
                  if (i < 6)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Divider(
                        color: AppColors.text(context).withOpacity(0.2),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
          ],
        );
      case CollectionType.schedule:
        throw "unimplemented";
    }
  }

  Widget _dayCell({
    required BuildContext context,
    required CECModel cmodel,
    required int day,
  }) {
    var items =
        cmodel.collection.items.where((element) => element.day == day).toList();
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  intToDay(day),
                  style: ttSubTitle(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: WrappedButton(
                  title: "Configure",
                  icon: Icons.settings_rounded,
                  onTap: () {
                    cupertinoSheet(
                      context: context,
                      enableDrag: false,
                      builder: (context) => _DayOfWeekPicker(day: day),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: WorkoutCellSmall(wc: i.workout!),
            ),
        ],
      ),
    );
  }

  Widget _selectWorkout(BuildContext context, CECModel cmodel,
      {Function(WorkoutCategories w)? onSelect}) {
    return WrappedButton(
      title: "Add A Workout",
      rowAxisSize: MainAxisSize.max,
      center: true,
      type: WrappedButtonType.main,
      onTap: () {
        cupertinoSheet(
          context: context,
          builder: (context) => SelectWorkouts(
            onSelect: (w) {
              if (onSelect != null) {
                onSelect(w)!;
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
                    wc: w,
                  ),
                );
                setState(() {
                  cmodel.refresh();
                });
              }
            },
            closeOnSelect: true,
          ),
        );
      },
    );
  }
}

class _DayOfWeekPicker extends StatefulWidget {
  const _DayOfWeekPicker({
    super.key,
    required this.day,
  });
  final int day;

  @override
  State<_DayOfWeekPicker> createState() => __DayOfWeekPickerState();
}

class __DayOfWeekPickerState extends State<_DayOfWeekPicker> {
  @override
  Widget build(BuildContext context) {
    var cmodel = context.read<CECModel>();
    var items = cmodel.collection.items
        .where((element) => element.day == widget.day)
        .toList();
    return HeaderBar.sheet(
      title: intToDay(widget.day),
      horizontalSpacing: 0,
      canScroll: false,
      trailing: const [CancelButton(title: "Done")],
      children: [
        Expanded(
          child: RawReorderableList<CollectionItem>(
            items: items,
            areItemsTheSame: (p0, p1) =>
                p0.collectionItemId == p1.collectionItemId,
            header: Padding(
              padding: const EdgeInsets.fromLTRB(16, 75, 16, 16),
              child: WrappedButton(
                title: "Select A Workout",
                rowAxisSize: MainAxisSize.max,
                center: true,
                type: WrappedButtonType.main,
                onTap: () {
                  cupertinoSheet(
                    context: context,
                    builder: (context) => SelectWorkouts(
                      onSelect: (w) {
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
                        var c = CollectionItem.fromWorkout(
                          collectionId: cmodel.collection.collectionId,
                          wc: w,
                        );
                        c.day = widget.day;
                        cmodel.collection.items.add(c);
                        setState(() {
                          cmodel.refresh();
                        });
                      },
                      closeOnSelect: true,
                    ),
                  );
                },
              ),
            ),
            footer: const SizedBox(height: 50),
            onReorderFinished: (item, from, to, newItems) {
              cmodel.collection.items
                ..clear()
                ..addAll(newItems);
              setState(() {
                cmodel.refresh();
              });
            },
            slideBuilder: (item, index) {
              return ActionPane(
                extentRatio: 0.3,
                motion: const DrawerMotion(),
                children: [
                  Expanded(
                    child: Row(children: [
                      SlidableAction(
                        onPressed: (context) async {
                          await Future.delayed(
                            const Duration(milliseconds: 100),
                          );
                          cmodel.collection.items.removeWhere(
                            (element) =>
                                element.collectionItemId ==
                                item.collectionItemId,
                          );
                          setState(() {
                            cmodel.refresh();
                          });
                        },
                        icon: LineIcons.alternateTrash,
                        label: "Delete",
                        foregroundColor: Theme.of(context).colorScheme.onError,
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ]),
                  ),
                ],
              );
            },
            builder: (item, index, handle, inDrag) {
              return Container(
                decoration: BoxDecoration(
                  color: inDrag
                      ? AppColors.cell(context)[100]
                      : AppColors.cell(context),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.workout!.workout.title,
                          style: ttLabel(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: handle,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
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
