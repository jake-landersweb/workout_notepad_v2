import 'dart:convert';

import 'package:workout_notepad_v2/model/client.dart';
import 'package:http/http.dart' as http;

class SubscriptionRecord {
  String purchaseId;
  String productId;
  String transactionDate;

  int active;
  int gracePeriod;
  int billingIssue;

  String store;
  String? promoCode;
  String userId;

  String created;
  String updated;

  SubscriptionRecord({
    required this.purchaseId,
    required this.productId,
    required this.transactionDate,
    required this.active,
    required this.gracePeriod,
    required this.billingIssue,
    required this.store,
    required this.promoCode,
    required this.userId,
    required this.created,
    required this.updated,
  });

  factory SubscriptionRecord.fromJson(Map<String, dynamic> json) {
    return SubscriptionRecord(
      purchaseId: json['purchaseId'],
      productId: json['productId'],
      transactionDate: json['transactionDate'],
      active: json['active'],
      gracePeriod: json['gracePeriod'],
      billingIssue: json['billingIssue'],
      store: json['store'],
      promoCode: json['promoCode'],
      userId: json['userId'],
      created: json['created'],
      updated: json['updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'purchaseId': purchaseId,
      'productId': productId,
      'transactionDate': transactionDate,
      'active': active,
      'gracePeriod': gracePeriod,
      'billingIssue': billingIssue,
      'store': store,
      'promoCode': promoCode,
      'userId': userId,
      'created': created,
      'updated': updated,
    };
  }

  static Future<SubscriptionRecord?> fromUserId(String userId) async {
    var client = PurchaseClient(client: http.Client());
    var response = await client.fetch("/users/$userId/subscription");
    client.client.close();

    if (response.statusCode != 200) {
      print("There was an issue getting the subscription data");
      print(response.body);
      throw "There was an error";
    }

    var body = jsonDecode(response.body);
    if (body == null) {
      print("No subscription record found");
      return null;
    }

    return SubscriptionRecord.fromJson(body);
  }

  String get title {
    switch (productId) {
      case "wn_premium":
        return "Premium (Monthly)";
      case "wn_premium_year":
        return "Premium (Yearly)";
      default:
        return "Unknown";
    }
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
