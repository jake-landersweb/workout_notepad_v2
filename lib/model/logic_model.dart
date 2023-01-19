import 'package:flutter/material.dart';

/// This is a class for holding all of the app state that does not
/// persist between app launches. There is no references from
/// [SharedPreferences] or [SQLite].
class LogicModel extends ChangeNotifier {
  int _tabBarIndex = 0;
  int get tabBarIndex => _tabBarIndex;
  void setTabBarIndex(int index) {
    _tabBarIndex = index;
    notifyListeners();
  }
}
