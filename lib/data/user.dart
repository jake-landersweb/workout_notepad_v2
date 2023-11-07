import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/model/client.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:http/http.dart' as http;

enum SubscriptionType { none, wn_unlocked }

SubscriptionType subStatusFromJson(String? status) {
  switch (status) {
    case "wn_unlocked":
    case "wn_unlocked_promo":
      return SubscriptionType.wn_unlocked;
    default:
      return SubscriptionType.none;
  }
}

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
  bool offline = false;
  late SubscriptionType subscriptionType = SubscriptionType.none;
  int? subscriptionEstimatedExpireEpoch;
  int? subscriptionTransactionEpoch;
  String? anonUserId;

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
    this.anonUserId,
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
        anonUserId: anonUserId,
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
    if (json.containsKey("created")) {
      created = json['created'].round();
    }
    if (json.containsKey("updated")) {
      updated = json['updated'].round();
    }
    subscriptionType = subStatusFromJson(json['subscriptionType']);
    subscriptionEstimatedExpireEpoch =
        json['subscriptionEstimatedExpireEpoch']?.round();
    subscriptionTransactionEpoch =
        json['subscriptionTransactionEpoch']?.round();
    anonUserId = json['anonUserId'];
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
      "subscriptionEstimatedExpireEpoch": subscriptionEstimatedExpireEpoch,
      "subscriptionTransactionEpoch": subscriptionTransactionEpoch,
      "anonUserId": anonUserId,
    };
  }

  static Future<User?> loginAuth(
    auth.UserCredential credential, {
    bool convertFromAnon = false,
    String? anonUserId,
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
          "signInMethod": credential.credential?.signInMethod ?? "unknown",
          "anonUserId": anonUserId,
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
      NewrelicMobile.instance.recordError(
        error,
        StackTrace.current,
        attributes: {"err_code": "login_auth"},
      );
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
      NewrelicMobile.instance.recordError(
        error,
        StackTrace.current,
        attributes: {"err_code": "login_anon"},
      );
      print("UNKNOWN ERROR - $error");
      return null;
    }
  }

  static Future<User?> fromId(String uid) async {
    try {
      var client = Client(client: http.Client());
      var response = await client.fetch("/users/$uid");
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
      NewrelicMobile.instance.recordError(
        error,
        StackTrace.current,
        attributes: {"err_code": "login_fromid"},
      );
      print("UNKNOWN ERROR - $error");
      return null;
    }
  }

  Future<bool> delete() async {
    try {
      var client = Client(client: http.Client());
      var response = await client.delete("/users/$userId");
      if (response.statusCode != 200) {
        print("ERROR - There was an error with the request ${response.body}");
        return false;
      }
      return true;
    } catch (error) {
      NewrelicMobile.instance.recordError(
        error,
        StackTrace.current,
        attributes: {"err_code": "user_delete"},
      );
      print("UNKNOWN ERROR - $error");
      return false;
    }
  }

  Widget avatar(BuildContext context, {double size = 120}) {
    if (offline) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Align(
          child: ClipOval(
            child: SvgPicture.asset(
              "assets/svg/default_profile.svg",
              height: size,
              fit: BoxFit.fitHeight,
              placeholderBuilder: (context) {
                return LoadingIndicator(
                    color: Theme.of(context).colorScheme.primary);
              },
            ),
          ),
        ),
      );
    }
    var defaultAvatar = SvgPicture.network(
      "https://source.boringavatars.com/beam/120/$userId?colors=418A2F,DD7373,4B3F72,283044",
      height: size,
      fit: BoxFit.fitHeight,
      placeholderBuilder: (context) {
        return LoadingIndicator(color: Theme.of(context).colorScheme.primary);
      },
    );
    if (imgUrl == null ||
        imgUrl == "" ||
        (imgUrl?.contains("default") ?? false)) {
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

  // bool isPremiumUser() {
  //   switch (subscriptionType) {
  //     case SubscriptionType.none:
  //       return false;
  //     case SubscriptionType.wn_unlocked:
  //       return true;
  //   }
  // }

  String getName() {
    if (displayName == null || displayName == "") {
      return "Unknown User";
    } else {
      return displayName!;
    }
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
