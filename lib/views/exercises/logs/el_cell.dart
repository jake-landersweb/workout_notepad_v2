import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/colored_cell.dart';
import 'package:workout_notepad_v2/components/timer.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/exercises/logs/tag_group.dart';
import 'package:workout_notepad_v2/views/root.dart';

class ELCellLarge extends StatefulWidget {
  const ELCellLarge({
    super.key,
    required this.log,
  });
  final ExerciseLog log;

  @override
  State<ELCellLarge> createState() => _ELCellLargeState();
}

class _ELCellLargeState extends State<ELCellLarge> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cell(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 0, 2),
            child: Text(widget.log.title, style: ttLabel(context)),
          ),
          ELCell(log: widget.log, showDate: true),
        ],
      ),
    );
  }
}

class ELCell extends StatelessWidget {
  const ELCell({
    super.key,
    required this.log,
    this.showDate = true,
    this.backgroundColor,
  });
  final ExerciseLog log;
  final bool showDate;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDate)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 0, 4),
              child: Text(
                log.getCreatedFormatted(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppColors.subtext(context),
                ),
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.cell(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < log.metadata.length; i++)
                  Column(
                    children: [
                      _cell(context, i, log.metadata[i]),
                      SizedBox(
                        height: 32,
                        child: getRestText(i).isEmpty
                            ? Container()
                            : Center(
                                // child: Text(
                                //   getRestText(i),
                                //   style: ttcaption(context),
                                // ),
                                child: ColoredCell(
                                  title: getRestText(i),
                                  color: Colors.grey.withOpacity(0.5),
                                  size: ColoredCellSize.xs,
                                ),
                              ),
                      )
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _cell(BuildContext context, int index, ExerciseLogMeta meta) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SetGroup(
            title: "SET ${index + 1}",
            tagTitles: meta.tags.map((e) => e.title),
          ),
        ),
        Expanded(
          flex: 2,
          child: _post(context, meta),
        ),
      ],
    );
  }

  Widget _post(BuildContext context, ExerciseLogMeta meta) {
    switch (log.type) {
      case ExerciseType.weight:
        return Row(
          children: [
            Expanded(child: _itemCell(context, "REPS", meta.reps.toString())),
            Text(
              "*",
              style: ttLabel(
                context,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Expanded(
              child: _itemCell(
                context,
                meta.weightPost,
                meta.weight.toString(),
              ),
            ),
          ],
        );
      case ExerciseType.timed:
      case ExerciseType.duration:
        return Row(
          children: [
            Expanded(
              child: _itemCell(
                context,
                "",
                formatHHMMSS(meta.time),
              ),
            ),
          ],
        );
      case ExerciseType.bw:
        return Row(
          children: [
            Expanded(child: _itemCell(context, "REPS", meta.reps.toString())),
          ],
        );
    }
  }

  Widget _itemCell(BuildContext context, String title, String item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          item.toString(),
          style: ttTitle(
            context,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        if (title != "")
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.subtext(context),
            ),
          ),
      ],
    );
  }

  String getRestText(int i) {
    if (i == log.metadata.length - 1) {
      return "";
    }
    if (log.metadata[i].savedDate != null &&
        log.metadata[i + 1].savedDate != null) {
      return log.metadata[i + 1].savedDifference(log.metadata[i].savedDate);
    }
    return "";
  }
}
