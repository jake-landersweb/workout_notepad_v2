// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder_date.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder_item.dart';
import 'package:workout_notepad_v2/data/log_builder/log_row.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/utils/root.dart';

enum LBGraphType {
  TIMESERIES,
  PIE,
  BAR,
  SPIDER,
  PANEL,
  TABLE;

  IconData getIcon() {
    switch (this) {
      case LBGraphType.TIMESERIES:
        return LineIcons.lineChart;
      case LBGraphType.PIE:
        return LineIcons.pieChart;
      case LBGraphType.BAR:
        return LineIcons.barChart;
      case LBGraphType.SPIDER:
        return LineIcons.spider;
      case LBGraphType.PANEL:
        return LineIcons.stop;
      case LBGraphType.TABLE:
        return LineIcons.table;
    }
  }
}

enum LBGrouping {
  WORKOUT,
  EXERCISE,
  SET,
  TAG,
  DATE,
  CATEGORY,
  NONE;

  List<LBGraphType> getValidGraphTypes() {
    switch (this) {
      case LBGrouping.WORKOUT:
      case LBGrouping.EXERCISE:
      case LBGrouping.SET:
      case LBGrouping.TAG:
      case LBGrouping.CATEGORY:
      case LBGrouping.NONE:
        return [
          LBGraphType.PIE,
          LBGraphType.BAR,
          LBGraphType.SPIDER,
          LBGraphType.PANEL,
          LBGraphType.TABLE,
        ];
      case LBGrouping.DATE:
        return [
          LBGraphType.TIMESERIES,
          LBGraphType.BAR,
          LBGraphType.PANEL,
          LBGraphType.TABLE,
        ];
    }
  }
}

enum LBColumn {
  REPS,
  TIME,
  WEIGHT,
  WORKOUT_DURATION,
}

enum LBCondensing {
  MAX,
  AVERAGE,
  MIN,
  SUM,
  COUNT,
  FIRST,
  ;
}

enum LBWeightNormalization {
  LBS,
  KG,
}

class LogBuilder {
  // state fields
  late String id;
  late String title;
  late List<LogBuilderItem> items;
  late LBGrouping grouping;
  late LBColumn column;
  late LBCondensing condensing;
  late LBWeightNormalization weightNormalization;
  late LBGraphType graphType;
  int? limit;
  Color? color;
  Color? backgroundColor;
  late int version;
  late bool showXAxis;
  late bool showYAxis;
  late bool showLegend;
  late bool showTitle;
  late LogBuilderDate date;

  // runtime fields
  int numberOfRecordsEvaluated = 0;

  LogBuilder({
    this.title = "",
    List<LogBuilderItem>? items,
    this.grouping = LBGrouping.DATE,
    this.column = LBColumn.WEIGHT,
    this.condensing = LBCondensing.MAX,
    this.weightNormalization = LBWeightNormalization.KG,
    this.graphType = LBGraphType.TIMESERIES,
    this.limit,
    this.version = 1,
    this.color,
    this.backgroundColor,
    LogBuilderDate? date,
    this.showXAxis = true,
    this.showYAxis = true,
    this.showLegend = true,
    this.showTitle = true,
  }) {
    id = const Uuid().v4();
    this.items = items ?? [];
    this.date = date ?? LogBuilderDate();
  }

  LogBuilder copy() {
    var b = LogBuilder(
      title: title,
      items: items.map((item) => item.copy()).toList(),
      grouping: grouping,
      column: column,
      condensing: condensing,
      weightNormalization: weightNormalization,
      graphType: graphType,
      color: color,
      limit: limit,
      version: version,
    );
    b.id = id;
    b.numberOfRecordsEvaluated = numberOfRecordsEvaluated;
    return b;
  }

