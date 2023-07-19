import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class CollectionPreview extends StatelessWidget {
  const CollectionPreview({
    super.key,
    required this.collection,
    this.items,
  });
  final Collection collection;
  final List<CollectionItem>? items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCalendar(
        view: CalendarView.month,
        showNavigationArrow: true,
        appointmentTextStyle: const TextStyle(fontSize: 24),
        dataSource: CollectionDataSource(items ?? collection.items),
        initialSelectedDate: collection.datetime,
        monthViewSettings: const MonthViewSettings(
          showAgenda: true,
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        ),
      ),
    );
  }
}

class CollectionDataSource extends CalendarDataSource {
  CollectionDataSource(List<CollectionItem> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].datetime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].datetime;
  }

  @override
  String getSubject(int index) {
    return appointments![index].workout.title;
  }

  @override
  Color getColor(int index) {
    return ColorUtil.random(appointments![index].workoutId);
  }

  @override
  bool isAllDay(int index) {
    return true;
  }
}
