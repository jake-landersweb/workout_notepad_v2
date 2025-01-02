import 'package:workout_notepad_v2/logger/level.dart';

class LogRecord {
  final String timestamp;
  final LogLevel level;
  final String message;
  final Map<String, dynamic>? data;

  LogRecord({
    required this.timestamp,
    required this.level,
    required this.message,
    required this.data,
  });
}
