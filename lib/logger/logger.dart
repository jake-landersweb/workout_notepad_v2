// singleton instance
import 'dart:async';
import 'dart:convert';

import 'package:workout_notepad_v2/logger/events/log_event.dart';
import 'package:workout_notepad_v2/logger/formatter/log_formatter.dart';
import 'package:workout_notepad_v2/logger/formatter/text_log_formatter.dart';
import 'package:workout_notepad_v2/logger/level.dart';
import 'package:workout_notepad_v2/logger/record.dart';
import 'package:workout_notepad_v2/logger/sink/log_sink.dart';

class Logger {
  static Logger? _instance;

  final String title;
  late final LogFormatter formatter;
  late final List<LogSink> sinks;
  late final LogLevel level;

  // for holding data set with `.withData`
  Map<String, dynamic>? _internalData;

  Logger._internal(
    this.title, {
    LogLevel? level,
    LogFormatter? formatter,
    List<LogSink>? sinks,
    Map<String, dynamic>? internalData,
  }) {
    this.level = level ?? LogLevel.info;
    this.formatter = formatter ?? TextLogFormatter();
    this.sinks = sinks ?? [];
    _internalData = internalData;

    // set the internal data for log sinks
    for (var i in this.sinks) {
      i.setLoggerData(title);
    }
  }

  factory Logger(
    String title, {
    LogLevel? level,
    LogFormatter? formatter,
    List<LogSink>? sinks,
    Map<String, dynamic>? attributes,
  }) {
    _instance ??= Logger._internal(
      title,
      level: level,
      formatter: formatter,
      sinks: sinks,
      internalData: attributes,
    );
    return _instance!;
  }

  Logger withData([Map<String, dynamic>? data]) {
    return Logger._internal(
      title,
      formatter: formatter,
      sinks: List.from(sinks),
      internalData: {
        if (_internalData != null) ..._internalData!,
        if (data != null) ...data,
      },
    );
  }

  void log(LogLevel level, String message, [Map<String, dynamic>? data]) {
    // check that the log level is valid
    if (level.number >= this.level.number) {
      var record = LogRecord(
        timestamp: "${DateTime.now().microsecondsSinceEpoch * 1000}",
        level: level,
        message: message,
        data: {
          if (data != null) ...data,
          if (_internalData != null) ..._internalData!,
        },
      );
      var formatted = formatter.format(record);
      for (var sink in sinks) {
        sink.send(record, formatted);
      }
    }
  }

  void debug(String message, [Map<String, dynamic>? data]) {
    log(LogLevel.debug, message, data);
  }

  void info(String message, [Map<String, dynamic>? data]) {
    log(LogLevel.info, message, data);
  }

  void warn(String message, [Map<String, dynamic>? data]) {
    log(LogLevel.warn, message, data);
  }

  void error(String message, [Map<String, dynamic>? data]) {
    log(LogLevel.err, message, data);
  }

  void fatal(String message, [Map<String, dynamic>? data]) {
    log(LogLevel.fatal, message, data);
  }

  void exception(Object error, StackTrace? stack,
      {Map<String, dynamic>? data, String? message}) {
    var attributes = {"exception": error};
    if (stack != null) {
      attributes["stackTrace"] = stack;
    }
    log(
      LogLevel.err,
      message ?? error.toString(),
      {
        ...attributes,
        if (data != null) ...data,
      },
    );
  }

  void event(LogEvent e) {
    var record = LogRecord(
      timestamp: "${DateTime.now().microsecondsSinceEpoch * 1000}",
      level: LogLevel.info,
      message: e.message,
      data: {
        ...e.data(),
        if (_internalData != null) ..._internalData!,
      },
      eventName: e.eventName,
    );
    var formatted = formatter.format(record);
    for (var sink in sinks) {
      sink.send(record, formatted);
    }
  }

  // takes in a raw unformated string (i.e.) from a legacy print statement
  // and attempts to parse it into a structured logging context.
  // If there are keywords present (error, warn, etc.) then it will
  // attempt to be pased to the write output.
  // If valid JSON is passed, the message field will be empty, and the json
  // will be passed as the `data`.
  void parse(String message) {
    // attempt to parse as json
    if (message != "null" && message != "{}") {
      try {
        var obj = jsonDecode(message);
        info("", obj);
        return;
      } catch (_) {}
    }

    // parse keywords
    if (message.toLowerCase().contains("debug")) {
      debug(message);
    } else if (message.toLowerCase().contains("error")) {
      error(message);
    } else if (message.toLowerCase().contains("warn") ||
        message.toLowerCase().contains("warning")) {
      warn(message);
    } else if (message.toLowerCase().contains("fatal")) {
      fatal(message);
    } else {
      info(message);
    }
  }

  // Flush all of the logs in the configured sinks
  Future<void> flush() async {
    for (var i in sinks) {
      await i.flush();
    }
  }

  void setAttribute(String key, dynamic value) {
    _internalData ??= {};
    _internalData![key] = value;
  }
}
