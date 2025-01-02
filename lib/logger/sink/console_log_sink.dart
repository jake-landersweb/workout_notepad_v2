import 'dart:async';
import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/logger/record.dart';
import 'package:workout_notepad_v2/logger/sink/log_sink.dart';

class ConsoleLogSink implements LogSink {
  @override
  void setLoggerData(String title) {}

  @override
  Future<void> send(LogRecord record, String formatted) async {
    Zone.root.run(() {
      debugPrint(formatted);
    });
  }

  @override
  Future<void> flush() async {}
}
