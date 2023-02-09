import 'package:flutter/material.dart';

enum TabBarPage { workouts, exercises, logs, settings }

/// This is a class for holding all of the app state decdoupled from the user
/// [SharedPreferences] or [SQLite].
class LogicModel extends ChangeNotifier {
  TabBarPage _tabBarIndex = TabBarPage.workouts;
  TabBarPage get tabBarIndex => _tabBarIndex;
  void setTabBarIndex(TabBarPage page) {
    _tabBarIndex = page;
    notifyListeners();
  }
}
