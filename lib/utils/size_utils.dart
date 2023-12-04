import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget heightDefault([double? height]) => SizedBox(height: spaceDefault);
Widget height5([double? height]) => SizedBox(height: height ?? 5);
Widget height10([double? height]) => SizedBox(height: height ?? 10);
Widget height20([double? height]) => SizedBox(height: height ?? 20);
Widget height30([double? height]) => SizedBox(height: height ?? 30);
Widget height40([double? height]) => SizedBox(height: height ?? 40);
Widget height50([double? height]) => SizedBox(height: height ?? 50);
Widget height100([double? height]) => SizedBox(height: height ?? 100);

Widget widthDefault([double? width]) => SizedBox(width: spaceDefault);
Widget width5([double? width]) => SizedBox(width: width ?? 5);
Widget width10([double? width]) => SizedBox(width: width ?? 10);
Widget width20([double? width]) => SizedBox(width: width ?? 20);
Widget width30([double? width]) => SizedBox(width: width ?? 30);
Widget width40([double? width]) => SizedBox(width: width ?? 40);
Widget width50([double? width]) => SizedBox(width: width ?? 50);
Widget width100([double? width]) => SizedBox(width: width ?? 100);

Size getSize(BuildContext context) => MediaQuery.of(context).size;
double getWidth([BuildContext? context]) =>
    MediaQuery.of(Get.context!).size.width;
double getHeight([BuildContext? context]) =>
    MediaQuery.of(context ?? Get.context!).size.height;
BuildContext get getContext => Get.context!;
ThemeData getTheme([BuildContext? context]) =>
    Theme.of(context ?? Get.context!);

Widget space(double p) =>
    SizedBox(height: MediaQuery.of(Get.context!).size.height * p / 100);
double perSize(double p) => MediaQuery.of(Get.context!).size.height * p / 100;

double paddingDefault = Get.width * 0.03;
double spaceDefault = Get.width * 0.03;
