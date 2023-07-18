import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';

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
  late int startDate;
  DateTime get datetime {
    return DateTime.fromMillisecondsSinceEpoch(startDate);
  }

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
    startDate =
        DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch;
    numRepeats = 5;
    items = [];
  }

  static Future<Collection> fromJson(dynamic json) async {
    var c = Collection(
      collectionId: json['collectionId'],
      title: json['title'],
      collectionType: collectionTypeFromJson(json['collectionType']),
      description: json['description'],
      startDate: json['startDate'],
      numRepeats: json['numRepeats'],
      items: [],
    );
    c.items = await c.fetchItems() ?? [];
    return c;
  }

  static Future<List<Collection>> getList({
    Database? db,
  }) async {
    db ??= await getDB();

    var response = await db.rawQuery("""
      SELECT * FROM collection
      ORDER BY startDate
    """);
    List<Collection> collections = [];
    for (var i in response) {
      var c = await Collection.fromJson(i);
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
        var item = await CollectionItem.fromJson(i);
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
        "startDate": startDate,
        "numRepeats": numRepeats,
      };

  /// gets the next most recent item that is today or in the future
  CollectionItem? get nextItem {
    var filtered = items.where(
      (element) =>
          element.date >
              DateTime.now()
                  .subtract(const Duration(days: 1))
                  .millisecondsSinceEpoch &&
          element.workoutLogId == null,
    );
    if (filtered.isEmpty) {
      return null;
    }
    return filtered.first;
  }

  String get dateRange {
    if (items.isEmpty) {
      return "";
    }
    return "${items.first.dateStr} - ${items.last.dateStr}";
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
  late int date;
  DateTime get datetime => DateTime.fromMillisecondsSinceEpoch(date);
  late int daysBreak;
  late int day;
  // for tracking the completion
  String? workoutLogId;

  String? created;
  String? updated;

  // not in DB
  Workout? workout;
  String? collectionTitle;

  CollectionItem({
    required this.collectionItemId,
    required this.collectionId,
    required this.workoutId,
    required this.date,
    required this.daysBreak,
    required this.day,
    this.workoutLogId,
    this.workout,
    this.collectionTitle,
  });

  CollectionItem clone() => CollectionItem(
        collectionItemId: collectionItemId,
        collectionId: collectionId,
        workoutId: workoutId,
        date: date,
        daysBreak: daysBreak,
        day: day,
        workoutLogId: workoutLogId,
        workout: workout?.copy(),
        collectionTitle: collectionTitle,
      );

  CollectionItem.init({
    required this.collectionId,
    required this.workoutId,
  }) {
    collectionItemId = const Uuid().v4();
    date = DateTime.now().millisecondsSinceEpoch;
    daysBreak = 1;
    day = 0;
  }

  CollectionItem.fromWorkout({
    required this.collectionId,
    required Workout w,
  }) {
    workout = w.copy();
    workoutId = w.workoutId;
    collectionItemId = const Uuid().v4();
    date = DateTime.now().millisecondsSinceEpoch;
    daysBreak = 1;
    day = 0;
  }

  static Future<CollectionItem> fromJson(dynamic json) async {
    var ci = CollectionItem(
      collectionItemId: json['collectionItemId'],
      collectionId: json['collectionId'],
      workoutId: json['workoutId'],
      date: json['date'],
      daysBreak: json['daysBreak'],
      day: json['day'],
      workoutLogId: json['workoutLogId'],
      collectionTitle: json['title'],
    );
    ci.workout = await ci.getWorkout();
    return ci;
  }

  Future<Workout?> getWorkout({Database? db}) async {
    try {
      db ??= await getDB();
      var response = await db.rawQuery("""
        SELECT * FROM workout
        WHERE workoutId = '$workoutId'
      """);
      if (response.isEmpty) {
        throw ("ERROR: no workout found");
      }
      return await Workout.fromJson(response[0]);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Map<String, dynamic> toMap() => {
        "collectionItemId": collectionItemId,
        "collectionId": collectionId,
        "workoutId": workoutId,
        "date": date,
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

  String get dateStr => formatDateTime(datetime);

  @override
  String toString() => toMap().toString();
}
