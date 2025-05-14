import 'package:flutter_test/flutter_test.dart';
import 'package:workout_notepad_v2/logger/formatter/logfmt_log_formatter.dart';
import 'package:workout_notepad_v2/logger/level.dart';
import 'package:workout_notepad_v2/logger/logger.dart';
import 'package:workout_notepad_v2/logger/sink/otel_log_sink.dart';

void main() {
  test("test otel sink", () async {
    var logger = Logger(
      "workout-notepad-test",
      level: LogLevel.debug,
      formatter: LogFMTLogFormatter(),
      sinks: [
        OtelLogSink(
          endpoint: "http://localhost:8043/v1/logs",
          apiKey: "",
          flushDuration: Duration(milliseconds: 0),
        ),
      ],
    );

    logger.info("this should send to an otel backend", {
      "string": "att1",
      "int": 1,
      "double": 1.23,
      "bool": true,
      "list": [1, 2, 3, 4, 5],
      "other": {"key1": "value", "key2": 1}
    });
    await Future.delayed(Duration(milliseconds: 1000)); //wait
  });
}
