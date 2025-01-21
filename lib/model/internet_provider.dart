import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:workout_notepad_v2/logger.dart';

class InternetProvider extends ChangeNotifier {
  InternetProvider() {
    init();
  }

  late StreamSubscription<List<ConnectivityResult>> _subscription;
  List<ConnectivityResult>? _result;

  void init() {
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      _result = result;
      notifyListeners();

      // print out the type
      var type = this.type();
      logger.debug(
        "internet status has changed",
        {"type": type?.name ?? "null"},
      );
    });
  }

  bool hasInternet() {
    if (_result == null) return false;

    return !_result!.contains(ConnectivityResult.none);
  }

  ConnectivityResult? type() {
    if (_result == null) return null;

    if (_result!.contains(ConnectivityResult.mobile)) {
      // Mobile network available.
      return ConnectivityResult.mobile;
    } else if (_result!.contains(ConnectivityResult.wifi)) {
      // Wi-fi is available.
      // Note for Android:
      // When both mobile and Wi-Fi are turned on system will return Wi-Fi only as active network type
      return ConnectivityResult.wifi;
    } else if (_result!.contains(ConnectivityResult.ethernet)) {
      // Ethernet connection available.
      return ConnectivityResult.ethernet;
    } else if (_result!.contains(ConnectivityResult.vpn)) {
      // Vpn connection active.
      // Note for iOS and macOS:
      // There is no separate network interface type for [vpn].
      // It returns [other] on any device (also simulator)
      return ConnectivityResult.vpn;
    } else if (_result!.contains(ConnectivityResult.bluetooth)) {
      // Bluetooth connection available.
      return ConnectivityResult.bluetooth;
    } else if (_result!.contains(ConnectivityResult.other)) {
      // Connected to a network which is not in the above mentioned networks.
      return ConnectivityResult.other;
    } else if (_result!.contains(ConnectivityResult.none)) {
      // No available network types
      return ConnectivityResult.none;
    }
    return null;
  }

  @override
  dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
