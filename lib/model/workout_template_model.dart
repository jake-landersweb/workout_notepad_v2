import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_template.dart';
import 'package:workout_notepad_v2/model/client.dart';
import 'package:http/http.dart' as http;

class WorkoutTemplateModel extends ChangeNotifier {
  WorkoutTemplateModel();

  final client = GoClient(client: http.Client());

  List<WorkoutTemplate>? remoteTemplates;
  bool loadingRemoteTemplates = true;

  Future<List<WorkoutTemplate>?> fetchRemoteTemplates({
    String? searchText,
    List<Category>? categories,
    bool reload = false,
  }) async {
    if (remoteTemplates == null || remoteTemplates!.isEmpty || reload) {
      print("Fetching the remote workout templates");
      loadingRemoteTemplates = true;
      notifyListeners();
      String path = "/v2/templates";
      if ((searchText ?? "").isNotEmpty) {
        path = "$path?searchText=$searchText";
      }
      if ((categories ?? []).isNotEmpty) {
        path =
            "$path?categories=${categories!.map((i) => i.categoryId).toList()}";
      }
      var response = await client.fetch(path);
      if (response.statusCode != 200) {
        throw Exception(
            "message=\"failed to query the remote templates\" status=${response.statusCode} body=\"${response.body}\"");
      }

      // parse the templates
      var decoded = jsonDecode(response.body);
      List<WorkoutTemplate> items = [];
      for (var i in decoded) {
        items.add(WorkoutTemplate.fromJson(i));
      }
      remoteTemplates = items;
      loadingRemoteTemplates = false;
      notifyListeners();
      print("Successfully fetched remote templates: ${items.length}");
    }

    return remoteTemplates;
  }

  Future<WorkoutTemplate> getRemoteTemplate({
    required int id,
  }) {
    throw UnimplementedError();
  }
}
