import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/colored_cell.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder_item.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/color.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

class GraphItemCell extends StatefulWidget {
  const GraphItemCell({
    super.key,
    required this.index,
    required this.item,
  });
  final int index;
  final LogBuilderItem item;

  @override
  State<GraphItemCell> createState() => _GraphItemCellState();
}

class _GraphItemCellState extends State<GraphItemCell> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 65,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColoredCell(
                  title: widget.item.addition.name,
                  size: ColoredCellSize.small,
                ),
              ],
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  widget.item.column.toHumanReadable(),
                  style: ttLabel(context),
                ),
                ColoredCell(
                  title: widget.item.modifier.toHumanReadable(),
                  size: ColoredCellSize.small,
                  bordered: true,
                  on: false,
                ),
                _getValues(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getValues(BuildContext context) {
    switch (widget.item.modifier) {
      case LBIModifier.EQUALS:
      case LBIModifier.NOT_EQUALS:
      case LBIModifier.LESS_THAN:
      case LBIModifier.GREATER_THAN:
        return Text(widget.item.values.capitalize(), style: ttLabel(context));
      case LBIModifier.CONTAINS:
      case LBIModifier.NOT_CONTAINS:
        DataModel dmodel = context.read();
        var items = widget.item.values.split(",");
        switch (widget.item.column) {
          case LBIColumn.EXERCISE_ID:
            return Column(
              children: [
                for (var i in dmodel.exercises
                    .where(((element) =>
                        widget.item.values.contains(element.exerciseId)))
                    .toList())
                  ExerciseCell(
                    exercise: i,
                    padding: const EdgeInsets.only(bottom: 8),
                    borderColor: AppColors.divider(context),
                  ),
              ],
            );
          case LBIColumn.CATEGORY:
            DataModel dmodel = context.read();
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i in dmodel.categories)
                  if (widget.item.values.contains(i.title))
                    CategoryCell(categoryId: i.categoryId),
              ],
            );
          case LBIColumn.TITLE:
          case LBIColumn.TAGS:
          case LBIColumn.REPS:
          case LBIColumn.WEIGHT:
          case LBIColumn.TIME:
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i in items)
                  ColoredCell(
                    title: i.trim(),
                    size: ColoredCellSize.small,
                    isTag: widget.item.column == LBIColumn.TAGS,
                  ),
              ],
            );
        }
    }
  }

  Widget _getPartialRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [],
    );
  }
}
