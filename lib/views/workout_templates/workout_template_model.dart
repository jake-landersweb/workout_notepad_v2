import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/data/workout_template.dart';
import 'package:workout_notepad_v2/model/client.dart';
import 'package:http/http.dart' as http;
import 'package:workout_notepad_v2/model/root.dart';

class WorkoutTemplateModel extends ChangeNotifier {
  WorkoutTemplateModel() {
    textEditingController = TextEditingController()
      ..addListener(() {
        _onTextChanged();
      });
  }

  final client = GoClient(client: http.Client());

  List<WorkoutTemplate>? remoteTemplates;
  LoadingStatus remoteTemplateStatus = LoadingStatus.loading;

  late TextEditingController textEditingController;
  Timer? _debounce;
  List<String> categories = [];

  Future<List<WorkoutTemplate>?> fetchRemoteTemplates({
    bool reload = false,
  }) async {
    try {
      if (remoteTemplates == null || remoteTemplates!.isEmpty || reload) {
        print("Fetching the remote workout templates");
        remoteTemplateStatus = LoadingStatus.loading;
        notifyListeners();
        String path = "/v2/templates";
        if (textEditingController.text.isNotEmpty) {
          path = "$path?searchText=${textEditingController.text}";
        }
        if (categories.isNotEmpty) {
          path = "$path?categories=${categories.join(",")}";
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
        remoteTemplateStatus = LoadingStatus.done;
        notifyListeners();
        print("Successfully fetched remote templates: ${items.length}");
      }

      return remoteTemplates;
    } catch (error, stack) {
      remoteTemplates = null;
      remoteTemplateStatus = LoadingStatus.error;
      notifyListeners();
      print(error);
      print(stack);
      rethrow;
    }
  }

  Future<WorkoutTemplate> getRemoteTemplate({
    required int id,
  }) {
    throw UnimplementedError();
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchRemoteTemplates(reload: true);
    });
  }
}
