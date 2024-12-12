import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/utils/root.dart';

TextStyle ttTitle(
  BuildContext context, {
  Color? color,
  double? size,
  FontWeight? fontWeight,
}) {
  return TextStyle(
    fontSize: size ?? 24,
    color: color ?? AppColors.text(context),
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
    color: color ?? AppColors.text(context),
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
    color: color ?? AppColors.text(context),
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
    color: color ?? AppColors.text(context),
    fontWeight: fontWeight ?? FontWeight.w500,
  );
}

TextStyle ttBody(
  BuildContext context, {
  Color? color,
  double? size,
  FontWeight? fontWeight,
  double? height,
}) {
  return TextStyle(
    fontSize: size ?? 14,
    color: color ?? AppColors.text(context),
    fontWeight: fontWeight ?? FontWeight.w500,
    height: height,
  );
}

TextStyle ttcaption(
  BuildContext context, {
  Color? color,
  double? size,
  FontWeight? fontWeight,
}) {
  return TextStyle(
    fontSize: size ?? 14,
    fontWeight: fontWeight ?? FontWeight.w400,
    color: color ?? AppColors.text(context).withValues(alpha: 0.7),
  );
}
