import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/auth_services.dart';
import '../routes/app_pages.dart';

class EnsureAuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    log('EnsureAuthMiddleware isLoggedInValue: ${AuthService.instance.isLoggedIn}');
    if (!AuthService.instance.isLoggedIn) {
      final newRoute = Routes.loginThen(route ?? '');
      return RouteSettings(name: newRoute);
    }
    return super.redirect(route);
  }

  // @override
  // Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
  //   // you can do whatever you want here
  //   // but it's preferable to make this method fast
  //   // await Future.delayed(Duration(milliseconds: 500));
  //   log('EnsureAuthMiddleware isLoggedInValue: ${AuthService.instance.isLoggedInValue}');
  //   if (!AuthService.instance.isLoggedInValue) {
  //     final newRoute = Routes.loginThen(route.location!);
  //     return GetNavConfig.fromRoute(newRoute);
  //   }
  //   return await super.redirectDelegate(route);
  // }
}

class EnsureNotAuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    log('EnsureNotAuthMiddleware isLoggedInValue: ${AuthService.instance.isLoggedIn}');
    if (AuthService.instance.isLoggedIn) {
      return const RouteSettings(name: Routes.home);
    }
    return super.redirect(route);
  }

  // @override
  // Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
  //   log('EnsureNotAuthMiddleware isLoggedInValue: ${AuthService.instance.isLoggedInValue}');
  //   if (AuthService.instance.isLoggedInValue) {
  //     return GetNavConfig.fromRoute(Routes.home);
  //   }
  //   return await super.redirectDelegate(route);
  // }
}
