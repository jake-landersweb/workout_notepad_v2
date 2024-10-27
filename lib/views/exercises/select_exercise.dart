import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/model/search_model.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

class SelectExercise extends StatefulWidget {
  const SelectExercise({
    super.key,
    required this.onSelect,
    this.title,
  });
  final Function(Exercise exercise) onSelect;
  final String? title;

  @override
  State<SelectExercise> createState() => _SelectExerciseState();
}

class _SelectExerciseState extends State<SelectExercise> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    var searchModel = Provider.of<SearchModel>(context);
    return HeaderBar.sheet(
      title: widget.title ?? "Select Exercise",
      trailing: const [CancelButton()],
      children: [
        const SizedBox(height: 16),
        WrappedButton(
          title: "Create New",
          type: WrappedButtonType.standard,
          icon: Icons.add_rounded,
          iconBg: Theme.of(context).colorScheme.primary,
          iconFg: Colors.white,
          onTap: () {
            cupertinoSheet(
              context: context,
              builder: (context) => CEERoot(
                isCreate: true,
                onAction: (e) {
                  widget.onSelect(e);
                  Navigator.of(context).pop();
                },
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        searchModel.header(
            context: context, dmodel: dmodel, labelText: "Search ..."),
        const SizedBox(height: 16),
        for (var i in searchModel.search(dmodel.exercises))
          Clickable(
            onTap: () {
              widget.onSelect(i);
              Navigator.of(context).pop();
            },
            child: ExerciseCell(exercise: i),
          ),
      ],
    );
  }
}
