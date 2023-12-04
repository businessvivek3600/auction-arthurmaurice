import 'package:flutter/material.dart';
import '/utils/text.dart';

import '../utils/size_utils.dart';

enum ToastType { success, failed, warning, info }

class MyToastModel {
  Widget? child;
  String? message;
  ToastType type;

  MyToastModel(this.message, this.type, {this.child});
}

class ToastItem extends StatefulWidget {
  const ToastItem({
    Key? key,
    this.onTap,
    required this.animation,
    required this.item,
  }) : super(key: key);

  final Animation<double> animation;
  final VoidCallback? onTap;
  final MyToastModel item;

  @override
  State<ToastItem> createState() => _ToastItemState();
}

class _ToastItemState extends State<ToastItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle =
        Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.all(spaceDefault),
          child: FadeTransition(
            opacity: widget.animation,
            child: SizeTransition(
              sizeFactor: widget.animation,
              child: widget.item.child ??
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: _getTypeColor(widget.item.type),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12.0))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.item.message != null)
                          capText(widget.item.message!, context,
                              style: textStyle),
                        if (widget.item.child != null) widget.item.child!,
                        // width10(),
                        // IconButton(
                        //     icon:
                        //         const Icon(Icons.close, color: Colors.white, size: 10),
                        //     onPressed: () => widget.onTap?.call()),
                      ],
                    ),
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const Color(0xFF3DD89B);
      case ToastType.warning:
        return const Color(0xFFFFD873);
      case ToastType.info:
        return const Color(0xFF17A2b8);
      case ToastType.failed:
        return const Color(0xFFFF4E43);
      default:
        return const Color(0xFF3DD89B);
    }
  }
}
