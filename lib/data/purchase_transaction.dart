import 'package:flutter/material.dart';

enum PurchaseTransactionType { assign, revoke, restore, other }

PurchaseTransactionType purchaseTransactionTypefromJson(String val) {
  switch (val) {
    case "assign_purchase":
      return PurchaseTransactionType.assign;
    case "revoke_purchase":
      return PurchaseTransactionType.revoke;
    case "restore_purchase":
      return PurchaseTransactionType.restore;
    default:
      return PurchaseTransactionType.other;
  }
}

class PurchaseTransaction {
  late int transactionActivityId;
  late String purchaseId;
  late PurchaseTransactionType transactionType;
  late DateTime created;
  late String productId;

  PurchaseTransaction({
    required this.transactionActivityId,
    required this.purchaseId,
    required this.transactionType,
    required this.created,
    required this.productId,
  });

  PurchaseTransaction.fromJson(dynamic json) {
    transactionActivityId = json['transactionActivityId'];
    purchaseId = json['purchaseId'];
    transactionType = purchaseTransactionTypefromJson(json['transactionType']);
    created = DateTime.fromMillisecondsSinceEpoch(json['created']);
    productId = json['productId'];
  }

  String getTitle() {
    switch (transactionType) {
      case PurchaseTransactionType.assign:
        return "Assign Puchase";
      case PurchaseTransactionType.revoke:
        return "Revoke Purchase";
      case PurchaseTransactionType.restore:
        return "Restore Purchase";
      case PurchaseTransactionType.other:
        return "Other";
    }
  }

  IconData getIcon() {
    switch (transactionType) {
      case PurchaseTransactionType.assign:
        return Icons.payments_rounded;
      case PurchaseTransactionType.revoke:
        return Icons.currency_exchange_rounded;
      case PurchaseTransactionType.restore:
        return Icons.settings_backup_restore_rounded;
      case PurchaseTransactionType.other:
        return Icons.question_mark_rounded;
    }
  }
}
