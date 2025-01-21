import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:workout_notepad_v2/logger/formatter/logfmt_log_formatter.dart';
import 'package:workout_notepad_v2/logger/record.dart';
import 'package:workout_notepad_v2/logger/sink/log_sink.dart';

class OtelLogSink implements LogSink {
  late String title;
  final String endpoint;
  final String apiKey;
  final int batchSize;

  // internal buffer to use for log records
  late final Duration flushDuration;
  late final List<LogRecord> _buffer;
  late final List<String> _bufferFormatted;

  late Timer _timer;

  OtelLogSink({
    required this.endpoint,
    this.apiKey = "",
    this.batchSize = 50,
    Duration? flushDuration,
  }) {
    this.flushDuration = flushDuration ?? Duration(seconds: 30);
    _buffer = [];
    _bufferFormatted = [];

    // only add a ticker if the flush duration is not set to 0
    if (this.flushDuration.inSeconds != 0) {
      // attach a timer to flush the buffer at the specified interval
      _timer = Timer.periodic(this.flushDuration, (Timer timer) {
        _flushBuffer();
      });
    }
  }

  @override
  void setLoggerData(String title) {
    this.title = title;
  }

  @override
  Future<void> send(LogRecord record, String formatted) async {
    // add to the buffer
    _buffer.add(record);
    _bufferFormatted.add(formatted);

    // if flush is disabled, immediately send the logs
    if (flushDuration.inSeconds == 0) {
      _flushBuffer();
    }
  }

  @override
  Future<void> flush() async {
    await _flushBuffer();
  }

  Future<void> _flushBuffer() async {
    try {
      Zone.root.run(() {
        print("Processing: ${_buffer.length} logs");
      });

      // batch the buffer
      var chunks = _chunkList(_buffer, batchSize);
      var chunksFormatted = _chunkList(_bufferFormatted, batchSize);

      // loop over the chunks
      for (int i = 0; i < chunks.length; i++) {
        // create the payload
        var payload = _recordsToOtelPayload(chunks[i], chunksFormatted[i]);

        // send to the otel backend
        var response = await _sendToOtelBackend(payload);

        // TODO: handle failing of responses (i.e. bad internet connection)
        response;
      }
    } catch (error, stack) {
      Zone.root.run(() {
        print("critical error flushing otel buffer:");
        print(error);
        print(stack);
      });
    } finally {
      // remove these from the internal buffer
      _buffer.clear();
      _bufferFormatted.clear();
    }
  }

  Map<String, dynamic> _recordsToOtelPayload(
    List<LogRecord> records,
    List<String> formatted,
  ) {
    List<Map<String, dynamic>> logs = [];
    for (int i = 0; i < records.length; i++) {
      logs.add({
        "time_unix_nano": records[i].timestamp,
        "severity_number": records[i].level.number,
        "severity_text": records[i].level.name,
        "body": {"stringValue": records[i].message},
        "attributes": [
          ..._convertAttributes(records[i].data ?? {}),
          ...[
            {
              "key": "formattedMessage",
              "value": {"stringValue": formatted[i]}
            }
          ]
        ],
      });
    }

    return {
      "resource_logs": [
        {
          "resource": {
            "attributes": [
              {
                "key": "service.name",
                "value": {"stringValue": title}
              }
            ]
          },
          "scope_logs": [
            {
              "scope": {"name": title},
              "log_records": logs,
            }
          ]
        }
      ]
    };
  }

  Future<bool> _sendToOtelBackend(Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          if (apiKey.isNotEmpty) 'x-api-key': apiKey,
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to send logs to the otel backend: ${response.body}');
      }
      return true;
    } catch (e, stack) {
      Zone.root.run(() {
        print('Error sending log to Otel backend: $e $stack');
      });
      return false;
    }
  }

  void dispose() {
    // Cancel the timer when it's no longer needed
    _timer.cancel();
  }
}

List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
  List<List<T>> chunks = [];
  for (int i = 0; i < list.length; i += chunkSize) {
    chunks.add(list.sublist(
        i, i + chunkSize > list.length ? list.length : i + chunkSize));
  }
  return chunks;
}

List<Map<String, dynamic>> _convertAttributes(Map<String, dynamic> data) {
  List<Map<String, dynamic>> res = [];

  for (var item in data.entries) {
    Map<String, dynamic> attribute = {"key": item.key};

    // check for correct runtime type
    switch (item.value.runtimeType) {
      case Map<String, dynamic>:
        attribute["value"] = {"stringValue": logfmt(item.value)};
        break;
      case List:
        attribute['value'] = {
          "arrayValue": {"values": item.value}
        };
        break;
      case String:
        attribute['value'] = {"stringValue": item.value};
        break;
      case bool:
        attribute['value'] = {"boolValue": item.value};
        break;
      case int:
        attribute['value'] = {"intValue": item.value};
        break;
      case double:
        attribute['value'] = {"doubleValue": item.value};
        break;
      case Null:
        attribute["value"] = {"stringValue": "null"};
        break;
      default:
        attribute["value"] = {"stringValue": item.value.toString()};
    }

    res.add(attribute);
  }

  return res;
}
