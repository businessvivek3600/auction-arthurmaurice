import 'package:flutter/material.dart';

import 'dart:math';

class NeonContainer extends StatefulWidget {
  const NeonContainer({
    super.key,
    this.width,
    this.height,
    this.blurRadius,
    this.borderRadius,
    this.shadowOpacity,
    this.gradientColorOne,
    this.gradientColorTwo,
    this.shadowColor,
    this.boxColor,
    this.borderColor,
  });
  final Color? gradientColorOne;
  final Color? gradientColorTwo;
  final Color? shadowColor;
  final Color? boxColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final double? blurRadius;
  final double? borderRadius;
  final double? shadowOpacity;

  @override
  State<NeonContainer> createState() => _NeonContainerState();
}

class _NeonContainerState extends State<NeonContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));

    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);
    _controller.repeat();

    _controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius!)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.boxColor!, //Color(0xE3090909),
              boxShadow: [
                BoxShadow(
                  color: widget.shadowColor!.withOpacity(widget
                      .shadowOpacity!), //Color(0xFF000000).withOpacity(0.2),
                  blurRadius: widget.blurRadius!,
                  offset: const Offset(15, 15),
                )
              ],
            ),
          ),
          Positioned(
            top: widget.height! / 2,
            left: widget.width! / 2,
            child: Transform.rotate(
              angle: _animation.value,
              alignment: Alignment.topLeft,
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.gradientColorOne!,
                      widget.gradientColorTwo!,
                      // Color(0x00000000),
                      // Color.fromARGB(255, 255, 255, 255),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: widget.height! / 2,
            right: widget.width! / 2,
            child: Transform.rotate(
              angle: _animation.value,
              alignment: Alignment.bottomRight,
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      // Color.fromARGB(255, 255, 255, 255),
                      // Color(0x00000000),
                      widget.gradientColorTwo!,
                      widget.gradientColorOne!
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            width: widget.width! - 10,
            height: widget.height! - 10,
            decoration: BoxDecoration(
              color: widget.borderColor, //Color(0x871D1D1D),
              borderRadius: BorderRadius.all(
                Radius.circular(widget.borderRadius!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