  LogBuilder.fromJson(dynamic json) {
    // process the payload shape
    id = json['id'];
    var raw = jsonDecode(json['data']);

    title = raw['title'];
    items = [];
    for (var i in raw['items']) {
      items.add(LogBuilderItem.fromJson(i));
    }
    grouping = LBGrouping.values
            .firstWhereOrNull((element) => element.name == raw['grouping']) ??
        LBGrouping.values.first;
    column = LBColumn.values
            .firstWhereOrNull((element) => element.name == raw['column']) ??
        LBColumn.values.first;
    condensing = LBCondensing.values
            .firstWhereOrNull((element) => element.name == raw['condensing']) ??
        LBCondensing.values.first;
    weightNormalization = LBWeightNormalization.values.firstWhereOrNull(
            (element) => element.name == raw['weightNormalization']) ??
        LBWeightNormalization.values.first;
    graphType = LBGraphType.values
            .firstWhereOrNull((element) => element.name == raw['graphType']) ??
        LBGraphType.values.first;
    limit = raw['limit'];
    if (raw['color'] != null && raw['color'] != "") {
      color = ColorUtil.hexToColor(raw['color']);
    }
    if (raw['backgroundColor'] != null && raw['backgroundColor'] != "") {
      backgroundColor = ColorUtil.hexToColor(raw['backgroundColor']);
    }
    version = raw['version'];
    showXAxis = raw['showXAxis'];
    showYAxis = raw['showYAxis'];
    showLegend = raw['showLegend'];
    showTitle = raw['showTitle'];
    date = LogBuilderDate.fromJson(raw['date']);
  }

  num getColumnValue(LogRow row) {
    switch (column) {
      case LBColumn.REPS:
        return row.reps;
      case LBColumn.TIME:
        return row.time;
      case LBColumn.WEIGHT:
        return row.normalizedWeight;
      case LBColumn.WORKOUT_DURATION:
        return row.workoutLogDuration;
    }
  }

  String formatValue(num value) {
    if (condensing == LBCondensing.COUNT) {
      return value.toInt().toString();
    }

    switch (column) {
      case LBColumn.REPS:
      case LBColumn.WEIGHT:
        var val = double.parse(value.toDouble().toStringAsFixed(2));
        var valStr = "";
        if (val == val.toInt()) {
          valStr = val.toInt().toString();
        } else {
          valStr = val.toStringAsFixed(2);
        }
        if (column == LBColumn.WEIGHT) {
          return "$valStr ${weightNormalization.name.toLowerCase()}";
        } else {
          return valStr;
        }
      case LBColumn.TIME:
      case LBColumn.WORKOUT_DURATION:
        return formatHHMMSS(value.toInt());
    }
  }

  String titleBuilder(DataModel dmodel, Tuple2<Object, num> item,
      {String separator = "\n", bool includeValue = true}) {
    switch (grouping) {
      case LBGrouping.NONE:
      case LBGrouping.WORKOUT:
        var workout = dmodel.workouts
                .firstWhereOrNull((element) => element.workoutId == item.v1) ??
            dmodel.workoutTemplates
                .firstWhereOrNull((element) => element.workoutId == item.v1);
        if (!includeValue) {
          return workout?.title ?? item.v1.toString();
        }
        return "${workout?.title ?? item.v1.toString()}$separator${formatValue(item.v2)}";
      case LBGrouping.EXERCISE:
        var exercise = dmodel.exercises.firstWhereOrNull(
            (element) => element.exerciseId == item.v1.toString());
        if (!includeValue) {
          return exercise?.title ?? item.v1.toString();
        }
        return "${exercise?.title ?? item.v1.toString()}$separator${formatValue(item.v2)}";
      case LBGrouping.SET:
        if (!includeValue) {
          return "Set ${item.v1}";
        }
        return "Set ${item.v1}$separator${formatValue(item.v2)}";
      case LBGrouping.CATEGORY:
      case LBGrouping.TAG:
        if (!includeValue) {
          return item.v1.toString();
        }
        return "${item.v1}$separator${formatValue(item.v2)}";
      case LBGrouping.DATE:
        if (!includeValue) {
          return formatDateTime(item.v1 as DateTime);
        }
        return "${formatDateTime(item.v1 as DateTime)}$separator${formatValue(item.v2)}";
    }
  }

  Color getColor(BuildContext context, {Tuple2<Object, num>? item}) {
    if (color != null) {
      return color!;
    }
    if (item == null) {
      return Theme.of(context).colorScheme.primary;
    }
    return ColorUtil.random(item.v1.toString());
  }

