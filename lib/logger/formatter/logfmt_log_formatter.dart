import 'package:workout_notepad_v2/logger/formatter/log_formatter.dart';
import 'package:workout_notepad_v2/logger/record.dart';

class LogFMTLogFormatter implements LogFormatter {
  @override
  String format(LogRecord record) {
    String msg = "level=${record.level.name}";
    if (record.message.isNotEmpty) {
      msg += " message=\"${record.message}\"";
    }
    if (record.data != null) {
      msg += " ${logfmt(record.data!)}";
    }
    return msg;
  }
}

String logfmt(Map<String, dynamic> object, [String prefix = '']) {
  StringBuffer buffer = StringBuffer();

  object.forEach((key, value) {
    String fullKey = prefix.isNotEmpty ? '$prefix.$key' : key;

    if (value is Map<String, dynamic>) {
      buffer.write(logfmt(value, fullKey));
    } else if (value is List) {
      if (value.isNotEmpty) {
        buffer.write(
          '$fullKey=${escapeValue(value.map((e) => e.toString()).toList().join(","))} ',
        );
      }
    } else {
      if (value is String && value.isEmpty) {
      } else {
        buffer.write('$fullKey=${escapeValue(value)} ');
      }
    }
  });

  return buffer.toString().trim();
}

String escapeValue(dynamic value) {
  if (value == null) return 'null';
  if (value is String && (value.contains(' ') || value.contains('='))) {
    return '"${value.replaceAll('"', '\\"')}"';
  }
  return value.toString();
}
