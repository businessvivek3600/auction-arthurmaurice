import 'dart:developer';

import '/constants/asset_constants.dart';
import '../../../../../services/handleNotification/notification_services.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../home_widgets_app/services/home_widget_setup.dart';

import '../../../../../generated/locales.g.dart';
import '../../../../../services/auth_services.dart';
import '../../../../../services/device_preview_services.dart';
import '../../../../../services/theme_services.dart';
import '../../../../../services/translation.dart';
import '../../../../routes/app_pages.dart';

class HomeDrawer extends StatefulWidget {
  HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  GlobalKey captureKey = GlobalKey();
  Image? image;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    HomeWidgetSetup.instance.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    print('HomeDrawer: build $captureKey');
    return Drawer(
      child: RepaintBoundary(
        key: captureKey,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue, Colors.blueAccent],
                ),
                image:
                    image != null ? DecorationImage(image: image!.image) : null,
              ),
              child: const Center(
                child: Text('Drawer Header',
                    style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
            ),
            const EnableDevicePreview(),

            ///send data to widget
            CaptureScreenShot(
                captureKey: captureKey,
                onCapture: (img) {
                  setState(() => image = img);
                  HomeWidgetSetup.instance.sendAndUpdate(
                    title: 'Updated from Background',
                    message: 'Updated from Background',
                    logicalSize: Size(Get.width * 3, Get.height * 2),
                    renderWidget: Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image:
                              AssetImage('assets/images/${MyPng.onBoarding1}'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // Container(
                    //   padding: const EdgeInsets.all(30),
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(30),
                    //     color: kPrimaryColor5,
                    //   ),
                    //   child: Builder(builder: (context) {
                    //     double lSize = 50;
                    //     double mSize = 30;
                    //     double sSize = 20;
                    //     return Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       children: [
                    //         titleLargeText('Running Bids',
                    //             color: Colors.white, fontSize: lSize),
                    //         const Divider(color: Colors.white70),

                    //         ///bids count
                    //         Row(
                    //           children: [
                    //             Expanded(
                    //               child: Column(
                    //                 crossAxisAlignment:
                    //                     CrossAxisAlignment.start,
                    //                 children: [
                    //                   bodyLargeText('Bids',
                    //                       color: Colors.white, fontSize: mSize),
                    //                   bodyLargeText('0',
                    //                       color: Colors.white, fontSize: mSize),
                    //                 ],
                    //               ),
                    //             ),
                    //             Expanded(
                    //               child: Column(
                    //                 crossAxisAlignment:
                    //                     CrossAxisAlignment.start,
                    //                 children: [
                    //                   bodyLargeText('Running',
                    //                       color: Colors.white, fontSize: mSize),
                    //                   bodyLargeText('0',
                    //                       color: Colors.white, fontSize: mSize),
                    //                 ],
                    //               ),
                    //             ),
                    //             Expanded(
                    //               child: Column(
                    //                 crossAxisAlignment:
                    //                     CrossAxisAlignment.start,
                    //                 children: [
                    //                   bodyLargeText('Completed',
                    //                       color: Colors.white, fontSize: mSize),
                    //                   bodyLargeText('0',
                    //                       color: Colors.white, fontSize: mSize),
                    //                 ],
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //         if (image != null)
                    //           SizedBox.fromSize(
                    //               size: Size(Get.width, Get.height),
                    //               child:
                    //                   LayoutBuilder(builder: (context, bound) {
                    //                 return assetImages(
                    //                   'onBoarding_1.png',
                    //                   width: bound.maxWidth,
                    //                   height: bound.maxHeight,
                    //                 );
                    //               })),

                    //         ///
                    //         ///
                    //       ],
                    //     );
                    //   }),
                    // ),
                  );
                }),

            ///send push notification
            ListTile(
              title: const Text('Send Push Notification'),
              onTap: () {
                PushNotification.sendPushNotification(
                    'Notification from Firebase',
                    'Body message from firebase', {
                  'name': 'waseem',
                  'age': 20,
                  'address': 'india',
                  'image':
                      'https://waseemdev.gallerycdn.vsassets.io/extensions/waseemdev/flutter-xml-layout/0.0.34/1644478592265/Microsoft.VisualStudio.Services.Icons.Default',
                });
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              onTap: () => Get.toNamed(Routes.account),
              title: const Text('Profile'),
            ),
            ListTile(
              // onTap: () => showAccountsSheet(),
              title: const Text('Switch account'),
            ),

            ///change theme
            ThemeSwitcher(
                clipper: const ThemeSwitcherCircleClipper(),
                builder: (context) {
                  return ListTile(
                    onTap: () {
                      try {
                        ThemeService.instance.changeThemeMode2(context, 'pink');
                      } catch (e) {
                        log('error: $e');
                      }
                    },
                    title: const Text('Change theme'),
                    trailing: const Icon(Icons.brightness_6_rounded),
                  );
                }),

            ///change language
            ListTile(
              onTap: () {
                _changeLocaleSheet();
              },
              title: const Text('Change language'),
              trailing: const Icon(Icons.language),
            ),

            ///logout
            ListTile(
              onTap: () async {
                AuthService.instance.logout().then((value) {
                  Navigator.pop(context);
                  // context.go(Routes.product);
                });
              },
              title: const Text('Logout'),
              trailing: const Icon(Icons.logout),
            ),
            Wrap(
              children: [
                /// icon buttons for diff- diff tyopes of notification
                IconButton(
                    onPressed: () {
                      // ShowNotification.showNotificationWithActions(
                      // 'testing', 'testing body', 'testing subtitle');
                    },
                    icon: const Icon(Icons.food_bank)),
                IconButton(
                    onPressed: () {
                      // ShowNotification.showNotificationWithIconAction(
                      // 'testing', 'testing body', 'testing subtitle');
                    },
                    icon: const Icon(Icons.no_accounts)),
                IconButton(
                    onPressed: () {
                      // ShowNotification.showNotificationWithNoSound();
                    },
                    icon: const Icon(Icons.no_accounts)),

                IconButton(
                    onPressed: () {
                      // ShowNotification.showNotificationWithTextChoice(
                      // 'testing', 'testing body', 'testing subtitle');
                    },
                    icon: const Icon(Icons.no_accounts)),
                IconButton(
                    onPressed: () {
                      // ShowNotification.showTimeoutNotification();
                    },
                    icon: const Icon(Icons.no_accounts)),
                IconButton(
                    onPressed: () {
                      // ShowNotification.showFullScreenNotification();
                    },
                    icon: const Icon(Icons.no_accounts)),

                /// repeat notification
                IconButton(
                    onPressed: () {
                      // ShowNotification.repeastNotification();
                    },
                    icon: const Icon(Icons.no_accounts)),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _changeLocaleSheet() {
    Get.bottomSheet(
      Container(
        color: Colors.grey,
        child: Wrap(
          children: [
            ...AppTranslation.translations.keys
                .map(
                  (e) => ListTile(
                    title: Text(e),
                    onTap: () {
                      TranslationService.changeLocale(e);
                      Navigator.pop(context);
                    },
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }
}
