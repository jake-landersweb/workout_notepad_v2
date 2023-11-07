import 'dart:convert';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:workout_notepad_v2/model/client.dart';
import 'package:http/http.dart' as http;
import 'package:workout_notepad_v2/model/root.dart';

class SnapshotMetadataItem {
  late String table;
  late int length;

  SnapshotMetadataItem({
    required this.table,
    required this.length,
  });

  SnapshotMetadataItem.fromJson(dynamic json) {
    table = json['table'];
    length = json['length'].round();
  }

  Map<String, dynamic> toMap() => {
        "table": table,
        "length": length,
      };

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    return other is SnapshotMetadataItem &&
        table == other.table &&
        length == other.length;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => super.hashCode;
}

class Snapshot {
  late String userId;
  late double created;
  late String createdStr;
  late String s3FileName;
  late List<SnapshotMetadataItem> metadata;
  Map<String, dynamic>? fileData;

  Snapshot({
    required this.userId,
    required this.created,
    required this.createdStr,
    required this.s3FileName,
  });

  Snapshot.fromJson(dynamic json) {
    userId = json['userId'];
    created = json['created'];
    createdStr = json['createdStr'];
    s3FileName = json['s3FileName'];
    metadata = [];
    for (var i in json['metadata']) {
      metadata.add(SnapshotMetadataItem.fromJson(i));
    }
  }

  /// Get the json blob of the snapshot
  Future<Map<String, dynamic>?> getFileData() async {
    try {
      var client = Client(client: http.Client());
      var response = await client.fetch("/users/$userId/snapshots/$created");
      if (response.statusCode != 200) {
        print("ERROR - There was an error with the request $response");
        return null;
      }
      Map<String, dynamic> body = jsonDecode(response.body);
      return body['body'];
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<List<Snapshot>?> getList(String userId) async {
    try {
      var client = Client(client: http.Client());
      var response = await client.fetch("/users/$userId/snapshots");
      if (response.statusCode != 200) {
        print("ERROR - There was an error with the request $response");
        return null;
      }
      Map<String, dynamic> body = jsonDecode(response.body);
      List<Snapshot> snapshots = [];
      for (var i in body['body']) {
        snapshots.add(Snapshot.fromJson(i));
      }
      return snapshots;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<List<Snapshot>?> snapshotDatabase(String userId) async {
    try {
      // get the database
      var db = await DatabaseProvider().database;
      // get all table names
      var response = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );

      Map<String, dynamic> data = {};

      // compose the data for dynamodb
      for (var i in response) {
        var r = await db.query(i['name'] as String);
        data[i['name'] as String] = r;
      }

      // encode to json
      String encoded = jsonEncode(data);

      var client = Client(client: http.Client());
      var httpResponse = await client.post(
        "/users/$userId/snapshots",
        {},
        encoded,
      );
      if (httpResponse.statusCode != 200) {
        print("ERROR - There was an error with the request $response");
        return null;
      }
      Map<String, dynamic> body = jsonDecode(httpResponse.body);
      List<Snapshot> snps = [];
      for (var i in body['body']) {
        snps.add(Snapshot.fromJson(i));
      }
      return snps;
    } catch (e) {
      NewrelicMobile.instance.recordError(
        e,
        StackTrace.current,
        attributes: {"err_code": "snapshot_create"},
      );
      return null;
    }
  }

  // gets the metadata that can be used to determine if the current snapshot metadata matches
  // another
  static Future<Snapshot> databaseSignature(String userId) async {
    // get the database
    var db = await DatabaseProvider().database;
    // get all table names
    var response = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );

    List<SnapshotMetadataItem> items = [];

    // compose the data for dynamodb
    for (var i in response) {
      var r = await db.query(i['name'] as String);
      items.add(
          SnapshotMetadataItem(table: i['name'] as String, length: r.length));
    }

    var s =
        Snapshot(userId: userId, created: 0, createdStr: "", s3FileName: "");
    s.metadata = items;
    return s;
  }

  int get workoutLength {
    return metadata.firstWhere((element) => element.table == "workout").length;
  }

  int get workoutLogLength {
    return metadata
        .firstWhere((element) => element.table == "workout_log")
        .length;
  }

  int get exerciseLength {
    return metadata.firstWhere((element) => element.table == "exercise").length;
  }

  int get exerciseLogLength {
    return metadata
        .firstWhere((element) => element.table == "exercise_log")
        .length;
  }

  Map<String, dynamic> toMap() => {
        "userId": userId,
        "created": created,
        "createdStr": createdStr,
        "s3FileName": s3FileName,
        "metadata": [for (var i in metadata) i.toMap()],
      };

  // checks if the snapshot signature is equal to another
  bool compareMetadata(Snapshot other) {
    if (other.metadata.length != metadata.length) {
      print("metadata length does not match");
      return false;
    }

    for (SnapshotMetadataItem metaItem in metadata) {
      if (!other.metadata.any((element) => element.table == metaItem.table)) {
        print("other does not contain: ${metaItem.table}");
        return false;
      }
      var tmpItem = other.metadata
          .firstWhere((element) => element.table == metaItem.table);
      if (tmpItem.length != metaItem.length) {
        print(
            "table: ${metaItem.table} tmpItem.length (${tmpItem.length}) != metaItem.length (${metaItem.length})");
        return false;
      }
    }

    return true;
  }

  @override
  String toString() => toMap().toString();
}
