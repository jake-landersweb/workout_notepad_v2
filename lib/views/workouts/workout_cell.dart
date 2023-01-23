import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/workouts/workout_detail.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class WorkoutCell extends StatefulWidget {
  const WorkoutCell({
    super.key,
    required this.wc,
  });
  final WorkoutCategories wc;

  @override
  State<WorkoutCell> createState() => _WorkoutCellState();
}

class _WorkoutCellState extends State<WorkoutCell> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return sui.Button(
      onTap: () {
        sui.Navigate(
          context,
          WorkoutDetail(workout: widget.wc.workout),
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
              if (widget.wc.workout.icon.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: widget.wc.workout.getIcon(size: 40),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.wc.workout.title,
                      style: ttSubTitle(context, color: dmodel.color),
                    ),
                    if (widget.wc.workout.description?.isNotEmpty ?? false)
                      Text(
                        widget.wc.workout.description!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: dmodel.accentColor(context)),
                      ),
                    if (widget.wc.categories.isNotEmpty) _cat(context),
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

  Widget _cat(BuildContext context) {
    String t = "";
    for (int i = 0; i < widget.wc.categories.length; i++) {
      t = "$t${widget.wc.categories[i].uppercase()}";
      if (i < widget.wc.categories.length - 1) {
        t = "$t, ";
      }
    }
    return Text(t);
  }
}
