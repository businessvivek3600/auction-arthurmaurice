import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

import '../../home_widgets_app/services/home_widget_update_service.dart';
import '/main.dart';
import '/utils/utils_index.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../app/routes/app_pages.dart';
import 'show_notification.dart';

/// flutterLocalNotificationsPlugin instance
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

String? selectedNotificationPayload;

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

/// Initializes the notification plugin and registers notification actions
class NotificationSetup {
  static const String tag = "NotificationSetup";

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  static Future<void> initialize() async => await initNotification();

  static Future<void> initFCM([bool fromBg = false]) async {
    FirebaseMessaging.instance.getInitialMessage().then((value) {
      var tag = 'FirebaseMessaging ';
      logger.i('initFCM getInitialMessage ${fromBg ? 'from bg' : ''}: $value',
          tag: tag);
      if (value != null) selectNotificationStream.add(value.data);
    });

    ///onMessage
    FirebaseMessaging.onMessage.listen((message) {
      var tag = 'FirebaseMessaging';
      logger.i('onMessage', error: message.toMap(), tag: tag);
      ShowNotification.showNotification(message);
      HomeWidgetUpdateService.fromNotifiaction(message);
    },
        onDone: () => logger.i('onMessage done', tag: tag),
        onError: (e) => logger.e('onMessage', error: e, tag: tag));

    /// onMessageOpenedApp
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      var tag = 'FirebaseMessaging';
      logger.i('onMessageOpenedApp', error: message.toMap(), tag: tag);
      selectNotificationStream.add(message.data);
    },
        onDone: () => logger.i('onMessageOpenedApp done'),
        onError: (e) => logger.e('onMessageOpenedApp', error: e, tag: tag));
  }
}

///handle notifications
class HandleNotification {
  static void handleNotification(String? payload) {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
  }

  static void configureSelectNotificationSubject() {
    selectNotificationStream.stream
        .listen((Map<String, dynamic>? payload) async {
      logger.w('configureSelectNotificationSubject payload: $payload');
      try {
        if (payload != null) {
          if (payload['channelId'] == NotificationChannels.auction.name) {
            dynamic id = payload['auctionId'];
            goToAuctionDetail(id);
          }
        }
      } catch (e) {
        logger.e('configureSelectNotificationSubject error: $e');
      }
    });
  }

  static void configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream
        .listen((ReceivedNotification receivedNotification) async {});
  }

  static void dispose() {
    didReceiveLocalNotificationStream.close();
    selectNotificationStream.close();
  }
}

/// setup the notification plugin
Future<void> initNotification() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final List<DarwinNotificationCategory> darwinNotificationCategories =
      <DarwinNotificationCategory>[
    DarwinNotificationCategory(
      darwinNotificationCategoryText,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.text(
          'text_1',
          'Action 1',
          buttonTitle: 'Send',
          placeholder: 'Placeholder',
        ),
      ],
    ),
    DarwinNotificationCategory(
      darwinNotificationCategoryPlain,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('id_1', 'Action 1'),
        DarwinNotificationAction.plain(
          'id_2',
          'Action 2 (destructive)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
        DarwinNotificationAction.plain(
          navigationActionId,
          'Action 3 (foreground)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
        DarwinNotificationAction.plain(
          'id_4',
          'Action 4 (auth required)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.authenticationRequired,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    )
  ];

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification:
        (int id, String? title, String? body, String? payload) async {
      didReceiveLocalNotificationStream.add(
        ReceivedNotification(
            id: id, title: title, body: body, payload: payload),
      );
    },
    notificationCategories: darwinNotificationCategories,
  );

  await _configureLocalTimeZone();
  await _requestPermissions();

  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  /// update the iOS/MacOS notification badge when the app is opened
  // const MethodChannel platform =
  //     MethodChannel('dexterx.dev/flutter_local_notifications_example');
  // platform.invokeMethod<void>('updateNotificationBadgeNumber', 2);
}

Future<Map<String, dynamic>?> _getPayloadMap(dynamic payload) async {
  try {
    if (payload != null) {
      Map<String, dynamic> payloadMap = {};
      try {
        payloadMap = jsonDecode(payload);
      } catch (e) {
        payloadMap.addAll({'payloadString': payload});
      }
      return payloadMap;
    }
    return null;
  } catch (e) {
    logger.e('getPayload error: $e');
    return null;
  }
}

///request permission
Future<void> _requestPermissions() async {
  ///check request permission
  await Permission.notification
      .onDeniedCallback(() {
        logger.w('Permission.notification.onDeniedCallback');
        _permissionForNotification();
      })
      .onGrantedCallback(() {
        logger.w('Permission.notification.onGrantedCallback');
        // _permission();
      })
      .onPermanentlyDeniedCallback(() {
        logger.w('Permission.notification.onPermanentlyDeniedCallback');
        _permissionForNotification();
      })
      .onRestrictedCallback(() {
        logger.w('Permission.notification.onRestrictedCallback');
        _permissionForNotification();
      })
      .onLimitedCallback(() {
        logger.w('Permission.notification.onLimitedCallback');
        _permissionForNotification();
      })
      .onProvisionalCallback(() {
        logger.w('Permission.notification.onProvisionalCallback');
        _permissionForNotification();
      })
      .request()
      .then((value) => logger.i('Permission.notification.request: $value'));
}

void _permissionForNotification() async {
  if (Platform.isIOS || Platform.isMacOS) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  } else if (Platform.isAndroid) {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
  }
}

