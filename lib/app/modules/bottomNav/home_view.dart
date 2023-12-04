import 'package:action_tds/app/modules/bottomNav/home/controllers/home_controller.dart';
import 'package:action_tds/database/functions.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import 'home_bottom_nav_bar.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  var controller = Get.put(HomeController());
  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      checkForUpdate(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return ThemeSwitchingArea(
    //     child:
    return DoublePressBackWidget(
      onWillPop: () async {
        if (controller.persistentTabController.index != 0) {
          controller.persistentTabController.jumpToTab(0);
          return false;
        } else {
          return true;
        }
      },
      child: ProvidedStylesExample(
        menuScreenContext: context,
        // drawer: HomeDrawer(),
        // )
      ),
    );
  }
}
