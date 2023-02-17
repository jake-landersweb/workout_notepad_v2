import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/root.dart';

class ExerciseLogs extends StatefulWidget {
  const ExerciseLogs({
    super.key,
    required this.exercise,
  });
  final Exercise exercise;

  @override
  State<ExerciseLogs> createState() => _ExerciseLogsState();
}

class _ExerciseLogsState extends State<ExerciseLogs> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: ((context) => ELModel(exercise: widget.exercise)),
      builder: (context, child) => _body(context),
    );
  }

  Widget _body(BuildContext context) {
    var emodel = Provider.of<ELModel>(context);
    var dmodel = Provider.of<DataModel>(context);
    return comp.InteractiveSheet(
      header: (context) {
        return Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  comp.CloseButton(color: dmodel.color.shade200),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        emodel.exercise.title,
                        style: ttTitle(context, size: 32),
                      ),
                    ),
                  ),
                ],
              ),
              if (emodel.exercise.description.isNotEmpty)
                Text(
                  emodel.exercise.description,
                  style: ttLabel(context, color: dmodel.color.shade200),
                ),
            ],
          ),
        );
      },
      builder: (context) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
            child: Column(
              children: [
                for (int i = 0; i < emodel.logs.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: i < emodel.logs.length - 1 ? 16 : 0),
                    child: ELCell(log: emodel.logs[i]),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