///configure local timezone
Future<void> _configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) return;
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

/// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<Map<String, dynamic>?> selectNotificationStream =
    StreamController<Map<String, dynamic>?>.broadcast();

const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');
const String portName = 'notification_send_port';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

///For notification actions that don't show the application/user interface, the [onDidReceiveBackgroundNotificationResponse] callback is invoked on a background isolate
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  var tag = 'notificationTapBackground';
  logger.f('notification(${notificationResponse.id}) tapped!',
      error: notificationResponse.actionId, tag: tag);
  logger.w('Notification Response',
      error: notificationResponse.payload, tag: tag);
  if (notificationResponse.input?.isNotEmpty ?? false) {
    logger.i('User provided value: ${notificationResponse.input}', tag: tag);
  }
  onDidReceiveNotificationResponse(notificationResponse);
}

/// firebaseMessagingBackgroundHandler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  var tag = 'firebaseMessagingBackgroundHandler';
  await initBeforeRun(true);
  ShowNotification.showNotification(message);
  if (message.messageId != null) {
    HomeWidgetUpdateService.fromNotifiaction(message);
  }
  logger.i('firebaseMessagingBackgroundHandler',
      error: message.toMap(), tag: tag);
}

void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) async {
  var tag = 'onDidReceiveNotificationResponse';
  logger.i(
      '${notificationResponse.id} ${notificationResponse.notificationResponseType.name}',
      error: notificationResponse.actionId,
      tag: tag);
  switch (notificationResponse.notificationResponseType) {
    case NotificationResponseType.selectedNotification:
      selectNotificationStream
          .add(await _getPayloadMap(notificationResponse.payload ?? ''));
      break;
    case NotificationResponseType.selectedNotificationAction:
      var payload = jsonDecode(notificationResponse.payload ?? '{}');
      if (notificationResponse.actionId ==
          NotificationAction.openAuction.name) {
        String? id = payload['clickActionData'];
        goToAuctionDetail(id);
        // selectNotificationStream
        //     .add(await _getPayloadMap(notificationResponse.payload ?? ''));
      }
      break;
  }
}

///Send notificaitons
class PushNotification {
  static const String tag = "PushNotification";
  static Future<void> sendPushNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    try {
      var url = 'https://fcm.googleapis.com/fcm/send';
      var serverToken =
          'AAAAzZVpM_w:APA91bE9yo7UoThDXIt6ZCcKTh4FQjdUMd8iEsIQdgtepO1mMHO3f199g3eIWd-AuPPJZD8NpjQa2ZjqCZOROA3hsYew2idYa7imtiBRTNV_HcMvCkGJt8fGt0Myvs-XqH1n_D9_yKiv';
      var token = Platform.isAndroid
          ? await FirebaseMessaging.instance.getToken()
          : 'dBovParhRs-69eHhbumKHf:APA91bEAs-2AqWH5ZACGSl-AwP_oM4f_UkQR3viwEodxZ3IDpCfDEw67oUXlODWiLbNqScN8Ir7zRBfr90_LbKMIzMdOV_kCHYTvYNUU3Xi_ii5PYnd_SG-OiJiKpr0s1Mfx43dUeCty';

      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'key=$serverToken'
      };
      Map<String, dynamic> bodyData = {
        'data': data,
        "to": token,
        "notification": {"title": title, "body": body},
        "android": {
          "ttl": "86400s",
          "notification": {"click_action": "OPEN_ACTIVITY_1"}
        },
        "apns": {
          "headers": {
            "apns-priority": "5",
          },
          "payload": {
            "aps": {"category": "NEW_MESSAGE_CATEGORY"}
          }
        },
        "webpush": {
          "headers": {"TTL": "86400"}
        }
      };
      var response = await GetConnect().post(url, bodyData, headers: headers);
      logger.i(
          'PushNotification sendPushNotification res: ${response.statusCode}  ${response.request?.headers}',
          error: response.body);
    } catch (e) {
      logger.e('PushNotification sendPushNotification error: $e');
    }
  }
}
