// https://github.com/open-telemetry/oteps/blob/main/text/logs/0097-log-data-model.md#log-and-event-record-definition
enum LogLevel {
  trace,
  debug,
  info,
  warn,
  err,
  fatal;

  String get name {
    switch (this) {
      case LogLevel.trace:
        return "TRACE";
      case LogLevel.debug:
        return "DEBUG";
      case LogLevel.info:
        return "INFO";
      case LogLevel.warn:
        return "WARN";
      case LogLevel.err:
        return "ERROR";
      case LogLevel.fatal:
        return "FATAL";
    }
  }

  int get number {
    switch (this) {
      case LogLevel.trace:
        return 1;
      case LogLevel.debug:
        return 5;
      case LogLevel.info:
        return 9;
      case LogLevel.warn:
        return 13;
      case LogLevel.err:
        return 17;
      case LogLevel.fatal:
        return 21;
    }
  }
}
