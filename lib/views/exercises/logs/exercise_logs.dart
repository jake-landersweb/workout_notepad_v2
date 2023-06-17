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
                    const comp.CloseButton(),
                    Text(
                      elmodel.exercise.title,
                      style: ttTitle(context,
                          size: 32,
                          color: Theme.of(context).colorScheme.onBackground),
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
          children: [
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount: elmodel.logs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: index < elmodel.logs.length - 1 ? 16 : 0),
                  child: ELCell(log: elmodel.logs[index]),
                );
              },
            ),
            const ELWeightChart(),
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
            icon: Icons.receipt_long_outlined,
            title: "Overview",
          ),
          const SizedBox(width: 16),
          _actionCell(
            context: context,
            elmodel: elmodel,
            index: 1,
            icon: Icons.insights_rounded,
            title: "Weight Chart",
          ),
        ],
      ),
    );
  }

  Widget _actionCell({
    required BuildContext context,
    required ELModel elmodel,
    required int index,
    required IconData icon,
    required String title,
  }) {
    final bgColor = index == elmodel.currentIndex
        ? Theme.of(context).colorScheme.secondary
        : Colors.transparent;
    final textColor = index == elmodel.currentIndex
        ? Theme.of(context).colorScheme.onSecondary
        : Theme.of(context).colorScheme.secondary;
    return sui.Button(
      onTap: () => elmodel.navigateTo(index),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
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
              const SizedBox(width: 10),
              Text(
                title,
                style: ttLabel(
                  context,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
