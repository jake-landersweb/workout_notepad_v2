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
  final ExerciseBase exercise;
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
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(height: 50, width: 50),
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
                          child: IntrinsicWidth(
                            child: CategoryCell(title: exercise.category),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
