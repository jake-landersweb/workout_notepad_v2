import 'dart:convert';

import 'package:workout_notepad_v2/logger/formatter/log_formatter.dart';
import 'package:workout_notepad_v2/logger/record.dart';

class JSONLogFormatter implements LogFormatter {
  @override
  String format(LogRecord record) {
    var obj = {"level": record.level.name};
    if (record.message.isNotEmpty) {
      obj["message"] = record.message;
    }

    try {
      return jsonEncode({
        ...obj,
        if (record.data != null) ...record.data!,
      });
    } catch (error, stack) {
      return '{"level": "FATAL", "message": "failed to encode the json log message", "error": "${error.toString()}, "stack": "${stack.toString()}", "originalMessage": "${record.message}"}';
    }
  }
}
