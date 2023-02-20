import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextTimerController extends ChangeNotifier {
  late DateTime _initTime;
  late DateTime _currentTime;
  Duration? _initDuration;
  late int msIterate;
  final void Function(Duration ms)? onMsTick;

  bool _isActive = false;

  TextTimerController({
    Duration? initialTime,
    this.msIterate = 1000,
    bool startOnCreate = true,
    this.onMsTick,
  }) {
    _initTime = DateTime.now();
    _currentTime = DateTime.now();
    _initDuration = initialTime;
    if (startOnCreate) {
      start();
    }
  }

  @override
  void dispose() {
    _isActive = false;
    super.dispose();
  }

  void _iterate() async {
    while (_isActive) {
      // wait for the time duration
      _currentTime = DateTime.now();
      if (onMsTick != null) {
        onMsTick!(time);
      }
      notifyListeners();
      await Future.delayed(Duration(milliseconds: msIterate));
    }
  }

  void start() {
    _isActive = true;
    _initTime = DateTime.now();
    _currentTime = DateTime.now();
    if (_initDuration != null) {
      _currentTime.add(_initDuration!);
    }
    notifyListeners();
    _iterate();
  }

  void cancel() {
    _isActive = false;
    _initTime = DateTime.now();
    _currentTime = DateTime.now();
    notifyListeners();
  }

  Duration get time {
    return _currentTime.difference(_initTime);
  }

  bool get isActive {
    return _isActive;
  }
}

class TextTimer extends StatefulWidget {
  const TextTimer({
    super.key,
    this.initialTime,
    this.msEnd,
    this.msIterate = 1000,
    this.style,
    this.onEnd,
    this.timeFormat,
    this.onMsTick,
  });
  final Duration? initialTime;
  final int? msEnd;
  final int msIterate;
  final TextStyle? style;
  final VoidCallback? onEnd;
  final String Function(Duration duration)? timeFormat;
  final void Function(Duration ms)? onMsTick;

  @override
  State<TextTimer> createState() => _TextTimerState();
}

class _TextTimerState extends State<TextTimer> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TextTimerController(
        initialTime: widget.initialTime,
        msIterate: widget.msIterate,
        onMsTick: widget.onMsTick,
      ),
      builder: (context, child) => _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Text(
      _getTime(context),
      style: widget.style ??
          const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
    );
  }

  String _getTime(BuildContext context) {
    var controller = Provider.of<TextTimerController>(context);
    if (widget.timeFormat != null) {
      return widget.timeFormat!(controller.time);
    }
    return _formatHHMMSS(controller.time.inSeconds);
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
