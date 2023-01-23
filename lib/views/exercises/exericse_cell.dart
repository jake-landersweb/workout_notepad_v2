import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/category_bubble.dart';
import 'package:workout_notepad_v2/views/root.dart';

class ExerciseCell extends StatefulWidget {
  const ExerciseCell({
    super.key,
    required this.exercise,
  });
  final Exercise exercise;

  @override
  State<ExerciseCell> createState() => _ExerciseCellState();
}

class _ExerciseCellState extends State<ExerciseCell> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return sui.Button(
      onTap: () {
        sui.showFloatingSheet(
          context: context,
          builder: (context) => ExerciseDetail(exercise: widget.exercise),
          title: widget.exercise.title,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: sui.CustomColors.cellColor(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              if (widget.exercise.icon.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: widget.exercise.getIcon(),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.exercise.title,
                      style: ttLabel(context, color: dmodel.color),
                    ),
                    Text("${widget.exercise.sets} x ${widget.exercise.reps}",
                        style: ttBody(context)),
                    if (widget.exercise.category.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: CategoryBuble(text: widget.exercise.category),
                      ),
                  ],
                ),
              ),
              Icon(
                LineIcons.verticalEllipsis,
                color: dmodel.accentColor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
