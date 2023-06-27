import "package:flutter/material.dart";
import 'package:line_icons/line_icons.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'dart:math' as math;
import './root.dart' as comp;

enum CountdownTimerType { clock, numbers, adaptive }

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({
    super.key,
    this.type = CountdownTimerType.adaptive,
    required this.duration,
    this.beginTime,
    this.fontSize = 100,
    this.onStart,
    this.onEnd,
  });
  final CountdownTimerType type;
  final Duration duration;
  final DateTime? beginTime;
  final double fontSize;
  final VoidCallback? onStart;
  final VoidCallback? onEnd;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late CountdownTimerType _type;
  late String _restingHour;
  late String _restingMin;
  late String _restingSec;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    if (widget.type == CountdownTimerType.adaptive) {
      if (widget.duration.inSeconds > 599) {
        _type = CountdownTimerType.numbers;
      } else {
        _type = CountdownTimerType.clock;
      }
    } else {
      _type = widget.type;
    }

    if (widget.beginTime != null) {
      var diff = DateTime.now().difference(widget.beginTime!);
      _controller.reverse(
        from: (widget.duration.inMilliseconds - diff.inMilliseconds) /
            widget.duration.inMilliseconds,
      );
    }

    if (widget.onEnd != null) {
      _controller.addListener(() {
        if (_controller.value == 0) {
          widget.onEnd!();
        }
      });
    }

    // get resting digits to show when timer is off
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    _restingHour = twoDigits(widget.duration.inHours);
    _restingMin = twoDigits(widget.duration.inMinutes.remainder(60));
    _restingSec = twoDigits(widget.duration.inSeconds.remainder(60));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get timerString {
    Duration duration = _controller.duration! * _controller.value;
    if (duration.inMilliseconds == 0) {
      return '$_restingMin:$_restingSec';
    } else {
      return '${(duration.inMinutes).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
  }

  String get hour {
    Duration duration = _controller.duration! * _controller.value;
    if (duration.inMilliseconds == 0) {
      return _restingHour;
    } else {
      return duration.inHours.toString().padLeft(2, '0');
    }
  }

  String get min {
    Duration duration = _controller.duration! * _controller.value;
    if (duration.inMilliseconds == 0) {
      return _restingMin;
    } else {
      return (duration.inMinutes % 60).toString().padLeft(2, '0');
    }
  }

  String get sec {
    Duration duration = _controller.duration! * _controller.value;
    if (duration.inMilliseconds == 0) {
      return _restingSec;
    } else {
      return (duration.inSeconds % 60).toString().padLeft(2, '0');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 700),
      curve: Sprung.overDamped,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _timer(context),
                const SizedBox(height: 16),
                // controls
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Row(
                            children: [
                              Expanded(
                                child: Clickable(
                                  onTap: () {
                                    setState(() {
                                      _type = CountdownTimerType.clock;
                                    });
                                  },
                                  child: Container(
                                    constraints:
                                        const BoxConstraints(minHeight: 35),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                    ),
                                    child: Icon(
                                      Icons.timer_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 35,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              Expanded(
                                child: Clickable(
                                  onTap: () {
                                    setState(() {
                                      _type = CountdownTimerType.numbers;
                                    });
                                  },
                                  child: Container(
                                    constraints:
                                        const BoxConstraints(minHeight: 35),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                    ),
                                    child: Icon(
                                      Icons.timer_10_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: comp.ActionButton(
                              minHeight: 35,
                              title:
                                  _controller.isAnimating ? "Reset" : "Start",
                              icon: _controller.isAnimating
                                  ? Icons.restart_alt_rounded
                                  : Icons.play_arrow_rounded,
                              onTap: () {
                                if (_controller.isAnimating) {
                                  setState(() {
                                    _controller.reset();
                                  });
                                } else {
                                  setState(() {
                                    _controller.reverse(
                                      from: _controller.value == 0.0
                                          ? 1.0
                                          : _controller.value,
                                    );
                                  });
                                  if (widget.onStart != null) {
                                    widget.onStart!();
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _timer(BuildContext context) {
    switch (_type) {
      case CountdownTimerType.clock:
        return _clock(context);
      case CountdownTimerType.numbers:
        return _numbers(context);
      default:
        return Container();
    }
  }

  Widget _numbers(BuildContext context) {
    return Row(
      children: [
        if (widget.duration.inHours > 0)
          Expanded(
            child: _numberCell(
              context,
              Theme.of(context).colorScheme.tertiaryContainer,
              Theme.of(context).colorScheme.onTertiaryContainer,
              hour,
            ),
          ),
        if (widget.duration.inHours > 0)
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
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.onPrimaryContainer,
            min,
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
            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            Theme.of(context).colorScheme.onSurfaceVariant,
            sec,
          ),
        ),
      ],
    );
  }

  Widget _numberCell(BuildContext context, Color bg, Color fg, String val) {
    return Container(
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

  Widget _clock(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: FractionalOffset.center,
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: CustomTimerPainter(
                        animation: _controller,
                        backgroundColor:
                            Theme.of(context).colorScheme.background,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: FractionalOffset.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Text(
                          timerString,
                          style: TextStyle(
                            fontSize: widget.fontSize,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 15.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomTimerPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
