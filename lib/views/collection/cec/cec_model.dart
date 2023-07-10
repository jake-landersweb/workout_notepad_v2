import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/data/collection.dart';

class CECModel extends ChangeNotifier {
  late bool isCreate;
  late Collection collection;
  int _index = 0;
  int get index => _index;
  late PageController pageController;

  CECModel({Collection? collection}) {
    if (collection == null) {
      isCreate = true;
      this.collection = Collection.init();
    } else {
      isCreate = false;
      this.collection = collection.clone();
    }
    pageController = PageController(initialPage: index);
  }

  void refresh() {
    notifyListeners();
  }

  void setPage(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 700),
      curve: Sprung(36),
    );
  }

  void setIndex(int i) {
    _index = i;
    notifyListeners();
  }

  List<String> get workoutIds {
    return collection.items.map((e) => e.workout!.workout.workoutId).toList();
  }

  List<CollectionItem> getRenderedCollectionItems() {
    List<CollectionItem> items = [];
    var currentDate = collection.startDate;
    for (int repeats = 0; repeats < collection.numRepeats; repeats++) {
      for (var i in collection.items) {
        var c = i.clone();
        c.date = currentDate;
        items.add(c);
        currentDate = currentDate.add(Duration(days: c.daysBreak));
      }
    }
    return items;
  }
}
