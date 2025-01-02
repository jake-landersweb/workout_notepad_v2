import 'package:flutter_test/flutter_test.dart';
import 'package:workout_notepad_v2/logger/formatter/logfmt_log_formatter.dart';
import 'package:workout_notepad_v2/logger/level.dart';
import 'package:workout_notepad_v2/logger/logger.dart';
import 'package:workout_notepad_v2/logger/sink/console_log_sink.dart';
import 'package:flutter/foundation.dart';

void main() {
  test("test the logger with all levels", () async {
    // Capture debugPrint output
    final List<String> printedMessages = [];
    final originalDebugPrint = debugPrint;

    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) {
        printedMessages.add(message);
      }
    };

    try {
      var logger = Logger(
        "workout-notepad-test",
        level: LogLevel.debug,
        formatter: LogFMTLogFormatter(),
        sinks: [
          ConsoleLogSink(),
        ],
      );

      logger.debug("debug message");
      logger.info("info message");
      logger.warn("warn message");
      logger.error("error message");
      logger.fatal("fatal message");
      logger.exception(Exception("This is an exception"), null);

      // Allow logs to flush
      await Future.delayed(Duration(milliseconds: 100));
    } finally {
      // Restore the original debugPrint
      debugPrint = originalDebugPrint;
    }

    // Assertions
    expect(
      printedMessages,
      containsAll([
        'level=DEBUG message="debug message" ',
        'level=INFO message="info message" ',
        'level=WARN message="warn message" ',
        'level=ERROR message="error message" ',
        'level=FATAL message="fatal message" ',
        'level=ERROR message="Exception: This is an exception" exception=Exception: This is an exception'
      ]),
    );
  });

  test("test scoping by level", () async {
    // Capture debugPrint output
    final List<String> printedMessages = [];
    final originalDebugPrint = debugPrint;

    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) {
        printedMessages.add(message);
      }
    };

    try {
      var logger = Logger(
        "workout-notepad-test",
        level: LogLevel.warn,
        formatter: LogFMTLogFormatter(),
        sinks: [
          ConsoleLogSink(),
        ],
      );

      logger.debug("debug message");
      logger.info("info message");
      logger.warn("warn message");
      logger.error("error message");
      logger.fatal("fatal message");
      logger.exception(Exception("This is an exception"), null);

      // Allow logs to flush
      await Future.delayed(Duration(milliseconds: 100));
    } finally {
      // Restore the original debugPrint
      debugPrint = originalDebugPrint;
    }

    // Assertions
    expect(
      printedMessages,
      containsAll([
        'level=WARN message="warn message" ',
        'level=ERROR message="error message" ',
        'level=FATAL message="fatal message" ',
        'level=ERROR message="Exception: This is an exception" exception=Exception: This is an exception'
      ]),
    );
  });
}
