import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';

import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class ExerciseCell extends StatelessWidget {
  const ExerciseCell({
    super.key,
    required this.exercise,
    this.trailingIcon,
    this.trailingWidget,
    this.onTap,
    this.showBackground = true,
    this.padding = const EdgeInsets.only(bottom: 8),
    this.borderColor,
  });
  final Exercise exercise;
  final VoidCallback? onTap;
  final IconData? trailingIcon;
  final Widget? trailingWidget;
  final bool showBackground;
  final EdgeInsets padding;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    if (onTap != null) {
      return Clickable(
        onTap: onTap!,
        child: _body(context, dmodel),
      );
    }
    return _body(context, dmodel);
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: padding,
      child: showBackground
          ? Container(
              decoration: BoxDecoration(
                  color: AppColors.cell(context),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: borderColor ?? AppColors.cell(context))),
              child: _content(context),
            )
          : _content(context),
    );
  }

  Widget _content(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          if (exercise.category.isNotEmpty) getIcon(dmodel),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (getCategoryTitle(dmodel).isNotEmpty)
                  Text(
                    getCategoryTitle(dmodel).capitalize(),
                    style: ttcaption(context),
                  ),
                Text(
                  exercise.title,
                  style: ttLabel(
                    context,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (trailingIcon != null)
            Icon(
              trailingIcon,
              color: Theme.of(context).colorScheme.primary,
            )
          else
            exercise.info(
              context,
              style: ttBody(
                context,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          if (trailingWidget != null) trailingWidget!,
        ],
      ),
    );
  }

  Widget getIcon(DataModel dmodel) {
    var match = dmodel.categories.firstWhere(
      (element) => element.categoryId == exercise.category,
      orElse: () => Category(categoryId: "", title: "", icon: ""),
    );
    if (match.icon.isEmpty) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: getImageIcon(match.icon, size: 40),
    );
  }

  String getCategoryTitle(DataModel dmodel) {
    if (exercise.category.isEmpty) {
      return "";
    }
    var match = dmodel.categories.firstWhere(
      (element) => element.categoryId == exercise.category,
      orElse: () => Category(categoryId: "", title: "", icon: ""),
    );
    if (match.icon.isEmpty) {
      return "";
    }
    return match.title;
  }
}
