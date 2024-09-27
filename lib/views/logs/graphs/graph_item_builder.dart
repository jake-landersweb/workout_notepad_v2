import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/colored_cell.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder_item.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/model/search_model.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/color.dart';
import 'package:workout_notepad_v2/utils/icons.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

class GraphItemBuilder extends StatefulWidget {
  const GraphItemBuilder({
    super.key,
    this.item,
    required this.onSave,
  });
  final LogBuilderItem? item;
  final FutureOr<void> Function(BuildContext context, LogBuilderItem item)
      onSave;

  @override
  State<GraphItemBuilder> createState() => _GraphItemBuilderState();
}

class _GraphItemBuilderState extends State<GraphItemBuilder> {
  late LogBuilderItem _item;

  @override
  void initState() {
    _item = widget.item?.copy() ?? LogBuilderItem();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderBar.sheet(
      title: widget.item == null ? "New Condition" : "Edit Condition",
      leading: const [CloseButton2()],
      trailing: [
        Clickable(
          onTap: () {
            widget.onSave(context, _item);
            Navigator.of(context).pop();
          },
          child: Text(
            "Save",
            style:
                ttLabel(context, color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
      children: [
        const SizedBox(height: 32),
        SegmentedPicker(
          selection: _item.addition,
          selections: LBIAddition.values,
          titles: LBIAddition.values.map((e) => e.name).toList(),
          style: SegmentedPickerStyle(
            backgroundColor: AppColors.cell(context),
            height: 45,
          ),
          onSelection: ((p0) {
            setState(() {
              _item.addition = p0;
            });
          }),
        ),
        _label("Column"),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i in LBIColumn.values)
              ColoredCell(
                onTap: () {
                  // handle the change in value
                  switch (i) {
                    case LBIColumn.EXERCISE_ID:
                    case LBIColumn.TITLE:
                    case LBIColumn.TAGS:
                    case LBIColumn.CATEGORY:
                      _item.values = "";
                      break;
                    case LBIColumn.REPS:
                    case LBIColumn.WEIGHT:
                    case LBIColumn.TIME:
                      if (int.tryParse(_item.values) == null) {
                        _item.values = "0";
                      }
                      break;
                  }

                  // check if the selected condition is valid
                  var validConditons = i.getValidModifiers();
                  if (!validConditons.contains(_item.modifier)) {
                    _item.modifier = validConditons[0];
                  }

                  // set the state
                  setState(() {
                    _item.column = i;
                  });
                },
                title: i.toHumanReadable(),
                on: _item.column == i,
              ),
          ],
        ),
        _label("Condition"),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i in LBIModifier.values)
              ColoredCell(
                onTap: () {
                  setState(() {
                    _item.modifier = i;
                  });
                },
                title: i.toHumanReadable(),
                on: _item.modifier == i,
                disabled: !_item.column.getValidModifiers().contains(i),
              ),
          ],
        ),
        _label("Value(s)"),
        _getValueCreator(context),
      ],
    );
  }

  Widget _label(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Text(title, style: ttLabel(context)),
    );
  }

  Widget _getValueCreator(BuildContext context) {
    switch (_item.column) {
      case LBIColumn.EXERCISE_ID:
        DataModel dmodel = context.read();
        SearchModel searchModel = context.watch();

        return Column(
          children: [
            const SizedBox(height: 16),
            searchModel.header(
              context: context,
              dmodel: dmodel,
              labelText: "Search ...",
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                for (var i in dmodel.exercises
                    .where(((element) =>
                        _item.values.contains(element.exerciseId)))
                    .toList())
                  ExerciseCell(
                    exercise: i,
                    padding: const EdgeInsets.only(bottom: 8),
                    onTap: () {
                      if (_item.values.contains(i.exerciseId)) {
                        _item.values =
                            _item.values.replaceAll(i.exerciseId, "");
                      }
                      setState(() {
                        _item.values = _item.values
                            .split(",")
                            .map((e) => e.trim())
                            .whereNot((element) => element.isEmpty)
                            .join(",");
                      });
                    },
                  ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Divider(),
            ),
            for (var i in searchModel.search(dmodel.exercises))
              if (!_item.values.contains(i.exerciseId))
                ExerciseCell(
                  exercise: i,
                  padding: const EdgeInsets.only(bottom: 8),
                  onTap: () {
                    if (_item.values.contains(i.title)) {
                      _item.values = _item.values.replaceAll(i.exerciseId, "");
                    } else {
                      _item.values += ",${i.exerciseId}";
                    }
                    setState(() {
                      _item.values = _item.values
                          .split(",")
                          .map((e) => e.trim())
                          .whereNot((element) => element.isEmpty)
                          .join(",");
                    });
                  },
                ),
          ],
        );
      case LBIColumn.TITLE:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.cell(context),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Field(
                labelText: "Text here ...",
                value: _item.values,
                showBackground: true,
                onChanged: (val) {
                  setState(() {
                    _item.values = val;
                  });
                },
              ),
            ),
          ],
        );
      case LBIColumn.TAGS:
        var dmodel = context.read<DataModel>();
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i in dmodel.tags)
              ColoredCell(
                onTap: () {
                  if (_item.values.contains(i.title)) {
                    _item.values = _item.values.replaceAll(i.title, "");
                  } else {
                    _item.values += ",${i.title}";
                  }
                  setState(() {
                    _item.values = _item.values
                        .split(",")
                        .map((e) => e.trim())
                        .whereNot((element) => element.isEmpty)
                        .join(",");
                  });
                },
                title: i.title,
                isTag: true,
                size: ColoredCellSize.medium,
                on: _item.values.contains(i.title),
              ),
          ],
        );
      case LBIColumn.REPS:
      case LBIColumn.WEIGHT:
        return NumberPicker(
          initialValueStr: _item.values,
          onChanged: (val) {
            setState(() {
              _item.values = "$val";
            });
          },
        );
      case LBIColumn.TIME:
        return TimePicker.fromSeconds(
          seconds: int.tryParse(_item.values) ?? 0,
          onChanged: (val) {
            setState(() {
              _item.values = "$val";
            });
          },
        );
      case LBIColumn.CATEGORY:
        DataModel dmodel = context.read();
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i in dmodel.categories)
              Clickable(
                onTap: () {
                  if (_item.values.contains(i.title)) {
                    _item.values = _item.values.replaceAll(i.title, "");
                  } else {
                    _item.values += ",${i.title}";
                  }
                  setState(() {
                    _item.values = _item.values
                        .split(",")
                        .map((e) => e.trim())
                        .whereNot((element) => element.isEmpty)
                        .join(",");
                  });
                },
                child: GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _item.values.contains(i.title)
                          ? Theme.of(context).colorScheme.primary
                          : AppColors.cell(context),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (i.icon != "")
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: getImageIcon(i.icon, size: 25),
                            ),
                          Text(
                            i.title.capitalize(),
                            style: TextStyle(
                              color: _item.values.contains(i.title)
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
    }
    return Container();
  }
}
