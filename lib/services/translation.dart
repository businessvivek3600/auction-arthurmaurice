import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../database/init_get_storages.dart';
import '../generated/locales.g.dart';

class TranslationService extends Translations {
  TranslationService._() {
    init();
  }
  static final TranslationService _instance = TranslationService._();
  factory TranslationService() => _instance;

  static GetStorage localeBox = GetStorage(LocalStorage.appBox);
  static const localeStorageKey = 'locale';

  static String? get getLocaleKey =>
      localeBox.read<String?>(localeStorageKey) ??
      Get.deviceLocale?.languageCode;
  static void saveLocaleKey(String? locale) =>
      localeBox.write(localeStorageKey, locale);

  static void changeLocale(String? locale) {
    Get.updateLocale(getLocaleFromLanguage(locale));
    saveLocaleKey(locale);
    log('changeLocale: $locale  $getLocaleKey');
  }

  static const fallbackLocale = Locale('en', 'US');

  static late List<Locale> locales;

  static Locale getLocaleFromLanguage(String? languageCode) {
    try {
      if (languageCode != null) {
        for (var locale in locales) {
          if (locale.languageCode == languageCode) {
            return locale;
          }
        }
      }
    } catch (e) {
      log('_getLocaleFromLanguage error: $e');
    }
    return fallbackLocale;
  }

  @override
  Map<String, Map<String, String>> get keys => AppTranslation.translations;

  init() {
    locales = AppTranslation.translations.keys.map((e) => Locale(e)).toList();
    Future.delayed(const Duration(milliseconds: 500), () {
      changeLocale(getLocaleKey);
    });
    // getLocaleFromLanguage(Get.deviceLocale?.languageCode);
  }
}
