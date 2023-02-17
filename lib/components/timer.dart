import 'package:flutter/material.dart';

class TextTimer extends StatefulWidget {
  const TextTimer({
    super.key,
    this.initialTime,
    this.msEnd,
    this.msIterate = 1000,
    this.style,
    this.onEnd,
    this.timeFormat,
    this.onTick,
    this.onMsTick,
  });
  final Duration? initialTime;
  final int? msEnd;
  final int msIterate;
  final TextStyle? style;
  final VoidCallback? onEnd;
  final String Function(Duration duration)? timeFormat;
  final void Function(DateTime time)? onTick;
  final void Function(int ms)? onMsTick;

  @override
  State<TextTimer> createState() => _TextTimerState();
}

class _TextTimerState extends State<TextTimer> {
  late DateTime _initTime;
  late DateTime _currentTime;
  bool _isActive = true;

  @override
  void initState() {
    _initTime = DateTime.now();
    _currentTime = DateTime.now();
    if (widget.initialTime != null) {
      _currentTime.add(widget.initialTime!);
    }
    _iterate();
    super.initState();
  }

  @override
  void dispose() {
    _isActive = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _getTime(),
      style: widget.style ??
          const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
    );
  }

  void _iterate() async {
    while (_isActive) {
      // wait for the time duration
      await Future.delayed(Duration(milliseconds: widget.msIterate));
      // add the time
      setState(() {
        _currentTime =
            _currentTime.add(Duration(milliseconds: widget.msIterate));
      });
      // send observer
      if (widget.onTick != null) {
        widget.onTick!(_currentTime);
      }
      if (widget.onMsTick != null) {
        widget.onMsTick!(_currentTime.difference(_initTime).inMilliseconds);
      }
      // check if should end
      if (widget.msEnd != null && _duration().inMilliseconds > widget.msEnd!) {
        if (widget.onEnd != null) {
          widget.onEnd!();
        }
        _isActive = false;
      }
    }
  }

  String _getTime() {
    if (widget.timeFormat != null) {
      return widget.timeFormat!(_duration());
    }
    return _formatHHMMSS(_duration().inSeconds);
  }

  Duration _duration() {
    return _currentTime.difference(_initTime);
  }
}

/// format string as HH:MM:SS
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
