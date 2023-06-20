import 'dart:async';

import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';

class LWTime extends StatefulWidget {
  const LWTime({
    super.key,
    required this.start,
    this.style,
  });
  final DateTime start;
  final TextStyle? style;

  @override
  State<LWTime> createState() => _LWTimeState();
}

class _LWTimeState extends State<LWTime> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formatHHMMSS(DateTime.now().difference(widget.start).inSeconds),
      style: widget.style,
    );
  }
}
