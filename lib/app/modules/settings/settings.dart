import 'dart:io';

import 'package:action_tds/services/auth_services.dart';
import 'package:action_tds/utils/utils_index.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../components/component_index.dart';
import '../../../generated/locales.g.dart';
import '../../../services/device_preview_services.dart';
import '../../../services/share.dart';
import '../../../services/theme_services.dart';
import '../../../services/translation.dart';
import '../../routes/app_pages.dart';
import '../auth/controllers/auth_controller.dart';
import '../auth/user_model.dart';

class UserProfileSetting extends StatelessWidget {
  UserProfileSetting({super.key});
  final authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.transparent,
        // shadowColor: Colors.transparent,
        title: AutoSizeText(
          'Settings',
          minFontSize:
              (getTheme(context).textTheme.displayLarge?.fontSize ?? 20),
          maxFontSize: 40,
        ),
        centerTitle: false,
      ),
      body: globalContainer(
        child: ListView(
          children: [
            ///edit profile list tile
            _editProfile(context),
            divider(context),

            ///change password list tile
            _changePassword(context),

            divider(context),

            ///theme list tile
            _switchTheme(),
            divider(context),

            ///language list tile
            if (kDebugMode) const _ChangeLanguage(),

            // ///payment methods
            // height30(),
            // Padding(
            //     padding:
            //         EdgeInsetsDirectional.symmetric(horizontal: paddingDefault),
            //     child: bodyLargeText('Payment Methods', context,
            //         fontWeight: FontWeight.w600)),

            ///others
            height30(),
            Padding(
                padding:
                    EdgeInsetsDirectional.symmetric(horizontal: paddingDefault),
                child: bodyLargeText('Others', context,
                    fontWeight: FontWeight.w600)),
            height10(),

            ///share app
            _shareApp(context),
            divider(context),

            ///rate app
            _rateApp(context),
            divider(context),

            ///about app
            _aboutUs(context),
            divider(context),

            ///logout
            _logout(context),

            height30(),

            ///delete account tilewith red tile color
            _deleteAcount(),

            ///app preferences
            _errorLog(context),
            if (kDebugMode) const EnableDevicePreview(),

            height50(),
          ],
        ),
      ),
    );
  }

  ListTile _errorLog(BuildContext context) {
    return ListTile(
      onTap: () => context.push(Routes.errorLogListScreen),
      leading: Icon(
          Platform.isIOS ? CupertinoIcons.info : Icons.info_outline_rounded),
      title: AutoSizeText(
        'Error Logs',
        style: TextStyle(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded),
    );
  }

  ListTile _deleteAcount() {
    return ListTile(
      onTap: () {
        // Get.toNamed(Routes.profileSettings);
      },
      leading: Icon(Platform.isIOS
          ? CupertinoIcons.delete
          : Icons.delete_outline_rounded),
      title: const AutoSizeText(
        'Delete Account',
        style: TextStyle(
          color: Colors.red,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.red,
      ),
    );
  }

  ListTile _logout(BuildContext context) {
    return ListTile(
      onTap: () {
        var title = 'Logout';
        var message = 'Are you sure you want to logout?';
        var yes = 'Yes';
        var no = 'No';
        onYes() {
          Navigator.pop(context);
          AuthService.instance
              .logout()
              .then((value) => context.go(Routes.auth));
        }

        showCupertinoDialog(
            context: context,
            builder: (context) => Platform.isIOS
                ? CupertinoAlertDialog(
                    title: Text(title),
                    content: Text(message),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: onYes,
                        child: Text(yes),
                      ),
                      CupertinoDialogAction(
                        child: Text(no),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  )
                : AlertDialog(
                    title: Text(title),
                    content: Text(message),
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(spaceDefault),
                    ),
                    actions: [
                      TextButton(
                        onPressed: onYes,
                        child: Text(yes),
                      ),
                      TextButton(
                        child: Text(no),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ));
      },
      leading: Icon(Platform.isIOS
          ? CupertinoIcons.power
          : Icons.power_settings_new_outlined),
      title: AutoSizeText(
        'Logout',
        style: TextStyle(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded),
    );
  }

  ListTile _aboutUs(BuildContext context) {
    return ListTile(
      onTap: () {
        // Get.toNamed(Routes.profileSettings);
      },
      leading: Icon(
          Platform.isIOS ? CupertinoIcons.info : Icons.info_outline_rounded),
      title: AutoSizeText(
        'About Us',
        style: TextStyle(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded),
    );
  }

  ListTile _rateApp(BuildContext context) {
    return ListTile(
      onTap: () {
        // Get.toNamed(Routes.profileSettings);
      },
      leading: Icon(
          Platform.isIOS ? CupertinoIcons.star : Icons.star_outline_rounded),
      title: AutoSizeText(
        'Rate App',
        style: TextStyle(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded),
    );
  }

  ListTile _shareApp(BuildContext context) {
    return ListTile(
      onTap: () => AppShare.refferAFriend(
          authController.getUser<AuctionUser>()?.username),
      leading:
          Icon(Platform.isIOS ? CupertinoIcons.share : Icons.share_outlined),
      title: AutoSizeText(
        'Share App',
        style: TextStyle(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded),
    );
  }

  ThemeSwitcher _switchTheme() {
    return ThemeSwitcher(
        clipper: const ThemeSwitcherCircleClipper(),
        builder: (context) {
          return ListTile(
            onTap: () {
              _showThemeBottomSheet(context);

              // try {
              //   ThemeService.instance.changeThemeMode(context);
              // } catch (e) {
              //   logger.e('Error in changing theme', error: e);
              // }
            },
            leading: Icon(Platform.isIOS
                ? CupertinoIcons.moon_stars
                : Icons.brightness_4_outlined),
            title: AutoSizeText(
              'Theme',
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Theme.of(context).primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withOpacity(0.1) ??
                        Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          );
        });
  }

  ListTile _changePassword(BuildContext context) {
    return ListTile(
      onTap: () {
        context.pushNamed(Paths.changePassword);
      },
      leading: Icon(
          Platform.isIOS ? CupertinoIcons.lock : Icons.lock_outline_rounded),
      title: AutoSizeText(
        'Change Password',
        style: TextStyle(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded),
    );
  }

  ListTile _editProfile(BuildContext context) {
    return ListTile(
      onTap: () {
        context.push(Routes.updateProfile);
      },
      leading: Icon(Platform.isIOS
          ? CupertinoIcons.person
          : Icons.person_outline_rounded),
      title: AutoSizeText(
        'Edit Profile',
        style: TextStyle(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded),
    );
  }

  Divider divider(BuildContext context) {
    return Divider(
        color: getTheme(context).textTheme.bodySmall?.color?.withOpacity(0.2));
  }

  void _showThemeBottomSheet(BuildContext context) {
    Get.bottomSheet(
      SizedBox(
        height: 400,
        child: ListView(
          padding: EdgeInsetsDirectional.only(bottom: paddingDefault * 2),
          children: [
            ...ThemeService.instance.allThemes.entries
                .map(
                  (e) => ListTile(
                    onTap: () {
                      ThemeService.instance
                          .changeThemeMode2(context, e.key)
                          .then((v) => 2.delay(() => Get.back()));
                    },
                    title: AutoSizeText(
                      e.key.toString().split('.')[0].capitalizeFirst!,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleLarge?.color,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
            height40(),
          ],
        ),
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}

class _ChangeLanguage extends StatelessWidget {
  const _ChangeLanguage();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Get.bottomSheet(
          SizedBox(
            height: 300,
            child: ListView(
              padding: EdgeInsetsDirectional.only(bottom: paddingDefault * 2),
              children: [
                ...AppTranslation.translations.keys
                    .map(
                      (e) => ListTile(
                        onTap: () {
                          Get.back();
                          TranslationService.changeLocale(e);
                        },
                        title: AutoSizeText(
                          e,
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        );
      },
      leading:
          Icon(Platform.isIOS ? CupertinoIcons.globe : Icons.language_outlined),
      title: AutoSizeText(
        'Language',
        style: TextStyle(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: AutoSizeText(
        'English',
        style: TextStyle(
          color: Theme.of(context).textTheme.titleLarge?.color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
