import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesAuthStore extends AuthStore {
  final SharedPreferences prefs;
  final String key;

  SharedPreferencesAuthStore(this.prefs, {this.key = "pb_auth"}) {
    final String? raw = prefs.getString(key);

    if (raw != null && raw.isNotEmpty) {
      print("auth has keys");
      final decoded = jsonDecode(raw);
      final token = (decoded as Map<String, dynamic>)["token"] as String? ?? "";
      final model =
          RecordModel.fromJson(decoded["model"] as Map<String, dynamic>? ?? {});

      save(token, model);
    }
  }

  @override
  void save(
    String newToken,
    dynamic /* RecordModel|AdminModel|null */ newModel,
  ) {
    super.save(newToken, newModel);

    final encoded =
        jsonEncode(<String, dynamic>{"token": newToken, "model": newModel});
    prefs.setString(key, encoded);
  }

  @override
  void clear() {
    super.clear();
    prefs.remove(key);
  }
}
