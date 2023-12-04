import 'package:flutter/material.dart';

class HeroWidget extends StatelessWidget {
  const HeroWidget({super.key, required this.tag, required this.child});
  final String tag;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: child,
    );
  }
}

class HeroTag {
  static String fromImage(String image) => 'imageHeroTag_$image';
  static String fromText(String text) => 'textHeroTag_$text';
  static String fromWidget(String widget) => 'widgetHeroTag_$widget';
}
