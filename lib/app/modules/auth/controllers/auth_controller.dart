import '/app/modules/auth/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../providers/user_provider.dart';
import '/app/models/auth/login_model.dart';
import '/utils/my_logger.dart';

import '../../../models/root_models/root_user_model.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  static const tag = 'AuthController';
  static AuthController to = Get.find();

  Rx<AppUser>? currentUser;

  late Rx<PageController> pageController;
  Future<void> setCurrentUser(AppUser? user) async {
    if (user != null) {
      (await UserProvider.instance)
          .storeCurrentUser(user as AuctionUser)
          .then((_) {});
    }
    currentUser = user?.obs;
    update();
    logger.w('setCurrentUser: ${currentUser?.toJson()}');
  }

  T? getUser<T>() => currentUser?.value as T?;

  Rx<AppUser>? selectedUser;
  void setSelectedUser(AppUser? user) {
    selectedUser = user?.obs;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    print('AuthController onInit');
    refererController = TextEditingController().obs;
    nameController = TextEditingController().obs;
    usernameController = TextEditingController().obs;
    emailController = TextEditingController().obs;
    passwordController = TextEditingController().obs;
    pageController = PageController(initialPage: 0).obs;
    pageController.value.addListener(() {
      emailController.value.clear();
      passwordController.value.clear();
      nameController.value.clear();
      primaryFocus?.unfocus();
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  @override
  void dispose() {
    refererController.value.dispose();
    nameController.value.dispose();
    usernameController.value.dispose();
    emailController.value.dispose();
    passwordController.value.dispose();
    pageController.value.dispose();
    super.dispose();
  }

  late Rx<TextEditingController> refererController;
  late Rx<TextEditingController> nameController;
  late Rx<TextEditingController> usernameController;
  late Rx<TextEditingController> emailController;
  late Rx<TextEditingController> passwordController;
  RxBool loggingIn = false.obs;
  void setLoggingIn(bool value) {
    loggingIn.value = value;
    logger.w('setLoggingIn: ${loggingIn.value}', tag: tag);
    update();
  }

  Future<AppUser?> login(BuildContext context,
      {AuthFormModel? loginModel, AppUser? appUser}) async {
    /// loginModel is for login with email and password
    if (loginModel != null) {
      return (await UserProvider.instance)
          .login(context, loginModel)
          .then((value) async {
        if (value != null) {
          await setCurrentUser(value);
          return value;
        }
      }).catchError((e) {
        setLoggingIn(false);
        logger.e('login loginModel Error', tag: tag, error: e);
        Get.snackbar('login loginModel Error', e.toString());
        return null;
      });
    }

    /// appUser is for login
    else if (appUser != null) {
      await Future.delayed(const Duration(seconds: 2));
      await setCurrentUser(appUser);
      return appUser;
    }
    return null;
  }

  Future<AuctionUser?> register(
      BuildContext context, AuthFormModel registerModel) async {
    return (await UserProvider.instance)
        .register(context, registerModel)
        .then((value) async {
      if (value != null) {
        await setCurrentUser(value);
        return value;
      }
      return null;
    }).catchError((e) {
      setLoggingIn(false);
      logger.e('login loginModel Error', tag: tag, error: e);
      Get.snackbar('login loginModel Error', e.toString());
      return null;
    });
  }

  Future<dynamic> logout() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      setCurrentUser(null);
      Get.offAllNamed(Routes.auth);
      Get.snackbar('Success', 'Logout Success');
      return true;
    } catch (e) {
      return e;
    }
  }
}
