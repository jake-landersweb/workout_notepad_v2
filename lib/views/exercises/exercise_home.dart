import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/back_button.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';

import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/model/search_model.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;

class ExerciseHome extends StatefulWidget {
  const ExerciseHome({
    super.key,
    this.showBackButton = true,
  });
  final bool showBackButton;

  @override
  State<ExerciseHome> createState() => _ExerciseHomeState();
}

class _ExerciseHomeState extends State<ExerciseHome> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    var searchModel = Provider.of<SearchModel>(context);
    return Scaffold(
      body: HeaderBar(
        title: "Exercises",
        isLarge: true,
        leading: const [BackButton2()],
        trailing: [
          comp.AddButton(onTap: () {
            comp.cupertinoSheet(
              context: context,
              builder: (context) => const CEERoot(isCreate: true),
            );
          })
        ],
        children: [
          const SizedBox(height: 16),
          searchModel.header(
            context: context,
            dmodel: dmodel,
            labelText: "Search ...",
          ),
          const SizedBox(height: 16),
          for (var i in searchModel.search(dmodel.exercises))
            ExerciseCell(
              exercise: i,
              padding: const EdgeInsets.only(bottom: 8),
              onTap: () {
                comp.cupertinoSheet(
                  context: context,
                  builder: (context) => ExerciseDetail(exercise: i),
                );
              },
            ),
          SizedBox(
              height: (dmodel.workoutState == null ? 100 : 130) +
                  (dmodel.user!.offline ? 30 : 0)),
        ],
      ),
    );
  }
}
