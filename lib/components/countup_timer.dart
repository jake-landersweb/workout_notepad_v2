import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/timer.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import './root.dart' as comp;

class CountupTimer extends StatefulWidget {
  const CountupTimer({
    super.key,
    this.goalDuration,
    this.onFinish,
    this.startOnInit = false,
    this.startTime,
    this.onStart,
  });
  final Duration? goalDuration;
  final void Function(Duration duration)? onFinish;
  final bool startOnInit;
  final DateTime? startTime;
  final VoidCallback? onStart;

  @override
  State<CountupTimer> createState() => _CountupTimerState();
}

class _CountupTimerState extends State<CountupTimer> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => comp.TextTimerController(
        startOnCreate: widget.startOnInit,
        startTime: widget.startTime,
      ),
      builder: (context, child) => _body(context),
    );
  }

  Widget _body(BuildContext context) {
    var controller = Provider.of<TextTimerController>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (controller.time.inHours > 0)
              Expanded(
                child: _numberCell(
                  context,
                  Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  Theme.of(context).colorScheme.onTertiaryContainer,
                  hours(controller),
                ),
              ),
            if (controller.time.inHours > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  ":",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 60,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Expanded(
              child: _numberCell(
                context,
                Theme.of(context).primaryColor.withOpacity(0.15),
                Theme.of(context).colorScheme.onPrimaryContainer,
                minutes(controller),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                ":",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 60,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: _numberCell(
                context,
                AppColors.cell(context),
                Theme.of(context).colorScheme.onSurfaceVariant,
                seconds(controller),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: widget.goalDuration == null
                  ? Container()
                  : Center(
                      child: Text(
                        "Goal: ${_formatHHMMSS(widget.goalDuration!.inSeconds)}",
                        style: ttBody(
                          context,
                          color: AppColors.subtext(context),
                        ),
                      ),
                    ),
            ),
            Expanded(
              child: Clickable(
                onTap: () {
                  if (controller.isActive) {
                    if (widget.onFinish != null) {
                      widget.onFinish!(controller.time);
                    }
                    controller.cancel();
                  } else {
                    controller.start();
                    if (widget.onStart != null) {
                      widget.onStart!();
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cell(context)[800],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  height: 40,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          controller.isActive
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                          color: AppColors.cell(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          controller.isActive ? "Finish" : "Start",
                          style: TextStyle(
                            color: AppColors.cell(context)[50],
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _numberCell(BuildContext context, Color bg, Color fg, String val) {
    return AnimatedContainer(
      curve: Sprung.overDamped,
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          val,
          style: TextStyle(
            color: fg,
            fontSize: 60,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String hours(comp.TextTimerController controller) {
    return (controller.time.inSeconds ~/ 3600).toString().padLeft(2, '0');
  }

  String minutes(comp.TextTimerController controller) {
    return (controller.time.inSeconds ~/ 60).toString().padLeft(2, '0');
  }

  String seconds(comp.TextTimerController controller) {
    return (controller.time.inSeconds % 60).toString().padLeft(2, '0');
  }

  String _formatHHMMSS(int seconds) {
    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    if (hours == 0) {
      return "$minutesStr:$secondsStr";
    }

    return "$hoursStr:$minutesStr:$secondsStr";
  }
}
