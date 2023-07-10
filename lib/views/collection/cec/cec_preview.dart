import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/collection/cec/root.dart';

class CECPreview extends StatefulWidget {
  const CECPreview({super.key});

  @override
  State<CECPreview> createState() => _CECPreviewState();
}

class _CECPreviewState extends State<CECPreview> {
  @override
  Widget build(BuildContext context) {
    var cmodel = context.read<CECModel>();
    return Scaffold(
      body: SfCalendar(
        view: CalendarView.month,
        appointmentTextStyle: const TextStyle(fontSize: 24),
        dataSource: CollectionDataSource(cmodel.getRenderedCollectionItems()),
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
    return appointments![index].date;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].date;
  }

  @override
  String getSubject(int index) {
    return appointments![index].workout.workout.title;
  }

  @override
  Color getColor(int index) {
    return ColorUtil.random(appointments![index].collectionItemId);
  }

  @override
  bool isAllDay(int index) {
    return true;
  }
}
