abstract class LogEvent {
  Map<String, dynamic> data();
  String get eventName;
  String get message;

  @override
  String toString() => message;
}
