import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/workouts/workout_detail.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class WorkoutCell extends StatefulWidget {
  const WorkoutCell({
    super.key,
    required this.workout,
  });
  final Workout workout;

  @override
  State<WorkoutCell> createState() => _WorkoutCellState();
}

class _WorkoutCellState extends State<WorkoutCell> {
  List<String> _categories = [];

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    _categories = await widget.workout.getCategories();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return sui.Button(
      onTap: () {
        sui.Navigate(
          context,
          WorkoutDetail(workout: widget.workout),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: dmodel.cellColor(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              if (widget.workout.icon.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: widget.workout.getIcon(size: 40),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.workout.title,
                      style: ttSubTitle(context, color: dmodel.color),
                    ),
                    if (widget.workout.description?.isNotEmpty ?? false)
                      Text(
                        widget.workout.description!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: dmodel.accentColor(context)),
                      ),
                    if (_categories.isNotEmpty) _cat(context),
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
    for (int i = 0; i < _categories.length; i++) {
      t = "$t${_categories[i].uppercase()}";
      if (i < _categories.length - 1) {
        t = "$t, ";
      }
    }
    return Text(t);
  }
}
