import 'package:flutter/foundation.dart';
import 'package:sqflite/sql.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/model/root.dart';

class User {
  late String id;
  String? email;
  String? firstName;
  String? lastName;
  String? phone;
  late int sync;
  Uint8List? password;
  Uint8List? salt;
  late String created;
  late String updated;

  User({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    required this.sync,
    this.password,
    this.salt,
    required this.created,
    required this.updated,
  });

  User.init() {
    var uuid = const Uuid();
    id = uuid.v4();
    sync = 0;
    created = "";
    updated = "";
  }

  User copy() => User(
        id: id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        sync: sync,
        password: password,
        salt: salt,
        created: created,
        updated: updated,
      );

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    phone = json['phone'];
    sync = json['sync'];
    password = json['password'];
    salt = json['salt'];
    created = json['created'];
    updated = json['updated'];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "email": email,
      "firstName": firstName,
      "lastName": lastName,
      "phone": phone,
      "sync": sync,
      "password": password,
      "salt": salt,
    };
  }

  Future<void> insert({ConflictAlgorithm? conflictAlgorithm}) async {
    final db = await getDB();
    await db.insert(
      'user',
      toMap(),
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.abort,
    );
  }

  static Future<User?> fromId(String id) async {
    final db = await getDB();
    final List<Map<String, dynamic>> response = await db.query('user');
    if (response.isEmpty) {
      return null;
    }
    return User.fromJson(response[0]);
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
