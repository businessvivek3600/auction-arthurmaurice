import 'package:action_tds/database/database_index.dart';
import 'package:flutter/foundation.dart';
import 'package:nb_utils/nb_utils.dart';

import '/database/connect/api_handler.dart';
import 'package:flutter/material.dart';

import '/app/modules/auth/user_model.dart';
import '/constants/constants_index.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../utils/utils_index.dart';
import '../../../models/models_index.dart';
import '/database/connect/base_connect.dart';

class UserProvider {
  static const tag = 'UserProvider';
  // static const String _tableName = 'session';
  var connect = Get.put(BaseConnect());
  UserProvider._();
  static UserProvider? _instance;
  static GetStorage userBox = GetStorage(LocalStorage.userBox);

  static Future<UserProvider> get instance async {
    _instance ??= UserProvider._();
    return _instance!;
  }

  //////////// auth   ////////////

  ///login
  Future<AuctionUser?> login(
      BuildContext context, AuthFormModel loginModel) async {
    try {
      var fcmToken = await getFCMToken();
      final response = await connect.post(
          ApiConst.login,
          loginModel.toJson()
            ..addAll({
              'deviceType': defaultTargetPlatform.name,
              'fcmToken': fcmToken
            }));
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = response.body;
        bool success = ApiHandler.checkApiSuccess(data);
        if (!success) return null;
        var user = AuctionUser.fromJson(data['data']['user']);
        await storeToken(data['data']['access_token']);
        await storeCurrentUser(user);
        return user;
      }
    } catch (e) {
      logger.e('login Error', tag: tag, error: e);
      errorSnack(message: e.toString(), context: context);
    }
    return null;
  }

  ///logout
  Future<bool> logout() async {
    try {
      String? token = getToken;
      if (token.isEmptyOrNull) return true;
      var res = await ApiHandler.hitApi(ApiConst.logout, method: ApiMethod.GET);
      if (res != null && res['status'] != null) {
        if (res['status'] == true) {
          successSnack(
              title: 'Success',
              message: ApiHandler.getReasonMessage(res['message']) ?? '',
              context: Get.context!);
          return true;
        } else {
          errorSnack(
              title: 'Error',
              message: ApiHandler.getReasonMessage(res['message']) ??
                  'Failed to logout',
              context: Get.context!);
        }
      }
    } catch (e) {
      logger.e('logout Error', tag: tag, error: e);
    }
    return false;
  }

  ///get user
  Future<AuctionUser?> getUser() async {
    try {
      var res =
          await ApiHandler.hitApi(ApiConst.getUser, method: ApiMethod.GET);
      logger.f('get user ${res?['user']}');
      return res != null ? AuctionUser.fromJson(res['user']) : null;
    } catch (e) {
      logger.e('get User Error', tag: tag, error: e);
    }
    return null;
  }

  ///update user
  Future<(AuctionUser?, String msg)> updateUser(
      Map<String, dynamic> data) async {
    try {
      var res = await ApiHandler.hitApi(ApiConst.updateProfile,
          method: ApiMethod.POST, body: data);
      if (res != null && res['status'] != null) {
        if (res['status'] == true) {
          var message = ApiHandler.getReasonMessage(res['message']) ?? '';
          return await getUser().then((value) => (value, message));
        } else {
          errorSnack(
              title: 'Error',
              message: ApiHandler.getReasonMessage(res['message']) ??
                  'Failed to update profile',
              context: Get.context!,
              backgroundColor: const Color.fromARGB(255, 255, 0, 0));
        }
      }
      logger.f('updateUser ${res?['user']}');
    } catch (e) {
      logger.e('get User Error', tag: tag, error: e);
    }
    return (null, '');
  }

  ///update password
  Future<bool> updatePassword(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      var res = await ApiHandler.hitApi(ApiConst.updatePassword,
          method: ApiMethod.POST, body: data);
      if (res != null && res['status'] != null) {
        if (res['status'] == true) {
          successSnack(
              title: 'Success',
              message: ApiHandler.getReasonMessage(res['message']) ?? '',
              context: context,
              backgroundColor: const Color.fromRGBO(76, 175, 80, 1));
          return true;
        } else {
          errorSnack(
              title: 'Error',
              message: ApiHandler.getReasonMessage(res['message']) ??
                  'Failed to update password',
              context: context,
              backgroundColor: const Color.fromARGB(255, 255, 0, 0));
        }
      }
      logger.f('updatePassword ${res?['user']}');
    } catch (e) {
      logger.e('get User Error', tag: tag, error: e);
    }
    return false;
  }

  /// update profile image
  Future<AuctionUser?> updateProfileImage(Map<String, dynamic> data) async {
    try {
      var res = await ApiHandler.hitApi(ApiConst.updateProfileImage,
          method: ApiMethod.POST, body: data, isFormData: true);
      if (res != null && res['status'] != null) {
        if (res['status'] == true) {
          successSnack(
              title: 'Success',
              message: ApiHandler.getReasonMessage(res['message']) ?? '',
              context: Get.context!,
              backgroundColor: const Color.fromRGBO(76, 175, 80, 1));
          return await getUser().then((value) => value);
        } else {
          errorSnack(
              title: 'Error',
              message: ApiHandler.getReasonMessage(res['message']) ??
                  'Failed to update profile image',
              context: Get.context!,
              backgroundColor: const Color.fromARGB(255, 255, 0, 0));
        }
      }
      logger.f('updateProfileImage ${res?['user']}');
    } catch (e) {
      logger.e('updateProfileImage Error', tag: tag, error: e);
    }
    return null;
  }

  ///register
  Future<AuctionUser?> register(
      BuildContext context, AuthFormModel loginModel) async {
    try {
      var fcmToken = await getFCMToken();
      final response = await connect.post(
          ApiConst.register,
          loginModel.toJson()
            ..addAll({
              'deviceType': defaultTargetPlatform.name,
              'fcmToken': fcmToken
            }));
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = response.body;
        bool success = ApiHandler.checkApiSuccess(data);
        if (!success) return null;
        var user = AuctionUser.fromJson(data['data']['user']);
        await storeToken(data['data']['access_token']);
        await storeCurrentUser(user);
        return user;
      }
    } catch (e) {
      logger.e('login Error', tag: tag, error: e);
      errorSnack(message: e.toString(), context: context);
    }
    return null;
  }

  //////////   user from local storage    //////////

  /// store current user in local storage
  Future<void> storeCurrentUser(AppUser user) async {
    await userBox.write('currentUser', user.toJson());
  }

  /// get current user from local storage
  AppUser? get getCurrentUser {
    final data = userBox.read('currentUser');
    return data != null ? AuctionUser.fromJson(data) : null;
  }

  /// remove current user from local storage
  Future<void> removeCurrentUser() async {
    await userBox.remove('currentUser');
  }

  /// store token in local storage
  Future<void> storeToken(String token) async {
    logger.w('storeToken: $token', tag: tag);
    await userBox.write('token', token);
  }

  /// get token from local storage
  String? get getToken {
    return userBox.read<String?>('token');
  }

  ///remove token from local storage
  Future<void> removeToken() async {
    await userBox.remove('token');
  }

  Future<bool> sendEmailVerification() async {
    try {
      var res = await ApiHandler.hitApi(ApiConst.sendEmailVerification,
          method: ApiMethod.GET);
      if (res != null && res['status'] != null) {
        if (res['status'] == true) {
          successSnack(
              title: 'Success',
              message: ApiHandler.getReasonMessage(res['message']) ?? '',
              context: Get.context!,
              backgroundColor: const Color.fromRGBO(76, 175, 80, 1));
          return true;
        } else {
          warningSnack(
              title: 'Error',
              message: ApiHandler.getReasonMessage(res['message']) ??
                  'Failed to send email verification',
              context: Get.context!);
        }
      }
    } catch (e) {
      logger.e('sendEmailVerification Error', tag: tag, error: e);
    }
    return false;
  }

  ///verifyEmailOTP
  Future<bool> verifyEmailOTP(String otp) async {
    try {
      var res = await ApiHandler.hitApi(ApiConst.verifyEmail,
          method: ApiMethod.POST, body: {'email_verified_code': otp});
      if (res != null && res['status'] != null) {
        if (res['status'] == true) {
          successSnack(
              title: 'Success',
              message: ApiHandler.getReasonMessage(res['message']) ?? '',
              context: Get.context!,
              backgroundColor: const Color.fromRGBO(76, 175, 80, 1));
          return await getUser().then((value) => true);
        } else {
          warningSnack(
              title: 'Error',
              message: ApiHandler.getReasonMessage(res['message']) ??
                  'Failed to verify email',
              context: Get.context!);
        }
      }
    } catch (e) {
      logger.e('verifyEmailOTP Error', tag: tag, error: e);
    }
    return false;
  }

  ///forgotPassword
  Future<bool> forgotPassword(String email) async {
    try {
      var res = await ApiHandler.hitApi(ApiConst.forgotPassword,
          method: ApiMethod.POST, body: {'value': email, 'type': 'email'});
      if (res != null && res['status'] != null) {
        if (res['status'] == true) {
          successSnack(
              title: 'Success',
              message: ApiHandler.getReasonMessage(res['message']) ?? '',
              context: Get.context!,
              backgroundColor: const Color.fromRGBO(76, 175, 80, 1));
          return true;
        } else {
          warningSnack(
              title: 'Error',
              message: ApiHandler.getReasonMessage(res['message']) ??
                  'Failed to send email verification',
              context: Get.context!);
        }
      }
    } catch (e) {
      logger.e('forgotPassword Error', tag: tag, error: e);
    }
    return false;
  }

  ///forgotPasswordSubmit
  Future<bool> forgotPasswordSubmit(Map<String, dynamic> data) async {
    try {
      var res = await ApiHandler.hitApi(ApiConst.forgotPasswordSubmit,
          method: ApiMethod.POST, body: data);
      if (res != null && res['status'] != null) {
        if (res['status'] == true) {
          successSnack(
              title: 'Success',
              message: ApiHandler.getReasonMessage(res['message']) ?? '',
              context: Get.context!,
              backgroundColor: const Color.fromRGBO(76, 175, 80, 1));
          return true;
        } else {
          warningSnack(
              title: 'Error',
              message: ApiHandler.getReasonMessage(res['message']) ??
                  'Failed to send email verification',
              context: Get.context!);
        }
      }
    } catch (e) {
      logger.e('forgotPasswordSubmit Error', tag: tag, error: e);
    }
    return false;
  }
}
