import 'package:action_tds/lib_pip/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'drag/drag_custom.dart' as dc;
import 'overlay_handler.dart';

class VideoTitleOverlayWidget extends StatefulWidget {
  final Function onClear;
  final Widget widget;

  VideoTitleOverlayWidget({required this.onClear, required this.widget})
      : assert(widget != null);

  @override
  _VideoTitleOverlayWidgetState createState() =>
      _VideoTitleOverlayWidgetState();
}

class _VideoTitleOverlayWidgetState extends State<VideoTitleOverlayWidget> {
  double width = 0;
  double oldWidth = 0;
  double oldHeight = 0;
  double height = 0;

  bool isInPipMode = false;

  Offset offset = const Offset(0, 0);

  Widget? player;

  _onExitPipMode() {
    Future.microtask(() {
      setState(() {
        isInPipMode = false;
        width = oldWidth;
        height = oldHeight;
        offset = const Offset(0, 0);
      });
    });
    Future.delayed(const Duration(milliseconds: 250), () {
      Provider.of<OverlayHandlerProvider>(context, listen: false).disablePip();
    });
  }

  _onPipMode() {
    double aspectRatio =
        Provider.of<OverlayHandlerProvider>(context, listen: false).aspectRatio;

    print("true   $aspectRatio");
//    Provider.of<OverlayHandlerProvider>(context, listen: false).enablePip();
    Future.delayed(const Duration(milliseconds: 100), () {
      print("true   Future.microtask");

      setState(() {
        isInPipMode = true;
        width = oldWidth - 32.0;
        height = Constants.VIDEO_TITLE_HEIGHT_PIP;
        print(oldHeight - height - Constants.BOTTOM_PADDING_PIP);
        offset = Offset(16, oldHeight - height - Constants.BOTTOM_PADDING_PIP);
//        height = (Constants.VIDEO_HEIGHT_PIP/aspectRatio) + 33;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (width == null || height == null) {
      oldWidth = width = MediaQuery.of(context).size.width;
      oldHeight = height = MediaQuery.of(context).size.height;
    }
    return Consumer<OverlayHandlerProvider>(
        builder: (context, overlayProvider, _) {
      print("video_overlay_widget ${overlayProvider.inPipMode}");
      if (overlayProvider.inPipMode != isInPipMode) {
        isInPipMode = overlayProvider.inPipMode;
        if (isInPipMode)
          _onPipMode();
        else
          _onExitPipMode();
      }
      print(height);
      return AnimatedPositioned(
        duration: const Duration(milliseconds: 150),
        left: offset.dx,
        top: offset.dy,
        child: Material(
          elevation: isInPipMode ? 5.0 : 0.0,
          child: AnimatedContainer(
            height: height,
            width: width,
            child: widget.widget,
            duration: const Duration(milliseconds: 250),
          ),
        ),
      );
    });
  }
}
