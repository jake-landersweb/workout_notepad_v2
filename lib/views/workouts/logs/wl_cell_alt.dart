import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/color.dart';

class WorkoutLogCellAlt extends StatelessWidget {
  const WorkoutLogCellAlt({
    super.key,
    required this.log,
    this.endContent,
  });

  final WorkoutLog log;
  final Widget? endContent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider(context)),
            borderRadius: BorderRadius.circular(7),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Column(
              children: [
                Container(
                  color: AppColors.cell(context)[600],
                  height: 20,
                  width: 50,
                  child: Center(
                    child: Text(
                      DateFormat('MMM').format(
                        log.getCreated(),
                      ),
                      style: TextStyle(
                        color: AppColors.subtext(context),
                      ),
                    ),
                  ),
                ),
                Container(
                  color: AppColors.cell(context)[300],
                  height: 30,
                  width: 50,
                  child: Center(
                    child: Text(
                      log.getCreated().day.toString(),
                      style: ttLabel(context, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                log.title,
                style: ttLabel(context),
              ),
              Text(
                log.getDuration(),
                style: ttBody(
                  context,
                  color: AppColors.subtext(context),
                ),
              ),
            ],
          ),
        ),
        endContent ??
            Transform.rotate(
              angle: math.pi / 2,
              child: Icon(
                Icons.chevron_left_rounded,
                color: AppColors.subtext(context),
              ),
            ),
      ],
    );
  }
}
