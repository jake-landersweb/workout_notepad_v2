import 'package:workout_notepad_v2/logger/record.dart';

abstract class LogFormatter {
  String format(LogRecord record);
}
