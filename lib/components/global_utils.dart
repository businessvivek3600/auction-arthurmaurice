import 'dart:async';

import 'package:action_tds/constants/constants_index.dart';
import 'package:action_tds/services/theme_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../utils/size_utils.dart';

///global page gradient
LinearGradient globalPageGradient() {
  return LinearGradient(
    colors: [
      Get.theme.primaryColor,
      Get.theme.secondaryHeaderColor,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

//global container
Container globalContainer({Widget? child, EdgeInsets? padding}) {
  return Container(
    padding: padding,
    // decoration: Get.theme.brightness == Brightness.dark
    //     ? BoxDecoration(gradient: globalPageGradient())
    //     : null,
    child: child,
  );
}

///global back button
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onTap,
    this.filled = false,
  });
  final FutureOr<bool> Function()? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    onPressed() async {
      bool result = true;
      if (onTap != null) {
        result = await onTap!();
      }
      if (result) {
        Navigator.pop(context);
      }
    }

    var icon = Icon(Icons.adaptive.arrow_back);
    return filled
        ? IconButton.filledTonal(
            onPressed: onPressed,
            icon: icon,
            color: Get.theme.primaryColor,
          )
        : IconButton(onPressed: onPressed, icon: icon);
  }
}

///global appbar margin
EdgeInsetsDirectional appBarTopMargin() {
  return EdgeInsetsDirectional.only(
    top: (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android)
        ? 50
        : 0,
  );
}

///font awesome icon
FaIcon faIcon(IconData icon, {Color color = Colors.white70, double size = 15}) {
  return FaIcon(icon, color: color, size: 15);
}

///money formatter
MoneyFormatter formatMoney(
  double i, {
  int fractionDigits = 3,
  String? symbol,
  thousandSeparator = ',',
  decimalSeparator = '.',
  symbolAndNumberSeparator = ' ',
  compactFormatType = CompactFormatType.short,
}) {
  symbol = symbol ?? AppConst.currencySymbol;
  return MoneyFormatter(
      amount: i,
      settings: MoneyFormatterSettings(
        symbol: symbol,
        thousandSeparator: thousandSeparator,
        decimalSeparator: decimalSeparator,
        symbolAndNumberSeparator: symbolAndNumberSeparator,
        fractionDigits: fractionDigits,
        compactFormatType: compactFormatType,
      ));
}

/// Preview image
void previewImage(Image image) =>
    showDialog(context: getContext, builder: (context) => Dialog(child: image));

///refresh effect
class DefaultRefreshEffect extends StatelessWidget {
  const DefaultRefreshEffect(
      {super.key, required this.child, required this.loading});
  final Widget child;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
        enabled: loading,
        containersColor: getTheme(context).primaryColorDark.withOpacity(0.1),
        ignorePointers: true,
        justifyMultiLineText: false,
        textBoneBorderRadius: const TextBoneBorderRadius.fromHeightFactor(.3),
        effect: ShimmerEffect(
          baseColor: getTheme(context).primaryColorDark.withOpacity(0.05),
          highlightColor: getTheme(context).primaryColorDark.withOpacity(0.08),
        ),
        child: child);
  }
}

String getAppLogo(BuildContext context, [bool invert = false]) {
  bool showWhiteLogo = false;
  String themeName = ThemeService.instance.getThemeName();
  switch (themeName) {
    case 'light':
      showWhiteLogo = false;
      break;
    case 'dark':
      showWhiteLogo = true;
      break;
    case 'website':
      showWhiteLogo = true;
      break;
    case 'darkBlue':
      showWhiteLogo = true;
      break;
    case 'halloween':
      showWhiteLogo = false;
      break;

    default:
      showWhiteLogo = true;
  }
  if (getTheme(context).brightness == Brightness.dark) {
    showWhiteLogo = true;
  }
  if (invert) {
    showWhiteLogo = !showWhiteLogo;
  }

  return showWhiteLogo ? MyPng.whiteLogo : MyPng.blackLogo;
}

///bottom sheet

// ignore: must_be_immutable
class CustomBottomsheet extends StatelessWidget {
  CustomBottomsheet({
    super.key,
    this.topMargin = kToolbarHeight,
    this.showDragLine = true,
    this.showCloseButton = true,
    this.margin,
    this.borderRadius,
    this.onClose,
    required this.builder,
  });
  final double topMargin;
  final bool showDragLine;
  final bool showCloseButton;
  final EdgeInsetsDirectional? margin;
  double? borderRadius;
  VoidCallback? onClose;
  final Widget Function(BoxConstraints bound) builder;

  @override
  Widget build(BuildContext context) {
    borderRadius = borderRadius ?? paddingDefault;
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius!),
                topRight: Radius.circular(borderRadius!)),
            child: Scaffold(
              backgroundColor: getTheme(context).scaffoldBackgroundColor,
              body: Column(
                children: [
                  if (showDragLine)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                              top: paddingDefault, bottom: paddingDefault),
                          height: 5,
                          width: paddingDefault * 4,
                          decoration: BoxDecoration(
                            color: getTheme(context).primaryColorDark,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),

                  ///child
                  Expanded(
                      child: LayoutBuilder(
                          builder: (context, constraints) =>
                              builder(constraints))),
                ],
              ),
            ),
          ),

          ///closed button on top right
          if (showCloseButton)
            Positioned(
              right: paddingDefault / 2,
              top: paddingDefault / 2,
              child: GestureDetector(
                  onTap: () {
                    Get.back();
                    if (onClose != null) onClose!();
                  },
                  child: Icon(
                    CupertinoIcons.clear_circled,
                    size: paddingDefault * 2,
                  )),
            ),
        ],
      ),
    );
  }
}

///global appbar
SystemUiOverlayStyle getTransaparentAppBarStatusBarStyle(BuildContext context) {
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: getTheme(context).brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark,
    statusBarBrightness: getTheme(context).brightness == Brightness.light
        ? Brightness.light
        : Brightness.dark,
  );
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  );
}

setStatusBarStyle(BuildContext context) {
  SystemChrome.setSystemUIOverlayStyle(
      getTransaparentAppBarStatusBarStyle(context));
}