  Future<List<LogRow>> queryDB(
    Database db, {
    LogBuilderDate? date,
  }) async {
    try {
      // get the range dates
      var builderDate = date ?? this.date;
      var range = builderDate.getRange();

      // handle the weight normalization
      String wn = "";
      switch (weightNormalization) {
        case LBWeightNormalization.LBS:
          wn =
              "WHEN elm.weightPost = 'kg' THEN ROUND(elm.weight * 2.20462, 2) ELSE elm.weight";
          break;
        case LBWeightNormalization.KG:
          wn =
              "WHEN elm.weightPost = 'lbs' THEN ROUND(elm.weight * 0.453592, 2) ELSE elm.weight";
          break;
      }
      var query = """
        WITH RankedMeta AS (
            SELECT 
                elm.*,
                ROW_NUMBER() OVER (PARTITION BY elm.exerciseLogId) AS setPosition,
                CASE 
                    $wn
                END AS normalizedWeight,
                (
                    SELECT GROUP_CONCAT(t.title, ', ')
                    FROM exercise_log_meta_tag elmt
                    JOIN tag t ON elmt.tagId = t.tagId
                    WHERE elmt.exerciseLogMetaId = elm.exerciseLogMetaId
                ) AS tags
            FROM exercise_log_meta elm
            WHERE elm.created >= DATETIME('${(range.v1).toIso8601String()}')
            AND elm.created <= DATETIME('${(range.v2).toIso8601String()}')
        )

        SELECT
            elm.*, el.*, c.title as category, c.categoryId as categoryId, wl.title as workoutLogTitle, wl.duration as workoutLogDuration
        FROM RankedMeta AS elm
        JOIN exercise_log AS el ON el.exerciseLogId = elm.exerciseLogId
        LEFT JOIN workout_log wl ON wl.workoutLogId = el.workoutLogId
        JOIN category AS c ON c.categoryId = el.category
      """;

      // add the custom query items
      for (var item in items) {
        query += item.format();
      }
      if (limit != null) {
        query += " LIMIT $limit";
      }
      query += ";";

      // query the database
      var raw = await db.rawQuery(query);
      numberOfRecordsEvaluated = raw.length;
      List<LogRow> rows = [];
      for (var i in raw) {
        rows.add(LogRow.fromJson(i));
      }
      return rows;
    } catch (e, stack) {
      print(e);
      print(stack);
      return [];
    }
  }

  Map<Object, List<LogRow>> groupData(List<LogRow> data) {
    Map<Comparable, List<LogRow>> grouped = {};
    switch (grouping) {
      case LBGrouping.WORKOUT:
        grouped = data.groupListsBy((element) => element.workoutLogTitle);
        break;
      case LBGrouping.EXERCISE:
        grouped = data.groupListsBy((element) => element.exerciseId);
        break;
      case LBGrouping.SET:
        grouped = data.groupListsBy((element) => element.setPosition);
        break;
      case LBGrouping.CATEGORY:
        grouped = data.groupListsBy((element) => element.category);
        break;
      case LBGrouping.DATE:
        grouped = data.groupListsBy((element) {
          return DateTime.parse(
            "${element.created.year}-${element.created.month < 10 ? '0${element.created.month}' : element.created.month}-${element.created.day < 10 ? '0${element.created.day}' : element.created.day}",
          );
        });
        break;
      case LBGrouping.TAG:
        /** It should be noted that grouping by tags will result in a record
         * being inserted into the map multiple times, based on the number of 
         * tags that were added onto the exercise log.
         * 
         * This may be a limitation in the future when it comes to performing
         * further calculations of averages later down the line
         */
        for (var i in data) {
          // ignore records without
          late List<String> tags;
          if (i.tags.isNotEmpty) {
            tags = i.tags.split(",");
          } else {
            tags = ["N/A"];
          }

          for (var t in tags) {
            if (grouped.containsKey(t.trim())) {
              grouped[t.trim()]!.add(i);
            } else {
              grouped[t.trim()] = [i];
            }
          }
        }
        break;
      case LBGrouping.NONE:
        grouped = {"Data": data};
    }

    // sort the data for consistency
    var sorted = Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return sorted;
  }

