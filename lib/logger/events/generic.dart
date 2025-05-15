import 'package:workout_notepad_v2/logger/events/log_event.dart';
import 'package:workout_notepad_v2/utils/string_utils.dart';

class GenericEvent implements LogEvent {
  final String name;
  final String? msg;
  final Map<String, dynamic>? metadata;

  GenericEvent(this.name, {this.msg, this.metadata});

  @override
  Map<String, dynamic> data() {
    return metadata ?? {};
  }

  @override
  String get eventName => name;

  @override
  String get message => msg ?? name.split("-").join(" ").capitalize();
}
