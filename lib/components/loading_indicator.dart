import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Creates a [LoadingIndicator] based on the platform the user
/// is currently on. If on [iOS] or [macOS], the resulting
/// widget will be a [CupertinoActivityIndicator]. If not,
/// then the widget will be a [CircularProgressIndicator] that
/// can be modifided with the [color] field.
class LoadingIndicator extends StatelessWidget {
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Center(
        child: CircularProgressIndicator(
            color: color ?? Theme.of(context).colorScheme.primary),
      );
    } else {
      if (Platform.isIOS) {
        return Center(
            child: CupertinoActivityIndicator(
                color: color == Colors.white ? Colors.white : null));
      } else {
        return Center(
          child: CircularProgressIndicator(
              color: color ?? Theme.of(context).colorScheme.primary),
        );
      }
    }
  }
}
