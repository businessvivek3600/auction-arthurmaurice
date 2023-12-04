import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '/utils/my_logger.dart';
import '../../../../utils/size_utils.dart';

import '/components/component_index.dart';
import '../../../../utils/color.dart';
import '../../../../utils/text.dart';
import '../../../routes/app_pages.dart';
import 'auth_view.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    logger.i('OnboardingView ${getTheme().brightness}');
    return Scaffold(
        body: Stack(
      children: [
        Container(decoration: BoxDecoration(gradient: globalPageGradient())),

        ///top left clipper
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipShadowPath(
            clipper: const MyClipper1(),
            shadow: const Shadow(blurRadius: 10, color: Colors.white24),
            child: Container(
              height: Get.height * 0.3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    kPrimaryColor5,
                    kPrimaryColor6,
                  ].reversed.toList(),
                ),
              ),
            ),
          ),
        ),

        /// Image and text
        Positioned(
          top: 0,
          bottom: getHeight(context) * 0.2,
          left: getWidth() * 0.05,
          right: getWidth() * 0.05,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              height100(kToolbarHeight),
              Expanded(
                child: Container(
                  // color: Colors.teal,
                  padding: EdgeInsets.all(spaceDefault),
                  child: Center(
                    child: Image.asset(
                      'assets/images/onBoarding_1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              height20(),
              displayLarge("THE LUXURY WATCH GUIDE", context,
                  fontSize: 32, color: Colors.white),
              height5(),
              bodyLargeText("Timepieces of Greatness", context,
                  color: Colors.white54),
            ],
          ),
        ),

        // Get started button
        Positioned(
          bottom: getHeight(context) * 0.05,
          left: getWidth() * 0.05,
          child: Stack(
            children: [
              Container(
                width: getHeight(context) * 0.08,
                height: getHeight(context) * 0.08,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        getTheme().primaryColor,
                        // getTheme().primaryColor.withOpacity(0.9),
                        Colors.black,
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            getTheme().colorScheme.background.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(-5, 5),
                      ),
                    ]),
              ),
              // Get started button
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      // Get.offAllNamed(Routes.auth);
                      context.go(Routes.auth);
                    },
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
