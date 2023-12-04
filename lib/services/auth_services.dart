import 'dart:async';

import 'package:action_tds/app/models/models_index.dart';
import 'package:flutter/material.dart';

import '../app/modules/bottomNav/home/controllers/home_controller.dart';
import '/app/modules/auth/providers/user_provider.dart';
import '/database/init_get_storages.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../app/modules/auth/controllers/auth_controller.dart';
import '../app/modules/auth/user_model.dart';
import '/utils/my_logger.dart';

/// A scope that provides [StreamAuth] for the subtree.
class StreamAuthScope extends InheritedNotifier<StreamAuthNotifier> {
  /// Creates a [StreamAuthScope] sign in scope.
  StreamAuthScope({super.key, required super.child})
      : super(notifier: StreamAuthNotifier());

  /// Gets the [StreamAuth].
  static StreamAuth of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<StreamAuthScope>()!
        .notifier!
        .streamAuth;
  }
}

/// A class that converts [StreamAuth] into a [ChangeNotifier].
class StreamAuthNotifier extends ChangeNotifier {
  /// Creates a [StreamAuthNotifier].
  StreamAuthNotifier() : streamAuth = StreamAuth() {
    streamAuth.onCurrentUserChanged.listen((AppUser? user) {
      notifyListeners();
    });
  }

  /// The stream auth client.
  final StreamAuth streamAuth;
}

/// An asynchronous log in services mock with stream similar to google_sign_in.
///
/// This class adds an artificial delay of 3 second when logging in an user, and
/// will automatically clear the login session after [refreshInterval].
class StreamAuth {
  /// Creates an [StreamAuth] that clear the current user session in
  /// [refeshInterval] second.
  StreamAuth({this.refreshInterval = 20})
      : _userStreamController = StreamController<AppUser?>.broadcast() {
    _userStreamController.stream.listen((AppUser? currentUser) {
      logger.w('StreamAuth: currentUser: $currentUser');
      _currentUser = currentUser;
    });
  }

  /// The current user.
  AppUser? get currentUser => _currentUser;
  AppUser? _currentUser;

  /// Checks whether current user is signed in with an artificial delay to mimic
  /// async operation.
  Future<(bool, AppUser?)> isSignedIn() async {
    // await Future<void>.delayed(const Duration(seconds: 1));
    var userProvider = await UserProvider.instance;
    _currentUser = await userProvider.getUser();
    String? token = userProvider.getToken;
    if (currentUser != null && token != null) {
      var authcontroller = Get.put(AuthController());
      await authcontroller.setCurrentUser(currentUser);
      await userProvider.storeToken(token);
    }
    return (_currentUser != null && token != null, _currentUser);
  }

  /// A stream that notifies when current user has changed.
  Stream<AppUser?> get onCurrentUserChanged => _userStreamController.stream;
  final StreamController<AppUser?> _userStreamController;

  /// The interval that automatically signs out the user.
  final int refreshInterval;

  Timer? _timer;
  Timer _createRefreshTimer() {
    return Timer(Duration(seconds: refreshInterval), () {
      _userStreamController.add(null);
      _timer = null;
    });
  }

  /// Signs in a user with an artificial delay to mimic async operation.
  Future<void> signIn(AppUser userData, String token,
      {bool onBoarding = false, int bottomIndex = 0}) async {
    var authProvider = await UserProvider.instance;
    await authProvider.updateUser(userData.toJson());
    await authProvider.storeToken(token);
    var currentUser = await authProvider.getUser();
    await AuthService.instance.login();
    if (currentUser != null) {
      _userStreamController.add(currentUser);
      Get.put(HomeController()).persistentTabController.index = bottomIndex;
    }
    _timer?.cancel();
  }

  /// Signs out the current user.
  Future<void> signOut({bool onBoarding = false}) async {
    _timer?.cancel();
    _timer = null;
    (await UserProvider.instance)
        .removeToken()
        .then((value) async => await AuthService.instance.authBox
            .remove(AuthService.instance.isLoggedInKey)
            .then((value) => AuthService.instance._isLoggedIn = false))
        .then((value) async {
      var homeCtrl = Get.put(HomeController())
        ..persistentTabController.index = 0;
      return value;
    }).then((value) => logger.w('logout: $value'));
    await clearControllers();

    _userStreamController.add(await (await UserProvider.instance).getUser());
  }

  clearControllers() async {}
}

class AuthService {
  static const String tag = 'AuthService';
  final GetStorage authBox = GetStorage(LocalStorage.sessionBox);
  final String isLoggedInKey = 'isLoggedIn';
  AuthService._();
  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;

  /// Mocks a login process
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  bool runningLogOut = false;

  void checkLogin() async {
    UserProvider userProvider = (await UserProvider.instance);
    String val = userProvider.getToken ?? '';
    var user = val.isEmpty ? null : userProvider.getCurrentUser as AuctionUser;
    if (user != null && val.isNotEmpty) {
      await login();
      logger.i('checkLogin  token=>$val user: => ${user.toJson()}', tag: tag);
      Get.put(AuthController());
      Get.find<AuthController>().setCurrentUser(user);
      userProvider.getUser();
    }
    logger.w('checkLogin isLoggedIn: $_isLoggedIn  $isLoggedIn authbox: $val',
        tag: tag);
  }

  Future<void> login() async {
    _isLoggedIn = true;
  }

  Future<void> logout([bool fromSession = true]) async {
    if (runningLogOut) return;
    var userProvider = await UserProvider.instance;
    runningLogOut = true;
    (fromSession ? Future.value(true) : userProvider.logout())
        .then((value) async {
      if (value) {
        Future.wait(
                [userProvider.removeToken(), userProvider.removeCurrentUser()])
            .then((value) async {
          _isLoggedIn = false;
          var homeCtrl = Get.put(HomeController());
          homeCtrl.persistentTabController.jumpToTab(0);
        });
      }
    }).then((_) => logger.w('_isLoggedIn: $_isLoggedIn'));
    runningLogOut = false;
  }
}
