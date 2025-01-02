import 'package:workout_notepad_v2/logger/record.dart';

abstract class LogSink {
  // for setting internal metadata needed for any sinks
  void setLoggerData(String title);

  // sending a record
  Future<void> send(LogRecord record, String formatted);

  // allow for force flushing any logs stored in a cache
  Future<void> flush();
}
