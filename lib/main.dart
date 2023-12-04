// ignore_for_file: deprecated_member_use

import 'package:action_tds/constants/constants_index.dart';
import 'package:action_tds/services/log_services.dart';

import '/services/auth_services.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:get/get.dart';

import 'home_widgets_app/services/home_widget_setup.dart';
import 'services/handleNotification/notification_services.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:get/get.dart';
import 'package:workmanager/workmanager.dart';
import '/services/theme_services.dart';
// import '/services/translation.dart';
import 'package:provider/provider.dart';

// import 'app/modules/main_binding.dart';
import 'app/routes/app_pages.dart';
import 'database/init_get_storages.dart';
import 'firebase_options.dart';
import 'home_widgets_app/entry_points.dart';
import 'services/device_preview_services.dart';
import 'utils/utils_index.dart';
import 'package:path_provider/path_provider.dart';

var initTheme = ThemeService.instance.initial;

Future<void> initBeforeRun([bool fromBg = false]) async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConst.readStringsXml();

  if (!fromBg) {
    logger.f('initBeforeRun hit fromBg: $fromBg');
    await LocalStorageBox.init();
    await DevicePreviewService.instance
        .init()
        .then((value) => AuthService.instance.checkLogin());

    await Firebase.initializeApp(
            name: '[DEFAULT]',
            options: fromBg ? null : DefaultFirebaseOptions.currentPlatform)
        .then((value) async => await FirebaseMessaging.instance
            .getToken()
            .then((value) => logger.i('deviceToken: $value')));

    await NotificationSetup.initialize();
    await Workmanager()
        .initialize(callbackDispatcher, isInDebugMode: kDebugMode);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    String storageLocation = (await getApplicationDocumentsDirectory()).path;
    await FastCachedImageConfig.init(
        subDir: storageLocation, clearCacheAfter: const Duration(days: 15));
  }
}

void main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    logger.e('FlutterError.onError: $details',
        error: details, stackTrace: details.stack);
    saveErrorLog(details);
  };
  await initBeforeRun().then((value) =>
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
          .then((_) {
        runApp(StreamAuthScope(child: app()));
      }));
}

Widget app() {
  return MyApp(initTheme: initTheme);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initTheme});
  final ThemeData initTheme;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    primaryFocus?.unfocus();
    //keyboard off
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    // TestHomeWidgetServices.instance.didChangeDependencies();
    HomeWidgetSetup.instance.init(backgroundCallback);
    HandleNotification.configureSelectNotificationSubject();
    HandleNotification.configureDidReceiveLocalNotificationSubject();
    //
  }

  @override
  void dispose() {
    HandleNotification.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    primaryFocus?.unfocus();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DevicePreviewStore>(
          create: (_) => DevicePreviewStore(
              defaultDevice: Devices.ios.iPad,
              storage: DevicePreviewStorage.preferences()),
        ),
      ],
      child: ValueListenableBuilder(
          valueListenable: devicePreviewEnabled,
          builder: (context, devicePreview, child) {
            return ThemeProvider(
                initTheme: widget.initTheme,
                builder: (_, theme) {
                  return DevicePreview(
                      enabled: devicePreview,
                      tools: const [
                        ...DevicePreview.defaultTools,
                      ],
                      builder: (context) {
                        return MaterialApp.router(
                          useInheritedMediaQuery: true,
                          builder: DevicePreview.appBuilder,
                          // initialBinding: MainBinding(),
                          // routerDelegate: goRouter.routerDelegate,

                          routerConfig: goRouter,
                          locale: Get.deviceLocale,
                          // fallbackLocale: const Locale('en', 'US'),
                          // translations: TranslationService(),
                          // unknownRoute: _unknownRoute(),
                          debugShowCheckedModeBanner: false,
                          theme: theme,
                          themeMode: ThemeMode.dark,
                        );
                      });
                });
          }),
    );
  }

  // GetPage<dynamic> _unknownRoute() {
  //   return GetPage(
  //     name: Routes.pageNotFound,
  //     page: () => const PageNotFound(),
  //     transition: Transition.fadeIn,
  //     transitionDuration: const Duration(milliseconds: 300),
  //   );
  // }
}
