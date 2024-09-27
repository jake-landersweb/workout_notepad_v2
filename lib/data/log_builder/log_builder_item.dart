// ignore_for_file: constant_identifier_names

import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

enum LBIAddition { AND, OR }

enum LBIColumn {
  // log
  EXERCISE_ID,
  TITLE,
  // log metadata
  TAGS,
  REPS,
  WEIGHT,
  TIME,
  // category
  CATEGORY;

  @override
  String toString() {
    switch (this) {
      case LBIColumn.EXERCISE_ID:
        return "el.exerciseId";
      case LBIColumn.TITLE:
        return "el.title";
      case LBIColumn.TAGS:
        return "elm.tags";
      case LBIColumn.REPS:
        return "elm.reps";
      case LBIColumn.WEIGHT:
        return "elm.weight";
      case LBIColumn.TIME:
        return "elm.time";
      case LBIColumn.CATEGORY:
        return "c.title";
    }
  }

  String toHumanReadable() {
    switch (this) {
      case LBIColumn.EXERCISE_ID:
        return "Exercise";
      case LBIColumn.TITLE:
        return "Title";
      case LBIColumn.TAGS:
        return "Tags";
      case LBIColumn.REPS:
        return "Reps";
      case LBIColumn.WEIGHT:
        return "Weight";
      case LBIColumn.TIME:
        return "Time";
      case LBIColumn.CATEGORY:
        return "Category";
    }
  }

  List<LBIModifier> getValidModifiers() {
    switch (this) {
      case LBIColumn.EXERCISE_ID:
        return [
          LBIModifier.EQUALS,
          LBIModifier.NOT_EQUALS,
          LBIModifier.CONTAINS,
          LBIModifier.NOT_CONTAINS,
        ];
      case LBIColumn.TITLE:
        return [
          LBIModifier.EQUALS,
          LBIModifier.NOT_EQUALS,
          LBIModifier.CONTAINS,
          LBIModifier.NOT_CONTAINS,
        ];
      case LBIColumn.TAGS:
        return [
          LBIModifier.EQUALS,
          LBIModifier.NOT_EQUALS,
          LBIModifier.CONTAINS,
          LBIModifier.NOT_CONTAINS,
        ];
      case LBIColumn.REPS:
        return [
          LBIModifier.EQUALS,
          LBIModifier.NOT_EQUALS,
          LBIModifier.LESS_THAN,
          LBIModifier.GREATER_THAN,
        ];
      case LBIColumn.WEIGHT:
        return [
          LBIModifier.EQUALS,
          LBIModifier.NOT_EQUALS,
          LBIModifier.LESS_THAN,
          LBIModifier.GREATER_THAN,
        ];
      case LBIColumn.TIME:
        return [
          LBIModifier.EQUALS,
          LBIModifier.NOT_EQUALS,
          LBIModifier.LESS_THAN,
          LBIModifier.GREATER_THAN,
        ];
      case LBIColumn.CATEGORY:
        return [
          LBIModifier.EQUALS,
          LBIModifier.NOT_EQUALS,
          LBIModifier.CONTAINS,
          LBIModifier.NOT_CONTAINS,
        ];
    }
  }
}

enum LBIModifier {
  EQUALS,
  NOT_EQUALS,
  LESS_THAN,
  GREATER_THAN,
  CONTAINS,
  NOT_CONTAINS;

  @override
  String toString() {
    switch (this) {
      case LBIModifier.EQUALS:
        return "=";
      case LBIModifier.NOT_EQUALS:
        return "!=";
      case LBIModifier.CONTAINS:
        return "LIKE";
      case LBIModifier.NOT_CONTAINS:
        return "NOT LIKE";
      case LBIModifier.LESS_THAN:
        return "<";
      case LBIModifier.GREATER_THAN:
        return ">";
    }
  }

  String toHumanReadable() {
    switch (this) {
      case LBIModifier.EQUALS:
        return "=";
      case LBIModifier.NOT_EQUALS:
        return "!=";
      case LBIModifier.CONTAINS:
        return "Contains";
      case LBIModifier.NOT_CONTAINS:
        return "Doesn't contain";
      case LBIModifier.LESS_THAN:
        return "<";
      case LBIModifier.GREATER_THAN:
        return ">";
    }
  }
}

class LogBuilderItem {
  late String id;
  late LBIAddition addition;
  late LBIColumn column;
  late LBIModifier modifier;
  late String values;

  LogBuilderItem({
    LBIAddition? addition,
    LBIColumn? column,
    LBIModifier? modifier,
    String? values,
  }) {
    id = const Uuid().v4();
    this.addition = addition ?? LBIAddition.AND;
    this.column = column ?? LBIColumn.TAGS;
    this.modifier = modifier ?? LBIModifier.CONTAINS;
    this.values = values ?? "Working Set";
  }

  LogBuilderItem.fromJson(dynamic json) {
    id = const Uuid().v4();
    addition = LBIAddition.values
            .firstWhereOrNull((element) => element.name == json['addition']) ??
        LBIAddition.values.first;
    column = LBIColumn.values
            .firstWhereOrNull((element) => element.name == json['column']) ??
        LBIColumn.values.first;
    modifier = LBIModifier.values
            .firstWhereOrNull((element) => element.name == json['modifier']) ??
        LBIModifier.values.first;
    values = json['values'];
  }

  String format() {
    return " ${addition.name} ${getValues()}";
  }

  String getValues() {
    switch (modifier) {
      case LBIModifier.EQUALS:
      case LBIModifier.NOT_EQUALS:
      case LBIModifier.LESS_THAN:
      case LBIModifier.GREATER_THAN:
        return "${column.toString()} ${modifier.toString()} '$values'";
      case LBIModifier.CONTAINS:
        var tmp = values.split(",").map((e) => e.trim()).toList();
        String val = "";
        for (int i = 0; i < tmp.length; i++) {
          val +=
              "${i == 0 ? '' : ' OR '}${column.toString()} LIKE '%${tmp[i]}%'";
        }
        return "($val)";
      case LBIModifier.NOT_CONTAINS:
        var tmp = values.split(",").map((e) => e.trim()).toList();
        String val = "";
        for (int i = 0; i < tmp.length; i++) {
          val +=
              "${i == 0 ? '' : ' OR '}${column.toString()} NOT LIKE '%${tmp[i]}%'";
        }
        return "($val)";
    }
  }

  LogBuilderItem copy() {
    return LogBuilderItem(
      addition: addition,
      column: column,
      modifier: modifier,
      values: values,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "addition": addition.name,
      "column": column.name,
      "modifier": modifier.name,
      "values": values,
    };
  }
}
