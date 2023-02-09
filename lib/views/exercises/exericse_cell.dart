import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/exercise_set.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/exercises/category_bubble.dart';
import 'package:workout_notepad_v2/views/root.dart';

class ExerciseCell extends StatelessWidget {
  const ExerciseCell({
    super.key,
    required this.exercise,
    this.trailingIcon,
    this.onTap,
    this.showBackground = true,
  });
  final Exercise exercise;
  final VoidCallback? onTap;
  final IconData? trailingIcon;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    if (onTap != null) {
      return sui.Button(
        onTap: onTap!,
        child: _body(context, dmodel),
      );
    }
    return _body(context, dmodel);
  }

  Container _body(BuildContext context, DataModel dmodel) {
    return Container(
      decoration: BoxDecoration(
        color: showBackground ? sui.CustomColors.cellColor(context) : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                if (exercise.icon.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: exercise.getIcon(),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.title,
                        style: ttLabel(context, color: dmodel.color),
                      ),
                      Text("${exercise.sets} x ${exercise.reps}",
                          style: ttBody(context)),
                      if (exercise.category.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: CategoryBuble(text: exercise.category),
                        ),
                    ],
                  ),
                ),
                if (trailingIcon != null)
                  Icon(
                    trailingIcon,
                    color: dmodel.accentColor(context),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
