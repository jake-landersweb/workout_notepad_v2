import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/data/exercise.dart';

import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/model/search_model.dart';
import 'package:workout_notepad_v2/utils/root.dart';
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
          Container(
            decoration: BoxDecoration(
              color: AppColors.cell(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border(context), width: 3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ImplicitlyAnimatedList<Exercise>(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                items: searchModel.search(dmodel.exercises),
                areItemsTheSame: (a, b) => a.exerciseId == b.exerciseId,
                insertDuration: const Duration(milliseconds: 500),
                removeDuration: const Duration(milliseconds: 200),
                // build items that stay in the list or are inserted
                itemBuilder: (context, animation, exercise, index) {
                  // Wrap the child in whatever transition you like:
                  return SizeFadeTransition(
                    animation: animation,
                    curve: Sprung.overDamped,
                    child: Column(
                      children: [
                        Clickable(
                          onTap: () {
                            comp.cupertinoSheet(
                              context: context,
                              builder: (context) =>
                                  ExerciseDetail(exercise: exercise),
                            );
                          },
                          child: Container(
                            key: ValueKey(exercise.exerciseId),
                            decoration: BoxDecoration(
                              color: AppColors.cell(context),
                            ),
                            child: ExerciseCell(
                              exercise: exercise,
                              padding: const EdgeInsets.only(bottom: 8),
                              showBackground: false,
                            ),
                          ),
                        ),
                        if (index <
                            searchModel.search(dmodel.exercises).length - 1)
                          Container(
                            height: 1,
                            width: double.infinity,
                            color: AppColors.divider(context),
                          ),
                      ],
                    ),
                  );
                },

                // // optional: how to animate removals
                // removeItemBuilder: (context, animation, person) {
                //   return FadeTransition(
                //     opacity: animation,
                //     child: ListTile(
                //       title: Text(person.name, style: TextStyle(color: Colors.red)),
                //     ),
                //   );
                // },
              ),
            ),
          ),
          SizedBox(height: (dmodel.workoutState == null ? 100 : 130)),
        ],
      ),
    );
  }
}
