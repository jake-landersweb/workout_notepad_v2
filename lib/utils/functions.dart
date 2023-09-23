import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'root.dart';

List<List<T>> chunkList<T>(List<T> list, int n) {
  List<List<T>> chunks = [];
  int length = list.length;
  int startIndex = length % n;

  if (startIndex != 0) {
    chunks.add(list.sublist(0, startIndex));
  }

  for (int i = startIndex; i < length; i += n) {
    chunks.add(list.sublist(i, i + n));
  }

  return chunks.reversed.toList();
}

String intToDay(int v) {
  switch (v) {
    case 0:
      return "Sunday";
    case 1:
      return "Monday";
    case 2:
      return "Tuesday";
    case 3:
      return "Wednesday";
    case 4:
      return "Thursday";
    case 5:
      return "Friday";
    case 6:
      return "Saturday";
    default:
      throw "Invalid date";
  }
}

Future<void> launchSupportPage(
    BuildContext context, User user, String type) async {
  if (!await launchUrl(Uri.parse(
      "https://workoutnotepad.co/support?email=${user.email}&userId=${user.userId}&type=$type"))) {
    snackbarErr(context, "There was an issue opening the support page.");
  }
}
