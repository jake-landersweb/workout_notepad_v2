// create a global logger
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/logger/formatter/json_log_formatter.dart';
import 'package:workout_notepad_v2/logger/formatter/logfmt_log_formatter.dart';
import 'package:workout_notepad_v2/logger/level.dart';
import 'package:workout_notepad_v2/logger/logger.dart';
import 'package:workout_notepad_v2/logger/sink/console_log_sink.dart';
import 'package:workout_notepad_v2/logger/sink/otel_log_sink.dart';
import 'package:workout_notepad_v2/model/env.dart';

var logger = Logger(
  kDebugMode ? "workout-notepad-app-dev" : "workout-notepad-app-prod",
  formatter: kDebugMode ? LogFMTLogFormatter() : JSONLogFormatter(),
  level: kDebugMode ? LogLevel.debug : LogLevel.info,
  sinks: [
    kDebugMode
        ? ConsoleLogSink()
        : OtelLogSink(
            endpoint: OTEL_BACKEND_HOST,
            apiKey: OTEL_BACKEND_API_KEY,
            flushDuration: Duration(seconds: kDebugMode ? 5 : 30),
          ),
  ],
  attributes: {
    "sessionId": Uuid().v4(), // add a session id for the app session
  },
);
