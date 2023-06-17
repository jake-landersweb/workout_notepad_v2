import 'package:flutter/material.dart';

TextStyle ttTitle(
  BuildContext context, {
  Color? color,
  double? size,
  FontWeight? fontWeight,
}) {
  return TextStyle(
    fontSize: size ?? 24,
    color: color,
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
    color: color,
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
    color: color,
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
    color: color,
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
    color: color,
    fontWeight: fontWeight ?? FontWeight.w500,
  );
}
