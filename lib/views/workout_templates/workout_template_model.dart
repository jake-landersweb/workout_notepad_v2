import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/data/workout_template.dart';
import 'package:workout_notepad_v2/logger.dart';
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
  LoadingStatus homeTemplateStatus = LoadingStatus.loading;
  LoadingStatus searchTemplateStatus = LoadingStatus.loading;

  Map<String, List<WorkoutTemplate>>? homepageData;

  late TextEditingController textEditingController;
  Timer? _debounce;
  List<String> categories = [];

  Future<List<WorkoutTemplate>?> getHomepageData({
    bool reload = false,
  }) async {
    try {
      if (homepageData == null || homepageData!.isEmpty || reload) {
        logger.info("Fetching the workout template dashboard ...");
        homeTemplateStatus = LoadingStatus.loading;
        notifyListeners();
        String path = "/v2/templates/home";
        var response = await client.fetch(path);
        if (response.statusCode != 200) {
          throw Exception(
              "message=\"failed to query the remote templates\" status=${response.statusCode} body=\"${response.body}\"");
        }

        // parse the templates
        var decoded = jsonDecode(response.body);
        Map<String, List<WorkoutTemplate>> tmpData = {};

        for (var item in (decoded as Map<String, dynamic>).entries) {
          List<WorkoutTemplate> tmp = [];
          for (var i in item.value) {
            tmp.add(WorkoutTemplate.fromJson(i));
          }
          tmpData[item.key] = tmp;
        }

        homepageData = tmpData;
        homeTemplateStatus = LoadingStatus.done;
        notifyListeners();
        logger.info("Successfully fetched remote template homepage");
      }

      return remoteTemplates;
    } catch (error, stack) {
      remoteTemplates = null;
      homeTemplateStatus = LoadingStatus.error;
      notifyListeners();
      logger.exception(error, stack);
      rethrow;
    }
  }

  Future<List<WorkoutTemplate>?> searchRemoteTemplates({
    bool reload = false,
  }) async {
    try {
      if (remoteTemplates == null || remoteTemplates!.isEmpty || reload) {
        var l = logger.withData({
          "categories": categories,
          "searchText": textEditingController.text,
        });
        l.info("Searching the remote workout templates ...");
        searchTemplateStatus = LoadingStatus.loading;
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
              "message=\"failed to search the remote templates\" status=${response.statusCode} body=\"${response.body}\"");
        }

        // parse the templates
        var decoded = jsonDecode(response.body);
        List<WorkoutTemplate> items = [];
        for (var i in decoded) {
          items.add(WorkoutTemplate.fromJson(i));
        }
        remoteTemplates = items;
        searchTemplateStatus = LoadingStatus.done;
        notifyListeners();
        l.info(
          "Successfully searched remote templates",
          {"length": items.length},
        );
      }

      return remoteTemplates;
    } catch (error, stack) {
      remoteTemplates = null;
      searchTemplateStatus = LoadingStatus.error;
      notifyListeners();
      logger.exception(error, stack);
      rethrow;
    }
  }

  Future<WorkoutTemplate> getRemoteTemplate({
    required int id,
  }) {
    throw UnimplementedError();
  }

  bool _beginningEmpty = true;
  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // ensure we do not run a search when the user clicks into the text box
      // because an empty text event is sent. But we also want the text to
      // re-search when the user deletes until the box is empty.
      if (_beginningEmpty) {
        if (textEditingController.text.isNotEmpty) {
          _beginningEmpty = false;
          searchRemoteTemplates(reload: true);
        }
      } else {
        if (textEditingController.text.isEmpty) {
          _beginningEmpty = true;
        }
        searchRemoteTemplates(reload: true);
      }
    });
  }
}
