// ignore_for_file: constant_identifier_names

import 'package:collection/collection.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/utils/tuple.dart';

enum LBDateRange {
  WEEK,
  MONTH,
  CUSTOM;
}

class LogBuilderDate {
  late LBDateRange dateRangeType;
  late int dateRangeModifier;
  DateTime? rangeStart;
  DateTime? rangeEnd;

  LogBuilderDate({
    this.dateRangeType = LBDateRange.WEEK,
    this.dateRangeModifier = 2,
    this.rangeStart,
    this.rangeEnd,
  }) {
    if (dateRangeType == LBDateRange.CUSTOM &&
        (rangeStart == null || rangeEnd == null)) {
      throw "ERROR: rangeStart and rangeEnd cannot be null";
    }
  }

  LogBuilderDate.fromJson(dynamic json) {
    dateRangeType = LBDateRange.values.firstWhereOrNull(
            (element) => element.name == json['dateRangeType']) ??
        LBDateRange.values.first;
    dateRangeModifier = json['dateRangeModifier'];
    rangeStart = DateTime.tryParse(json['rangeStart'] ?? "");
    rangeEnd = DateTime.tryParse(json['rangeEnd'] ?? "");
  }

  LogBuilderDate copy() {
    return LogBuilderDate(
      dateRangeType: dateRangeType,
      dateRangeModifier: dateRangeModifier,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );
  }

  Tuple2<DateTime, DateTime> getRange() {
    switch (dateRangeType) {
      case LBDateRange.WEEK:
        return Tuple2(
          DateTime.now().subtract(Duration(days: 7 * dateRangeModifier)),
          DateTime.now(),
        );
      case LBDateRange.MONTH:
        return Tuple2(
          DateTime.now().subtract(Duration(days: 30 * dateRangeModifier)),
          DateTime.now(),
        );
      case LBDateRange.CUSTOM:
        return Tuple2(rangeStart!, rangeEnd!);
    }
  }

  @override
  String toString() {
    switch (dateRangeType) {
      case LBDateRange.WEEK:
        return "Last $dateRangeModifier weeks";
      case LBDateRange.MONTH:
        return "Last $dateRangeModifier months";
      case LBDateRange.CUSTOM:
        var range = getRange();
        return "${formatDateTime(range.v1)} - ${formatDateTime(range.v2)}";
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "dateRangeType": dateRangeType.name,
      "dateRangeModifier": dateRangeModifier,
      "rangeStart": rangeStart?.toIso8601String(),
      "rangeEnd": rangeEnd?.toIso8601String(),
    };
  }
}
