import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout.dart';
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

  // CollectionType.repeat number of times to repeat
  late int numRepeats;
  // CollectionType.(days,schedule) number of weeks for this program
  late int numWeeks;

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
    required this.numWeeks,
    required this.items,
  });

  Collection clone() => Collection(
        collectionId: collectionId,
        title: title,
        collectionType: collectionType,
        description: description,
        startDate: startDate,
        numRepeats: numRepeats,
        numWeeks: numWeeks,
        items: [for (var i in items) i.clone()],
      );

  Collection.init() {
    collectionId = const Uuid().v4();
    title = "";
    collectionType = CollectionType.repeat;
    description = "";
    startDate = DateTime.now().add(const Duration(days: 1));
    numRepeats = 5;
    numWeeks = 12;
    items = [];
  }

  Collection.fromJson(dynamic json) {
    collectionId = json['collectionId'];
    title = json['title'];
    collectionType = collectionTypeFromJson(json['collectionType']);
    description = json['description'];
    startDate = DateTime.parse(json['startDate']);
    numRepeats = json['numRepeats'];
    numWeeks = json['numWeeks'];
    created = json['created'];
    updated = json['updated'];
  }

  static Future<List<Collection>> getList({
    required String collectionId,
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
        "numWeeks": numWeeks,
      };

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
    this.workoutLogId,
    this.workout,
  });

  CollectionItem clone() => CollectionItem(
        collectionItemId: collectionItemId,
        collectionId: collectionId,
        workoutId: workoutId,
        date: date,
        daysBreak: daysBreak,
        workoutLogId: workoutLogId,
        workout: workout?.clone(),
      );

  CollectionItem.init({
    required this.collectionId,
    required this.workoutId,
  }) {
    collectionItemId = const Uuid().v4();
    date = DateTime.now();
    daysBreak = 0;
  }

  CollectionItem.fromWorkout({
    required this.collectionId,
    required WorkoutCategories wc,
  }) {
    workout = wc.clone();
    workoutId = workout!.workout.workoutId;
    collectionItemId = const Uuid().v4();
    date = DateTime.now();
    daysBreak = 0;
  }

  CollectionItem.fromJson(dynamic json) {
    collectionItemId = json['collectionItemId'];
    collectionId = json['collectionId'];
    workoutId = json['workoutId'];
    date = DateTime.parse(json['date']);
    daysBreak = json['daysBreak'];
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
        "workoutLogId": workoutLogId,
      };

  @override
  String toString() => toMap().toString();
}
