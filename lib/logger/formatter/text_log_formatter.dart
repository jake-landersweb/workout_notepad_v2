import 'package:workout_notepad_v2/logger/formatter/log_formatter.dart';

class TextLogFormatter implements LogFormatter {
  const TextLogFormatter();

  @override
  String format(record) {
    String msg = "[${record.level.name}]";
    if (record.message.isNotEmpty) {
      msg += " ${record.message}";
    }
    if (record.eventName != null) {
      msg += " ${record.eventName!}";
    }
    if (record.data != null) {
      msg += " ${record.data!}";
    }
    return msg;
  }
}