  List<Tuple2<Object, num>> getGraphData(
    Map<Object, List<LogRow>> grouped,
  ) {
    List<Tuple2<Object, num>> res = [];

    // if (condensing == LBCondensing.COUNT && grouping != LBGrouping.TAG) {
    // if (condensing == LBCondensing.COUNT) {
    //   for (var i in grouped.entries) {
    //     res.add(
    //       Tuple2<Object, num>(
    //         i.key,
    //         // i.value.groupListsBy((element) => element.exerciseId).length,
    //         i.value.length,
    //       ),
    //     );
    //   }
    //   return res;
    // }

    for (var i in grouped.entries) {
      num total = 0;
      num count = 0;
      num max = double.negativeInfinity;
      num min = double.infinity;
      for (var item in i.value) {
        switch (column) {
          case LBColumn.WORKOUT_DURATION:
          case LBColumn.REPS:
            num value = getColumnValue(item);
            total += value;
            count += 1;
            if (value > max) {
              max = value;
            }
            if (value < min) {
              min = value;
            }
            break;
          case LBColumn.WEIGHT:
            if ([ExerciseType.weight].contains(item.type)) {
              num value = getColumnValue(item);
              total += value;
              count += 1;
              if (value > max) {
                max = value;
              }
              if (value < min) {
                min = value;
              }
            }
            break;
          case LBColumn.TIME:
            if ([ExerciseType.timed, ExerciseType.duration]
                .contains(item.type)) {
              num value = getColumnValue(item);
              total += value;
              count += 1;
              if (value > max) {
                max = value;
              }
              if (value < min) {
                min = value;
              }
            }
            break;
        }

        // if only evaluating first, then do not parse the rest of the rows
        if (condensing == LBCondensing.FIRST && count != 0) {
          break;
        }
      }

      if (count == 0) {
        continue;
      }

      switch (condensing) {
        case LBCondensing.MAX:
          res.add(Tuple2(i.key, max));
          break;
        case LBCondensing.AVERAGE:
          res.add(Tuple2(i.key, total / count));
          break;
        case LBCondensing.MIN:
          res.add(Tuple2(i.key, min));
          break;
        case LBCondensing.COUNT:
          res.add(Tuple2(i.key, count));
          break;
        case LBCondensing.SUM:
        case LBCondensing.FIRST:
          // FIRST will only parse a single row
          res.add(Tuple2(i.key, total));
          break;
      }
    }

    return res;
  }

  String generateTitle() {
    var base = "${condensing.name} ${column.name} by ${grouping.name}";
    if (items.isNotEmpty) {
      base += " where";
    }
    items.forEachIndexed((index, element) {
      if (index != 0) {
        base += " ${element.addition.name}";
      }
      base +=
          " ${element.column.toHumanReadable()} ${element.modifier.toHumanReadable()} ${element.values}";
    });
    return base;
  }

  String get graphTitle {
    if (title == "") {
      return generateTitle();
    }
    return title;
  }

  // DO NOT INSERT INTO THE DATABASE
  // use the `toPayload()` method instead.
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "items": items.map((e) => e.toMap()).toList(),
      "grouping": grouping.name,
      "column": column.name,
      "condensing": condensing.name,
      "weightNormalization": weightNormalization.name,
      "graphType": graphType.name,
      "limit": limit,
      "color": color?.toHex(),
      "backgroundColor": backgroundColor?.toHex(),
      "version": version,
      "showXAxis": showXAxis,
      "showYAxis": showYAxis,
      "showLegend": showLegend,
      "showTitle": showTitle,
      "date": date.toMap(),
    };
  }

  // shape of the object inside of the database
  Map<String, dynamic> toPayload() {
    return {
      "id": id,
      "title": title,
      "grouping": grouping.name,
      "column": column.name,
      "condensing": condensing.name,
      "weightNormalization": weightNormalization.name,
      "graphType": graphType.name,
      "data": jsonEncode(toMap()),
    };
  }
}
