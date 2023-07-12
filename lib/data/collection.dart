import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';

enum CollectionType { repeat, days, schedule }

int collectionTypeToJson(CollectionType ct) {
  return CollectionType.values.indexOf(ct);
}

CollectionType collectionTypeFromJson(int ct) {
  try {
    return CollectionType.values[ct];
  } catch (e) {
    throw "Invalid collection type index: $ct";
  }
}

class Collection {
  late String collectionId;
  late String title;
  late CollectionType collectionType;
  late String description;
  late DateTime startDate;

  // number of times to repeat the pattern
  late int numRepeats;

  // not in DB
  late List<CollectionItem> items;

  String? created;
  String? updated;

  Collection({
    required this.collectionId,
    required this.title,
    required this.collectionType,
    required this.description,
    required this.startDate,
    required this.numRepeats,
    required this.items,
  });

  Collection clone() => Collection(
        collectionId: collectionId,
        title: title,
        collectionType: collectionType,
        description: description,
        startDate: startDate,
        numRepeats: numRepeats,
        items: [for (var i in items) i.clone()],
      );

  Collection.init() {
    collectionId = const Uuid().v4();
    title = "";
    collectionType = CollectionType.repeat;
    description = "";
    startDate = DateTime.now().add(const Duration(days: 1));
    numRepeats = 5;
    items = [];
  }

  Collection.fromJson(dynamic json) {
    collectionId = json['collectionId'];
    title = json['title'];
    collectionType = collectionTypeFromJson(json['collectionType']);
    description = json['description'];
    startDate = DateTime.parse(json['startDate']);
    numRepeats = json['numRepeats'];
    created = json['created'];
    updated = json['updated'];
  }

  static Future<List<Collection>> getList({
    Database? db,
  }) async {
    db ??= await getDB();

    var response = await db.rawQuery("SELECT * FROM collection");
    List<Collection> collections = [];
    for (var i in response) {
      var c = Collection.fromJson(i);
      var items = await c.fetchItems(db: db);
      if (items == null) {
        throw "ERROR items was null";
      }
      c.items = items;
      collections.add(c);
    }
    return collections;
  }

  /// get all collection items for this collection
  Future<List<CollectionItem>?> fetchItems({Database? db}) async {
    try {
      db ??= await getDB();

      var response = await db.rawQuery(
        """
          SELECT * FROM collection_item
          WHERE collectionId = '$collectionId'
          ORDER BY date
        """,
      );

      List<CollectionItem> tmpItems = [];

      for (var i in response) {
        var item = CollectionItem.fromJson(i);
        item.workout = await item.getWorkout(db: db);
        tmpItems.add(item);
      }
      return tmpItems;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Map<String, dynamic> toMap() => {
        "collectionId": collectionId,
        "title": title,
        "collectionType": collectionTypeToJson(collectionType),
        "description": description,
        "startDate": startDate.toIso8601String(),
        "numRepeats": numRepeats,
      };

  Future<int> insert({ConflictAlgorithm? conflictAlgorithm}) async {
    final db = await getDB();
    var response = await db.insert(
      'collection',
      toMap(),
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.replace,
    );
    return response;
  }

  /// gets the next most recent item that is today or in the future
  CollectionItem? get nextItem {
    var filtered = items.where((element) =>
        element.date.compareTo(DateTime.now()) >= 0 &&
        element.workoutLogId == null);
    if (filtered.isEmpty) {
      return null;
    }
    return filtered.first;
  }

  @override
  String toString() => toMap().toString();
}

class CollectionItem {
  // for all
  late String collectionItemId;
  late String collectionId;
  late String workoutId;
  // date of the workout
  late DateTime date;
  late int daysBreak;
  late int day;
  // for tracking the completion
  String? workoutLogId;

  String? created;
  String? updated;

  // not in DB
  WorkoutCategories? workout;

  CollectionItem({
    required this.collectionItemId,
    required this.collectionId,
    required this.workoutId,
    required this.date,
    required this.daysBreak,
    required this.day,
    this.workoutLogId,
    this.workout,
  });

  CollectionItem clone() => CollectionItem(
        collectionItemId: collectionItemId,
        collectionId: collectionId,
        workoutId: workoutId,
        date: date,
        daysBreak: daysBreak,
        day: day,
        workoutLogId: workoutLogId,
        workout: workout?.clone(),
      );

  CollectionItem.init({
    required this.collectionId,
    required this.workoutId,
  }) {
    collectionItemId = const Uuid().v4();
    date = DateTime.now();
    daysBreak = 1;
    day = 0;
  }

  CollectionItem.fromWorkout({
    required this.collectionId,
    required WorkoutCategories wc,
  }) {
    workout = wc.clone();
    workoutId = workout!.workout.workoutId;
    collectionItemId = const Uuid().v4();
    date = DateTime.now();
    daysBreak = 1;
    day = 0;
  }

  CollectionItem.fromJson(dynamic json) {
    collectionItemId = json['collectionItemId'];
    collectionId = json['collectionId'];
    workoutId = json['workoutId'];
    date = DateTime.parse(json['date']);
    daysBreak = json['daysBreak'];
    day = json['day'];
    workoutLogId = json['workoutLogId'];
    created = json['created'];
    updated = json['updated'];
  }

  Future<WorkoutCategories?> getWorkout({Database? db}) async {
    try {
      db ??= await getDB();
      var response = await db.rawQuery("""
        SELECT * FROM workout
        WHERE workoutId = '$workoutId'
      """);
      if (response.isEmpty) {
        throw ("ERROR: no workout found");
      }
      var w = Workout.fromJson(response[0]);
      var cats = await w.getCategories();
      return WorkoutCategories(workout: w, categories: cats);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Map<String, dynamic> toMap() => {
        "collectionItemId": collectionItemId,
        "collectionId": collectionId,
        "workoutId": workoutId,
        "date": date.toIso8601String(),
        "daysBreak": daysBreak,
        "day": day,
        "workoutLogId": workoutLogId,
      };

  Future<int> insert({ConflictAlgorithm? conflictAlgorithm}) async {
    final db = await getDB();
    var response = await db.insert(
      'collection_item',
      toMap(),
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.replace,
    );
    return response;
  }

  String get dateStr {
    List<String> dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    List<String> monthNames = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    String dayName = dayNames[date.weekday - 1];
    String monthName = monthNames[date.month];
    String dayNum = date.day.toString();

    return '$dayName, $monthName $dayNum';
  }

  @override
  String toString() => toMap().toString();
}
