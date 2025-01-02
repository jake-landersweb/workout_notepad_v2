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

    return jsonEncode({
      ...obj,
      if (record.data != null) ...record.data!,
    });
  }
}
