import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/timer.dart';
import 'package:workout_notepad_v2/data/exercise_base.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class ELCell extends StatefulWidget {
  const ELCell({
    super.key,
    required this.log,
    this.showDate = true,
  });
  final ExerciseLog log;
  final bool showDate;

  @override
  State<ELCell> createState() => _ELCellState();
}

class _ELCellState extends State<ELCell> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showDate)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 0, 4),
              child: Text(
                widget.log.getCreatedFormatted(),
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
            color: AppColors.cell(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < widget.log.sets; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _cell(context, i, widget.log.metadata[i]),
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
          child: Column(
            children: [
              Center(
                child: Text(
                  "SET ${index + 1}",
                  style: ttBody(
                    context,
                    color: AppColors.subtext(context),
                  ),
                ),
              ),
              // assume single tag for now
              for (var i in meta.tags)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cell(context)[600],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                    child: Text(
                      i.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.subtext(context),
                      ),
                    ),
                  ),
                ),
            ],
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
    switch (widget.log.type) {
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
                widget.log.weightPost.toUpperCase(),
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
}
