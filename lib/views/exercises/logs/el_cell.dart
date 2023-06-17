import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;

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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showDate)
              Text(
                widget.log.getCreatedFormatted(),
                style: ttBody(
                  context,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            for (int i = 0; i < widget.log.sets; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _cell(context, i, widget.log.metadata[i]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cell(BuildContext context, int index, ExerciseLogMeta meta) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Center(
            child: Text(
              "SET ${index + 1}",
              style: ttBody(
                context,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
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
      case 1:
        return Row(
          children: [
            Expanded(
              child: _itemCell(
                context,
                widget.log.timePost.toUpperCase(),
                meta.time,
              ),
            ),
          ],
        );
      default:
        return Row(
          children: [
            Expanded(child: _itemCell(context, "REPS", meta.reps)),
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
                meta.weight,
              ),
            ),
          ],
        );
    }
  }

  Widget _itemCell(BuildContext context, String title, int item) {
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
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
