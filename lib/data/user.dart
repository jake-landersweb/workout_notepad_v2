import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/model/client.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:http/http.dart' as http;

class User {
  late String userId;
  String? email;
  String? displayName;
  String? phone;
  String? imgUrl;
  late int sync;
  late bool isAnon;
  late int expireEpoch;
  int? created;
  int? updated;

  User({
    required this.userId,
    this.email,
    this.displayName,
    this.phone,
    this.imgUrl,
    required this.sync,
    required this.isAnon,
    required this.expireEpoch,
    required this.created,
    required this.updated,
  });

  User copy() => User(
        userId: userId,
        email: email,
        displayName: displayName,
        phone: phone,
        imgUrl: imgUrl,
        sync: sync,
        isAnon: isAnon,
        expireEpoch: expireEpoch,
        created: created,
        updated: updated,
      );

  User.initTest() {
    userId = "1";
    sync = 0;
    isAnon = false;
    expireEpoch = -1;
  }

  User.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    email = json['email'];
    displayName = json['displayName'];
    phone = json['phone'];
    imgUrl = json['imgUrl'];
    sync = json['sync'].round();
    isAnon = json['isAnon'];
    expireEpoch = json['expireEpoch'].round();
    created = json['created'].round();
    updated = json['updated'].round();
  }

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "email": email,
      "displayName": displayName,
      "phone": phone,
      "imgUrl": imgUrl,
      "sync": sync,
      "isAnon": isAnon,
      "expireEpoch": expireEpoch,
    };
  }

  static Future<User?> loginAuth(
    auth.UserCredential credential, {
    bool convertFromAnon = false,
  }) async {
    try {
      if (credential.user == null) {
        print("ERROR - The user credential was null");
        return null;
      }
      var client = Client(client: http.Client());
      var response = await client.post(
        "/login",
        {},
        jsonEncode({
          "userId": credential.user!.uid,
          "email": credential.user!.email,
          "displayName": credential.user!.displayName,
          "phone": credential.user!.phoneNumber,
          "imgUrl": credential.user!.photoURL,
          "convertFromAnon": convertFromAnon,
        }),
      );
      if (response.statusCode != 200) {
        print("ERROR - There was an error with the request ${response.body}");
        return null;
      }
      Map<String, dynamic> body = jsonDecode(response.body);
      if (!body.containsKey("status") || body['status'] != 200) {
        print(body);
        return null;
      }
      var user = User.fromJson(body['body']);
      // save userid
      var prefs = await SharedPreferences.getInstance();
      prefs.setString("userId", user.userId);
      return user;
    } catch (error) {
      print("UNKNOWN ERROR - $error");
      return null;
    }
  }

  static Future<User?> loginAnon() async {
    try {
      var client = Client(client: http.Client());
      var response = await client.post(
        "/login",
        {},
        jsonEncode({
          "userId": const Uuid().v4(),
          "isAnon": true,
          "expireEpoch": DateTime.now()
              .add(const Duration(days: 3))
              .millisecondsSinceEpoch,
        }),
      );
      if (response.statusCode != 200) {
        print("ERROR - There was an error with the request $response");
        return null;
      }
      Map<String, dynamic> body = jsonDecode(response.body);
      if (!body.containsKey("status") || body['status'] != 200) {
        print(body);
        return null;
      }
      var user = User.fromJson(body['body']);
      // save userid
      var prefs = await SharedPreferences.getInstance();
      prefs.setString("userId", user.userId);
      return user;
    } catch (error) {
      print("UNKNOWN ERROR - $error");
      return null;
    }
  }

  static Future<User?> fromId(String uid) async {
    try {
      var client = Client(client: http.Client());
      var response = await client.fetch("/users/$uid");
      if (response.statusCode != 200) {
        print("ERROR - There was an error with the request $response");
        return null;
      }
      Map<String, dynamic> body = jsonDecode(response.body);
      if (!body.containsKey("status") || body['status'] != 200) {
        print(body);
        return null;
      }
      var user = User.fromJson(body['body']);
      // save userid
      var prefs = await SharedPreferences.getInstance();
      prefs.setString("userId", user.userId);
      return user;
    } catch (error) {
      print("UNKNOWN ERROR - $error");
      return null;
    }
  }

  Widget avatar(BuildContext context, {double size = 120}) {
    var defaultAvatar = SvgPicture.network(
      "https://source.boringavatars.com/beam/120/$userId?colors=418A2F,DD7373,4B3F72,283044",
      height: size,
      fit: BoxFit.fitHeight,
      placeholderBuilder: (context) {
        return LoadingIndicator(color: Theme.of(context).colorScheme.primary);
      },
    );
    if (imgUrl == null || imgUrl == "") {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Align(
          child: ClipOval(
            child: defaultAvatar,
          ),
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Align(
          child: ClipOval(
            child: Image.network(
              imgUrl!,
              height: size,
              fit: BoxFit.fitHeight,
              errorBuilder: (context, error, stackTrace) {
                return defaultAvatar;
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return LoadingIndicator(
                    color: Theme.of(context).colorScheme.primary);
              },
            ),
          ),
        ),
      );
    }
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
