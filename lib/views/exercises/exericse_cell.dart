import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

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
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: dmodel.cellColor(context),
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
                        child: Container(
                          decoration: BoxDecoration(
                            color: dmodel.color[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                            child: Text(
                              widget.exercise.category.uppercase(),
                              style: ttBody(context, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                LineIcons.angleDoubleRight,
                color: dmodel.accentColor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
