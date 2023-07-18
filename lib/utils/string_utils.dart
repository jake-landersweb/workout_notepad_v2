extension StringUtils on String {
  String capitalize() {
    if (length == 0) {
      return "";
    }
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

String formatDateTime(DateTime t) {
  List<String> dayNames = ['Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat', 'Sun'];

  List<String> monthNames = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'April',
    'May',
    'June',
    'July',
    'Aug',
    'Sept',
    'Oct',
    'Nov',
    'Dec'
  ];

  String dayName = dayNames[t.weekday - 1];
  String monthName = monthNames[t.month];
  String dayNum = t.day.toString();

  return '$dayName, $monthName $dayNum';
}
