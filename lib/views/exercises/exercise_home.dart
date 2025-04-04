import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    var dmodel = context.watch<DataModel>();
    var searchModel = Provider.of<SearchModel>(context);
    return Scaffold(
      body: HeaderBar(
        title: "Exercises",
        isLarge: true,
        refreshable: true,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 300));
          await dmodel.refreshExercises();
        },
        // leading: const [BackButton2()],
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
          SizedBox(height: (dmodel.workoutState == null ? 100 : 130)),
        ],
      ),
    );
  }
}
