import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import 'size_utils.dart';

// Light Mode Colors
// const Color lightPrimary = Color.fromARGB(255, 13, 209, 137); // Primary color
// const Color lightAccent = Color.fromARGB(255, 27, 101, 74); // Accent color

const kPrimaryColor = Color(0xFF272841);
const kPrimaryColor2 = Color(0xFF403f74);
const kPrimaryColor3 = Color(0xFF6C6C9A);
const kPrimaryColor4 = Color(0xFF8D8FB8);
const kPrimaryColor5 = Color(0xFFF74a05);
const kPrimaryColor6 = Color(0xFFFF5DA3);
const kPrimaryColor7 = Color(0xFF86ADff);
const kPrimaryColor8 = Color(0xFF7104f8);
const kPrimaryColor9 = Color(0xFFB72DF7);
const kPrimaryColor10 = Color(0xFFfc5f00);
const kPrimaryColor11 = Color(0xFFca5000);
const kSecondaryColor = Color(0xFF3F4158);
const kSecondaryColor2 = Color(0xFFD9D3D9);
const kSecondaryColor3 = Color(0xFFD9D9E4);
const kSecondaryColor4 = Color(0xFF3f4058);
const Color lightPrimary = Color(0xFF403f74); // Primary color
const Color lightAccent = kPrimaryColor; // Accent color
const Color lightBackground = Color(0xFF6C6C9A); // Background color
const Color lightText = Color(0xFF8D8FB8); // Text color

// Dark Mode Colors
// const Color darkPrimary = Color.fromARGB(255, 12, 31, 206); // Primary color
// const Color darkAccent = Color.fromARGB(255, 26, 30, 100); // Accent color
const Color darkPrimary = Color.fromARGB(255, 93, 122, 251); // Primary color
const Color darkAccent = Color.fromARGB(255, 73, 104, 244); // Accent color
const Color darkBackground = Color(0xFF121212); // Background color
Color darkBlueGrey = Colors.blueGrey.darken(60); // Background color
const Color darkText = Colors.white; // Text color¯

// Other Colors
const Color errorRed = Color(0xFFE57373); // Error color
const Color successGreen = Color(0xFF81C784); // Success color
const Color warningYellow = Color(0xFFFFD54F); // Warning color

const Color mainColor = Color(0xfff2f3f6);
// const Color mainColor = Color(0xccf5f1f1);
const Color mainColor100 = Color(0x120a0d0a);
const Color mainColor200 = Color(0x330a0d15);
const Color mainColor300 = Color(0x4d0a0d15);
const Color mainColor400 = Color(0x660a0d15);
const Color mainColor500 = Color(0x800a0d15);
const Color mainColor600 = Color(0x990a0d15);
const Color mainColor700 = Color(0xcc0a0d15);
const Color mainColor800 = Color(0xe60a0d15);
const Color mainColor900 = Color(0xf20a0d15);

const Color appLogoColor = Color(0xff02457C);
const Color appLogoColor2 = Color(0xff6DBA00);
const Color lightAppLogoColor = Color(0xff6DBA00);

const Color secondaryColorShaded = Color(0xff135179);
const Color secondaryColor2 = Color(0xffa457ec);
const Color colorGreen = Color(0xff16b940);
const Color colorYellow = Color(0xfffac00b);
const Color colorBlue = Color(0xff57a0f3);
const Color yearlyPackColor = Color(0xffec6df4);
const Color monthlyPackColor = Color(0xff74c2fb);

///text color
const Color titleTextColor = Color(0xff070707);
const Color mTitleTextColor = Color(0x79070707);
const Color capTextColor = Color(0x34070707);

//tools color
const Color cursorColor = Color(0xff070707);
const Color linkColor = Colors.blueAccent;
const Color purpleLight = Color(0xff1e224c);
const Color purpleDark = Color(0xff0d193e);
const Color orangeLight = Color(0xffec8d2f);
const Color orangeDark = Color(0xfff8b250);
const Color redLight = Color(0xfff44336);
const Color redDark = Color(0xffff5182);
const Color blueLight = Color(0xff0293ee);
const Color greenLight = Color(0xff13d38e);
// const Color defaultBottomSheetColor = Color(0xff083261);
const Color defaultBottomSheetColor = Color(0xff023c5b);

final Map<int, Color> colorMapper = {
  0: Colors.white,
  1: Colors.blueGrey[50]!,
  2: Colors.blueGrey[100]!,
  3: Colors.blueGrey[200]!,
  4: Colors.blueGrey[300]!,
  5: Colors.blueGrey[400]!,
  6: Colors.blueGrey[500]!,
  7: Colors.blueGrey[600]!,
  8: Colors.blueGrey[700]!,
  9: Colors.blueGrey[800]!,
  10: Colors.blueGrey[900]!,
};

extension ColorUtil on Color {
  Color byLuminance() =>
      computeLuminance() > 0.4 ? Colors.black87 : Colors.white;
}

Color fromHex(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

extension ColorExtension on Color {
  /// Convert the color to a darken color based on the [percent]
  Color darken([int percent = 40]) {
    assert(1 <= percent && percent <= 100);
    final value = 1 - percent / 100;
    return Color.fromARGB(
      alpha,
      (red * value).round(),
      (green * value).round(),
      (blue * value).round(),
    );
  }

  Color lighten([int percent = 40]) {
    assert(1 <= percent && percent <= 100);
    final value = percent / 100;
    return Color.fromARGB(
      alpha,
      (red + ((255 - red) * value)).round(),
      (green + ((255 - green) * value)).round(),
      (blue + ((255 - blue) * value)).round(),
    );
  }

  Color avg(Color other) {
    final red = (this.red + other.red) ~/ 2;
    final green = (this.green + other.green) ~/ 2;
    final blue = (this.blue + other.blue) ~/ 2;
    final alpha = (this.alpha + other.alpha) ~/ 2;
    return Color.fromARGB(alpha, red, green, blue);
  }
}

Color generateRandomLightColor() {
  final random = Random();
  int red = random.nextInt(128) + 128; // Ensure a light red value (128-255)
  int green = random.nextInt(128) + 128; // Ensure a light green value (128-255)
  int blue = random.nextInt(128) + 128; // Ensure a light blue value (128-255)

  return Color.fromARGB(255, red, green, blue);
}

LinearGradient globalPageGradient1() {
  return LinearGradient(
      colors: [
        getTheme().colorScheme.primary.withOpacity(.1),
        getTheme().colorScheme.primary.withOpacity(0.2),
        getTheme().colorScheme.primary.withOpacity(0.3),
        getTheme().colorScheme.primary.withOpacity(0.4),
        getTheme().colorScheme.primary.withOpacity(0.6),
        getTheme().colorScheme.primary.withOpacity(0.5),
        getTheme().colorScheme.primary.withOpacity(0.4),
        getTheme().colorScheme.primary.withOpacity(0.3),
        getTheme().colorScheme.primary.withOpacity(0.2),
        getTheme().colorScheme.primary.withOpacity(0.1),
      ].reversed.toList(),
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter);
}

buildAppbarGradient({List<Color>? colors}) {
  bool isDark = getTheme().brightness == Brightness.dark;
  Color color1 = isDark ? darkPrimary : lightPrimary;
  Color color2 = isDark ? darkAccent : lightAccent;
  return LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.bottomRight,
    colors: colors ?? [color1, color2],
  );
}

Color? getColor(String? bgColor) {
  if (bgColor == null || bgColor.isEmpty) return null;
  int? value = HexColor(bgColor).value;
  return Color(value);
}
