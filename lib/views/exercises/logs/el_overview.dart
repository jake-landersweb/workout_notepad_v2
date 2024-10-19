import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

class ELOverview extends StatefulWidget {
  const ELOverview({super.key});

  @override
  State<ELOverview> createState() => _ELOverviewState();
}

class _ELOverviewState extends State<ELOverview> {
  final double pad = 16;

  @override
  Widget build(BuildContext context) {
    var elmodel = Provider.of<ELModel>(context);
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: Column(
          children: [
            _overview(context, elmodel),
            const ELRaw(),
          ],
        ),
      ),
    );
  }

  Widget _overview(BuildContext context, ELModel elmodel) {
    switch (elmodel.exercise.type) {
      case ExerciseType.distance:
      case ExerciseType.weight:
      case ExerciseType.timed:
      case ExerciseType.duration:
        return Column(
          children: [
            Row(
              children: [
                _container(
                  context,
                  _basicBody(
                    context,
                    elmodel.logs.length.toString(),
                    "Total Logs",
                  ),
                ),
              ],
            ),
            SizedBox(height: pad / 2),
            Row(
              children: [
                _container(
                  context,
                  _basicBody(
                    context,
                    elmodel.avgVal,
                    "Avg",
                  ),
                ),
                SizedBox(width: pad / 2),
                _container(
                  context,
                  _basicBody(
                    context,
                    elmodel.avgReps.toStringAsFixed(2),
                    "Avg Reps",
                  ),
                ),
              ],
            ),
            SizedBox(height: pad / 2),
            Row(
              children: [
                _container(
                  context,
                  _basicBody(
                    context,
                    elmodel.maxVal,
                    "Max",
                  ),
                ),
                SizedBox(width: pad / 2),
                _container(
                  context,
                  _basicBody(
                    context,
                    elmodel.maxReps.round().toString(),
                    "Max Reps",
                  ),
                ),
              ],
            ),
            SizedBox(height: pad / 2),
            Row(
              children: [
                _container(
                  context,
                  _basicBody(
                    context,
                    elmodel.minVal,
                    "Min",
                  ),
                ),
                SizedBox(width: pad / 2),
                _container(
                  context,
                  _basicBody(
                    context,
                    elmodel.minReps.round().toString(),
                    "Min Reps",
                  ),
                ),
              ],
            ),
          ],
        );
      case ExerciseType.stretch:
      case ExerciseType.bw:
        return Column(
          children: [
            Row(
              children: [
                _container(
                  context,
                  _basicBody(
                    context,
                    elmodel.logs.length.toString(),
                    "Total Logs",
                  ),
                ),
                SizedBox(width: pad / 2),
                _container(
                  context,
                  _basicBody(
                    context,
                    elmodel.avgReps.toStringAsFixed(2),
                    "Avg Reps",
                  ),
                ),
              ],
            ),
            SizedBox(height: pad / 2),
            Row(
              children: [
                _container(
                  context,
                  _basicBody(
                    context,
                    elmodel.maxReps.round().toString(),
                    "Max Reps",
                  ),
                ),
                SizedBox(width: pad / 2),
                _container(
                  context,
                  _basicBody(
                    context,
                    elmodel.minReps.round().toString(),
                    "Min Reps",
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }

  Widget _container(BuildContext context, Widget child, {double height = 100}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cell(context),
          borderRadius: BorderRadius.circular(10),
        ),
        height: height,
        child: Center(
          child: child,
        ),
      ),
    );
  }

  Widget _basicBody(BuildContext context, String title, String caption) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AutoSizeText(
          title,
          maxFontSize: 32,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          caption,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color:
                Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
