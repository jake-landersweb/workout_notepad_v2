import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:workout_notepad_v2/logger/events/log_event.dart';
import 'package:flutter/widgets.dart';
import 'package:workout_notepad_v2/logger/logger.dart';

class EventNaivate implements LogEvent {
  final String pageName;
  final String? source;

  const EventNaivate(this.pageName, {this.source});

  @override
  Map<String, dynamic> data() {
    var d = {"page_name": pageName};
    if (source != null) {
      d['source'] = source!;
    }
    return d;
  }

  @override
  String get eventName => "page_navigate";

  @override
  String get message => "Page navigate (${source ?? "null"}) -> ($pageName)";
}

/// A NavigatorObserver that sends log events on page changes
class NavigationLoggingObserver extends NavigatorObserver {
  final Logger _logger;
  NavigationLoggingObserver(this._logger);

  void _logNavigate(Route<dynamic>? r, Route<dynamic>? p) {
    _logger.event(EventNaivate(routeName(r), source: routeName(p)));
  }

  String routeName(Route<dynamic>? route) {
    if (route?.settings.name != null) {
      return route!.settings.name!;
    } else if (route is MaterialPageRoute) {
      return route.builder(navigator!.context).runtimeType.toString();
    } else if (route is CupertinoPageRoute) {
      return route.builder(navigator!.context).runtimeType.toString();
    } else if (route is CupertinoModalBottomSheetRoute) {
      return route.builder(navigator!.context).runtimeType.toString();
    } else if (route is ModalSheetRoute) {
      return route.builder(navigator!.context).runtimeType.toString();
    } else {
      return route?.runtimeType.toString() ?? "unknown";
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logNavigate(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logNavigate(previousRoute, route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logNavigate(newRoute, oldRoute);
  }
}
