import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/data/exercise_set.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/components/root.dart' as comp;

class CEWExerciseCell extends StatefulWidget {
  const CEWExerciseCell({
    super.key,
    required this.cewe,
    required this.handle,
    required this.index,
    required this.inDrag,
  });
  final CEWExercise cewe;
  final Handle handle;
  final int index;
  final bool inDrag;

  @override
  State<CEWExerciseCell> createState() => _CEWExerciseCellState();
}

class _CEWExerciseCellState extends State<CEWExerciseCell> {
  @override
  Widget build(BuildContext context) {
    var cmodel = Provider.of<CEWModel>(context);
    return AnimatedContainer(
      curve: Sprung(36),
      duration: const Duration(milliseconds: 700),
      color: widget.inDrag
          ? sui.CustomColors.cellColor(context)
          : sui.CustomColors.backgroundColor(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.cewe.exercise.title,
                          style: ttSubTitle(context,
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                      widget.handle,
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ExerciseItemGroup(exercise: widget.cewe.exercise),
          ),
          ImplicitlyAnimatedList(
            items: widget.cewe.children,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: ((context, animation, item, i) {
              return SizeFadeTransition(
                sizeFraction: 0.7,
                curve: Curves.easeInOut,
                animation: animation,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: sui.Button(
                    onTap: () {
                      sui.showFloatingSheet(
                        context: context,
                        builder: (context) => sui.FloatingSheet(
                          title: item.title,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 8),
                              ExerciseItemGroup(
                                exercise: item,
                                onChanged: () => setState(() {}),
                              ),
                              const SizedBox(height: 16),
                              comp.DeleteButton(
                                title: "Remove",
                                onTap: () {
                                  Navigator.of(context).pop();
                                  cmodel.removeExerciseChild(
                                    widget.index,
                                    item,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        item.title,
                                        style: ttLabel(
                                          context,
                                          color: sui.CustomColors.textColor(
                                              context),
                                        ),
                                      )),
                                    ],
                                  ),
                                  item.info(
                                    context,
                                    style: ttLabel(
                                      context,
                                      color: sui.CustomColors.textColor(context)
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(LineIcons.verticalEllipsis),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            areItemsTheSame: ((oldItem, newItem) =>
                oldItem.exerciseSetId == newItem.exerciseSetId),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: sui.Button(
              onTap: () {
                comp.cupertinoSheet(
                  context: context,
                  builder: (context) {
                    return SelectExercise(
                      onSelect: (e) {
                        cmodel.addExerciseChild(
                          widget.index,
                          ExerciseSet.fromExercise(
                            cmodel.workout.workoutId,
                            widget.cewe.exercise,
                            e,
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: sui.CustomColors.cellColor(context),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(LineIcons.plus),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.index < cmodel.exercises.length - 1)
            const Divider(height: 0.5),
        ],
      ),
    );
  }
}
