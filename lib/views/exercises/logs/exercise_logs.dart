import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;

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
      builder: ((context, child) {
        return Navigator(
          onGenerateRoute: (settings) {
            return MaterialWithModalsPageRoute(
              settings: settings,
              builder: (context) => _body(context),
            );
          },
        );
      }),
    );
  }

  Widget _body(BuildContext context) {
    var elmodel = Provider.of<ELModel>(context);
    var dmodel = Provider.of<DataModel>(context);
    return comp.InteractiveSheet(
      headerPadding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      header: (context) {
        return SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        comp.CloseButton(
                          useRoot: true,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withOpacity(0.7),
                        ),
                        if (elmodel.exercise.type == 0)
                          Clickable(
                            onTap: () {
                              elmodel.toggleIsLbs();
                            },
                            child: Text(
                              elmodel.isLbs ? "lbs" : "kg",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimary
                                    .withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                              ),
                            ),
                          )
                        else
                          Container(),
                      ],
                    ),
                    Text(
                      elmodel.exercise.title,
                      style: ttTitle(
                        context,
                        size: 32,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              _actions(context, elmodel),
            ],
          ),
        );
      },
      builder: (context) {
        return PageView(
          controller: elmodel.pageController,
          onPageChanged: (value) => elmodel.onPageChange(value),
          children: const [
            ELOverview(),
            ELWeightChart(),
            ELBarChart(),
          ],
        );
      },
    );
  }

  Widget _actions(BuildContext context, ELModel elmodel) {
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        children: [
          const SizedBox(width: 16),
          _actionCell(
            context: context,
            elmodel: elmodel,
            index: 0,
            icon: Icons.view_stream_rounded,
          ),
          const SizedBox(width: 16),
          _actionCell(
            context: context,
            elmodel: elmodel,
            index: 1,
            icon: Icons.show_chart_rounded,
          ),
          const SizedBox(width: 16),
          _actionCell(
            context: context,
            elmodel: elmodel,
            index: 2,
            icon: Icons.bar_chart_rounded,
          ),
          // const SizedBox(width: 16),
          // _actionCell(
          //   context: context,
          //   elmodel: elmodel,
          //   index: 3,
          //   icon: Icons.scatter_plot_rounded,
          // ),
        ],
      ),
    );
  }

  Widget _actionCell({
    required BuildContext context,
    required ELModel elmodel,
    required int index,
    required IconData icon,
  }) {
    final bgColor = index == elmodel.currentIndex
        ? Theme.of(context).colorScheme.onPrimary
        : Colors.transparent;
    final textColor = index == elmodel.currentIndex
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onPrimary;
    return Clickable(
      onTap: () => elmodel.navigateTo(index),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 2,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: textColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
