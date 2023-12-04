import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'utils_index.dart';

void errorSnack({
  String title = 'Error',
  required String message,
  required BuildContext context,
  SnackPosition position = SnackPosition.TOP,
  Color? backgroundColor,
  Color? colorText,
  EdgeInsets? margin,
  double? borderRadius,
  Duration? duration,
  Icon? icon,
}) =>
    Get.snackbar(title, message,
        titleText: capText(title, context, color: Colors.white),
        messageText: capText(message, context, color: Colors.white),
        snackPosition: position,
        backgroundColor: backgroundColor ?? Colors.red,
        colorText: colorText ?? Colors.white,
        margin:
            margin ?? const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        borderRadius: borderRadius ?? 10,
        duration: duration ?? const Duration(seconds: 3),
        icon: icon ?? const Icon(Icons.error_outline, color: Colors.white));

void successSnack({
  String title = 'Success',
  required String message,
  required BuildContext context,
  SnackPosition position = SnackPosition.TOP,
  Color? backgroundColor,
  Color? colorText,
  EdgeInsets? margin,
  double? borderRadius,
  Duration? duration,
  Icon? icon,
}) =>
    Get.snackbar(title, message,
        titleText: capText(title, context, color: Colors.white),
        messageText: capText(message, context, color: Colors.white),
        snackPosition: position,
        backgroundColor: backgroundColor ?? Colors.green,
        colorText: colorText ?? Colors.white,
        margin: margin ?? const EdgeInsets.all(10),
        borderRadius: borderRadius ?? 10,
        duration: duration ?? const Duration(seconds: 3),
        icon: icon ??
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
            ));

void infoSnack({
  String title = 'Info',
  required String message,
  required BuildContext context,
  SnackPosition position = SnackPosition.TOP,
  Color? backgroundColor,
  Color? colorText,
  EdgeInsets? margin,
  double? borderRadius,
  Duration? duration,
  Icon? icon,
}) =>
    Get.snackbar(title, message,
        titleText: capText(title, context, color: Colors.white),
        messageText: capText(message, context, color: Colors.white),
        snackPosition: position,
        backgroundColor: backgroundColor ?? Colors.blue,
        colorText: colorText ?? Colors.white,
        margin: margin ?? const EdgeInsets.all(10),
        borderRadius: borderRadius ?? 10,
        duration: duration ?? const Duration(seconds: 3),
        icon: icon ??
            const Icon(
              Icons.info_outline,
              color: Colors.white,
            ));

void warningSnack({
  String title = 'Warning',
  required String message,
  required BuildContext context,
  SnackPosition position = SnackPosition.TOP,
  Color? backgroundColor,
  Color? colorText,
  EdgeInsets? margin,
  double? borderRadius,
  Duration? duration,
  Icon? icon,
}) =>
    Get.snackbar(title, message,
        titleText: capText(title, context, color: Colors.white),
        messageText: capText(message, context, color: Colors.white),
        snackPosition: position,
        backgroundColor:
            backgroundColor ?? const Color.fromARGB(255, 195, 176, 2),
        colorText: colorText ?? Colors.white,
        margin: margin ?? const EdgeInsets.all(10),
        borderRadius: borderRadius ?? 10,
        duration: duration ?? const Duration(seconds: 3),
        icon: icon ??
            const Icon(Icons.warning_amber_outlined, color: Colors.white));
