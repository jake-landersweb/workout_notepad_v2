import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';
import 'package:sqflite/sql.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';

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

    switch (collection.collectionType) {
      case CollectionType.repeat:
        var currentDate = collection.startDate;
        for (int repeats = 0; repeats < collection.numRepeats; repeats++) {
          for (var i in collection.items) {
            var c = i.clone();
            c.collectionItemId = const Uuid().v4();
            c.date = currentDate;
            items.add(c);
            currentDate = currentDate.add(Duration(days: c.daysBreak));
          }
        }
        return items;
      case CollectionType.days:
        List<CollectionItem> weekItems = [];
        // get the closest sunday in the past
        var daysToSubtract = collection.startDate.weekday % 7;
        var currentDate =
            collection.startDate.subtract(Duration(days: daysToSubtract));
        for (int i = 0; i < 7; i++) {
          // get all items from collection that match the day
          var tmpItems = collection.items.where((element) => element.day == i);
          // set the date on all items
          for (var item in tmpItems) {
            // check if date is in range of the current selected day
            item.date = currentDate;
            weekItems.add(item);
            // add a second to maintain order
            currentDate = currentDate.add(const Duration(seconds: 1));
          }
          currentDate = currentDate.add(const Duration(days: 1));
        }

        // clone the lists for the number of weeks
        for (var item in weekItems) {
          for (int i = 0; i < collection.numRepeats; i++) {
            var cloned = item.clone();
            cloned.collectionItemId = const Uuid().v4();
            cloned.date = cloned.date.add(Duration(days: 7 * i));
            // make sure item is in range of the collection start date
            if (cloned.date.compareTo(collection.startDate) >= 0) {
              items.add(cloned);
            }
          }
        }

        return items;
      case CollectionType.schedule:
        throw "unimplemented";
    }
  }

  Tuple2<bool, String> isValid() {
    if (collection.title.isEmpty) {
      return Tuple2(false, "The title cannot be empty");
    } else if (collection.description.isEmpty) {
      return Tuple2(false, "The description cannot be empty");
    } else if (collection.items.isEmpty) {
      return Tuple2(false, "Cannot create empty collection");
    } else {
      return Tuple2(true, "");
    }
  }

  Future<Tuple2<bool, String>> create() async {
    try {
      // create a transaction to insert this data into
      final db = await getDB();
      var resp = await db.transaction((txn) async {
        try {
          // insert the collection
          await txn.insert("collection", collection.toMap());
          // insert all collection items
          for (var i in getRenderedCollectionItems()) {
            await txn.insert(
              "collection_item",
              i.toMap(),
              conflictAlgorithm: ConflictAlgorithm.abort,
            );
          }
          return true;
        } catch (e) {
          print(e);
          throw Exception("Error occurred while inserting data: $e");
        }
      });
      if (resp) {
        print("Successfully created collection");
        return Tuple2(true, "Successfully created collection");
      } else {
        return Tuple2(
          false,
          "There was a fatal error with the database schema. Please contact support!",
        );
      }
    } catch (e) {
      print(e);
      return Tuple2(
        false,
        "There was a fatal error with the database schema. Please contact support!",
      );
    }
  }
}
