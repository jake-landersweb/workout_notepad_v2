import 'package:flutter/material.dart';

/// This is a class for holding all of the app state decdoupled from the user
/// [SharedPreferences] or [SQLite].
class LogicModel extends ChangeNotifier {
  int _tabBarIndex = 0;
  int get tabBarIndex => _tabBarIndex;
  void setTabBarIndex(int page) {
    _tabBarIndex = page;
    notifyListeners();
  }
}
