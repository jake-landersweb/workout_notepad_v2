import 'package:flutter/material.dart';
import 'package:sapphireui/sapphireui.dart' as sui;

TextStyle ttTitle(
  BuildContext context, {
  Color? color,
  double? size,
  FontWeight? fontWeight,
}) {
  return TextStyle(
    fontSize: size ?? 24,
    color: color ?? Theme.of(context).colorScheme.onBackground,
    fontWeight: fontWeight ?? FontWeight.w600,
  );
}

TextStyle ttSubTitle(
  BuildContext context, {
  Color? color,
  double? size,
  FontWeight? fontWeight,
}) {
  return TextStyle(
    fontSize: size ?? 22,
    color: color ?? Theme.of(context).colorScheme.onBackground,
    fontWeight: fontWeight ?? FontWeight.w500,
  );
}

TextStyle ttLargeLabel(
  BuildContext context, {
  Color? color,
  double? size,
  FontWeight? fontWeight,
}) {
  return TextStyle(
    fontSize: size ?? 20,
    color: color ?? Theme.of(context).colorScheme.onBackground,
    fontWeight: fontWeight ?? FontWeight.w600,
  );
}

TextStyle ttLabel(
  BuildContext context, {
  Color? color,
  double? size,
  FontWeight? fontWeight,
}) {
  return TextStyle(
    fontSize: size ?? 18,
    color: color ?? Theme.of(context).colorScheme.onBackground,
    fontWeight: fontWeight ?? FontWeight.w500,
  );
}

TextStyle ttBody(
  BuildContext context, {
  Color? color,
  double? size,
  FontWeight? fontWeight,
}) {
  return TextStyle(
    fontSize: size ?? 16,
    color: color ?? Theme.of(context).colorScheme.onBackground,
    fontWeight: fontWeight ?? FontWeight.w500,
  );
}
