import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/text_themes.dart';

class WECell extends StatefulWidget {
  const WECell({
    super.key,
    required this.exercise,
  });
  final Exercise exercise;

  @override
  State<WECell> createState() => _WECellState();
}

class _WECellState extends State<WECell> {
  List<Exercise> _children = [];

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    _children = await widget.exercise.getChildren();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return sui.Button(
      onTap: () {},
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              "${widget.exercise.sets} x ${widget.exercise.reps}",
              style: ttLabel(context, color: dmodel.color),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.exercise.title, style: ttLabel(context)),
                if (_children.isNotEmpty)
                  for (var i in _children) _superSet(context, i),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _superSet(BuildContext context, Exercise e) {
    return Text("Superset ${e.sets} x ${e.reps} ${e.title}",
        style: ttBody(context,
            color: sui.CustomColors.textColor(context).withOpacity(0.5)));
  }
}
