import 'package:action_tds/utils/size_utils.dart';
import 'package:action_tds/utils/utils_index.dart';
import 'package:flutter/material.dart';

/// create  a overlay widget which can float on the app screen and can be used to show any widget and can be dismissed by clicking a button on the widget
class AppPopupWindow {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  static void show(
    BuildContext context, {
    required Widget child,
    double? width,
    double? height,
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
    Duration duration = const Duration(seconds: 5),
    required Function(OverlayEntry? overlayEntry) onDismissed,
  }) {
    if (_isShowing) {
      return;
    }
    _isShowing = true;
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: width ?? getWidth(context),
            height: height ?? getHeight(context),
            color: Colors.tealAccent,
            child: child,
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    onDismissed(_overlayEntry);
    Future.delayed(duration, () {
      dismiss();
    });
  }

  static void dismiss() {
    if (_isShowing) {
      _isShowing = false;
      _overlayEntry?.remove();
      _overlayEntry = null;
      logger.i('dismiss hit from AppPopupWindow');
    }
  }
}
