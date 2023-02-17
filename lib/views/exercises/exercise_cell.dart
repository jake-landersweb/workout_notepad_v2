import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/exercise_set.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

class ExerciseCell extends StatelessWidget {
  const ExerciseCell({
    super.key,
    required this.exercise,
    this.trailingIcon,
    this.onTap,
    this.showBackground = true,
    this.padding = const EdgeInsets.only(bottom: 16),
  });
  final Exercise exercise;
  final VoidCallback? onTap;
  final IconData? trailingIcon;
  final bool showBackground;
  final EdgeInsets padding;

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

  Widget _body(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: padding,
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: Column(
          children: [
            Row(
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
                        style: ttLabel(
                          context,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (exercise.category.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                              child: Text(
                                exercise.category.uppercase(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailingIcon != null)
                  Icon(
                    trailingIcon,
                    color: dmodel.accentColor(context),
                  )
                else
                  exercise.info(
                    context,
                    style: ttBody(
                      context,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
