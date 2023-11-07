class NotificationPayload {
  String notificationType;
  String subtype;
  String notificationUUID;
  String notificationVersion;
  NotificationData data;

  NotificationPayload({
    required this.notificationType,
    required this.subtype,
    required this.notificationUUID,
    required this.notificationVersion,
    required this.data,
  });

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    return NotificationPayload(
      notificationType: json['notificationType'],
      subtype: json['subtype'],
      notificationUUID: json['notificationUUID'],
      notificationVersion: json['notificationVersion'],
      data: NotificationData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toMap() => {
        "notificationType": notificationType,
        "subtype": subtype,
        "notificationUUID": notificationUUID,
        "notificationVersion": notificationVersion,
        "data": data.toMap(),
      };

  @override
  String toString() => toMap().toString();
}

class NotificationData {
  int appAppleID;
  String bundleID;
  String bundleVersion;
  String environment;
  String signedRenewalInfo;
  String signedTransactionInfo;

  NotificationData({
    required this.appAppleID,
    required this.bundleID,
    required this.bundleVersion,
    required this.environment,
    required this.signedRenewalInfo,
    required this.signedTransactionInfo,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      appAppleID: json['appAppleId'],
      bundleID: json['bundleId'],
      bundleVersion: json['bundleVersion'],
      environment: json['environment'],
      signedRenewalInfo: json['signedRenewalInfo'],
      signedTransactionInfo: json['signedTransactionInfo'],
    );
  }

  Map<String, dynamic> toMap() => {
        "appAppleID": appAppleID,
        "bundleID": bundleID,
        "bundleVersion": bundleVersion,
        "environment": environment,
        "signedRenewalInfo": signedRenewalInfo,
        "signedTransactionInfo": signedTransactionInfo,
      };

  @override
  String toString() => toMap().toString();
}

class TransactionInfo {
  String appAccountToken;
  String bundleId;
  String currency;
  String environment;
  int expiresDate;
  String inAppOwnershipType;
  bool isUpgraded;
  String offerDiscountType;
  String offerIdentifier;
  int offerType;
  int originalPurchaseDate;
  String originalTransactionId;
  int price;
  String productId;
  int purchaseDate;
  int quantity;
  int revocationDate;
  String revocationReason;
  int signedDate;
  String storefront;
  String storefrontId;
  String subscriptionGroupIdentifier;
  String transactionId;
  String transactionReason;
  String type;
  String webOrderLineItemId;

  TransactionInfo({
    required this.appAccountToken,
    required this.bundleId,
    required this.currency,
    required this.environment,
    required this.expiresDate,
    required this.inAppOwnershipType,
    required this.isUpgraded,
    required this.offerDiscountType,
    required this.offerIdentifier,
    required this.offerType,
    required this.originalPurchaseDate,
    required this.originalTransactionId,
    required this.price,
    required this.productId,
    required this.purchaseDate,
    required this.quantity,
    required this.revocationDate,
    required this.revocationReason,
    required this.signedDate,
    required this.storefront,
    required this.storefrontId,
    required this.subscriptionGroupIdentifier,
    required this.transactionId,
    required this.transactionReason,
    required this.type,
    required this.webOrderLineItemId,
  });

  factory TransactionInfo.fromJson(Map<String, dynamic> json) =>
      TransactionInfo(
        appAccountToken: json['appAccountToken'] as String,
        bundleId: json['bundleId'] as String,
        currency: json['currency'] as String,
        environment: json['environment'] as String,
        expiresDate: json['expiresDate'] as int,
        inAppOwnershipType: json['inAppOwnershipType'] as String,
        isUpgraded: json['isUpgraded'] as bool,
        offerDiscountType: json['offerDiscountType'] as String,
        offerIdentifier: json['offerIdentifier'] as String,
        offerType: json['offerType'] as int,
        originalPurchaseDate: json['originalPurchaseDate'] as int,
        originalTransactionId: json['originalTransactionId'] as String,
        price: json['price'] as int,
        productId: json['productId'] as String,
        purchaseDate: json['purchaseDate'] as int,
        quantity: json['quantity'] as int,
        revocationDate: json['revocationDate'] as int,
        revocationReason: json['revocationReason'] as String,
        signedDate: json['signedDate'] as int,
        storefront: json['storefront'] as String,
        storefrontId: json['storefrontId'] as String,
        subscriptionGroupIdentifier:
            json['subscriptionGroupIdentifier'] as String,
        transactionId: json['transactionId'] as String,
        transactionReason: json['transactionReason'] as String,
        type: json['type'] as String,
        webOrderLineItemId: json['webOrderLineItemId'] as String,
      );

  Map<String, dynamic> toMap() => {
        "appAccountToken": appAccountToken,
        "bundleId": bundleId,
        "currency": currency,
        "environment": environment,
        "expiresDate": expiresDate,
        "inAppOwnershipType": inAppOwnershipType,
        "isUpgraded": isUpgraded,
        "offerDiscountType": offerDiscountType,
        "offerIdentifier": offerIdentifier,
        "offerType": offerType,
        "originalPurchaseDate": originalPurchaseDate,
        "originalTransactionId": originalTransactionId,
        "price": price,
        "productId": productId,
        "purchaseDate": purchaseDate,
        "quantity": quantity,
        "revocationDate": revocationDate,
        "revocationReason": revocationReason,
        "signedDate": signedDate,
        "storefront": storefront,
        "storefrontId": storefrontId,
        "subscriptionGroupIdentifier": subscriptionGroupIdentifier,
        "transactionId": transactionId,
        "transactionReason": transactionReason,
        "type": type,
        "webOrderLineItemId": webOrderLineItemId,
      };

  @override
  String toString() => toMap().toString();
}

class RenewalInfo {
  String originalTransactionId;
  int expirationIntent;
  String autoRenewProductId;
  String productId;
  int autoRenewStatus;
  bool isInBillingRetryPeriod;
  int signedDate;
  String environment;

  RenewalInfo({
    required this.originalTransactionId,
    required this.expirationIntent,
    required this.autoRenewProductId,
    required this.productId,
    required this.autoRenewStatus,
    required this.isInBillingRetryPeriod,
    required this.signedDate,
    required this.environment,
  });
  factory RenewalInfo.fromJson(Map<String, dynamic> json) => RenewalInfo(
        originalTransactionId: json['originalTransactionId'] as String,
        expirationIntent: json['expirationIntent'] as int,
        autoRenewProductId: json['autoRenewProductId'] as String,
        productId: json['productId'] as String,
        autoRenewStatus: json['autoRenewStatus'] as int,
        isInBillingRetryPeriod: json['isInBillingRetryPeriod'] as bool,
        signedDate: json['signedDate'] as int,
        environment: json['environment'] as String,
      );

  Map<String, dynamic> toMap() => {
        "originalTransactionId": originalTransactionId,
        "expirationIntent": expirationIntent,
        "autoRenewProductId": autoRenewProductId,
        "productId": productId,
        "autoRenewStatus": autoRenewStatus,
        "isInBillingRetryPeriod": isInBillingRetryPeriod,
        "signedDate": signedDate,
        "environment": environment,
      };

  @override
  String toString() => toMap().toString();
}

class ParsedJWT {
  NotificationPayload? notificationPayload;
  TransactionInfo? transactionInfo;
  RenewalInfo? renewalInfo;

  ParsedJWT({
    this.notificationPayload,
    this.transactionInfo,
    this.renewalInfo,
  });

  factory ParsedJWT.fromJson(Map<String, dynamic> json) => ParsedJWT(
        notificationPayload: json['NotificationPayload'] != null
            ? NotificationPayload.fromJson(
                json['NotificationPayload'] as Map<String, dynamic>)
            : null,
        transactionInfo: json['TransactionInfo'] != null
            ? TransactionInfo.fromJson(
                json['TransactionInfo'] as Map<String, dynamic>)
            : null,
        renewalInfo: json['RenewalInfo'] != null
            ? RenewalInfo.fromJson(json['RenewalInfo'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toMap() => {
        "notificationPayload": notificationPayload?.toMap(),
        "transactionInfo": transactionInfo?.toMap(),
        "renewalInfo": renewalInfo?.toMap(),
      };

  @override
  String toString() => toMap().toString();
}

class ApplePurchaseRecord {
  String purchaseId;
  List<ParsedJWT> records;

  ApplePurchaseRecord({
    required this.purchaseId,
    required this.records,
  });

  factory ApplePurchaseRecord.fromJson(dynamic json) {
    List<ParsedJWT> records = [];
    if (json['records'] != null) {
      for (var i in json['records']) {
        records.add(ParsedJWT.fromJson(i['payload']));
      }
    }
    return ApplePurchaseRecord(
      purchaseId: json['purchaseId'],
      records: records,
    );
  }
}
