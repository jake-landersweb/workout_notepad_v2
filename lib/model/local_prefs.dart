import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder.dart';
import 'package:workout_notepad_v2/logger.dart';

// holds local preferences of the app state. These are options that are not
// super important to tie to the account, and can handle being reset at any time.
// (though, this will really only happen if the app is deleted then re-installed)
class LocalPrefs extends ChangeNotifier {
  final String key;
  late SharedPreferences prefs;
  late final LocalPrefsDataModel _data;

  LocalPrefs({this.key = "local-prefs"}) {
    init();
  }

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(key);

    if (raw != null && raw.isNotEmpty) {
      logger.debug("local pref exists, attempting to decode");
      final decoded = jsonDecode(raw);
      _data = LocalPrefsDataModel.fromJson(decoded);
      logger.debug("successfully decoded");
    } else {
      logger.debug("local prefs do not exist, creating");
      _data = LocalPrefsDataModel();
      save();
    }
  }

  Future<bool> save() async {
    logger.debug("Saving local prefs");
    var resp = await prefs.setString(key, _data.toJson());
    if (!resp) {
      notifyListeners();
      return false;
    }
    notifyListeners();
    logger.debug("Successfully saved local prefs");
    return true;
  }

  Future<bool> clear() async {
    return prefs.remove(key);
  }

  String get defaultWeightPost => _data.defaultWeightPost;
  LBWeightNormalization get weightNormalization =>
      _data.defaultWeightPost == "lbs"
          ? LBWeightNormalization.LBS
          : LBWeightNormalization.KG;
  void setDefaultWeightPost(String value) {
    _data.defaultWeightPost = value;
    save();
  }
}

class LocalPrefsDataModel {
  String defaultWeightPost;

  LocalPrefsDataModel({
    this.defaultWeightPost = "lbs",
  });

  static fromJson(dynamic json) {
    var data = LocalPrefsDataModel();
    data.defaultWeightPost = json['defaultWeightPost'] ?? "lbs";
    return data;
  }

  Map<String, dynamic> toMap() {
    return {
      "defaultWeightPost": defaultWeightPost,
    };
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}
