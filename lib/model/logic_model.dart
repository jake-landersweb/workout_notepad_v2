import 'package:flutter/material.dart';

enum TabBarPage { workouts, exercises, logs, settings }

/// This is a class for holding all of the app state that does not
/// persist between app launches. There is no references from
/// [SharedPreferences] or [SQLite].
class LogicModel extends ChangeNotifier {
  TabBarPage _tabBarIndex = TabBarPage.workouts;
  TabBarPage get tabBarIndex => _tabBarIndex;
  void setTabBarIndex(TabBarPage page) {
    _tabBarIndex = page;
    notifyListeners();
  }
}
