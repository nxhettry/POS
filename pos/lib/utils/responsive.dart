import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isExtraSmallDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width < 1280;
  }

  static bool isSmallDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width < 1366;
  }

  static bool isMediumDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1366 && 
           MediaQuery.of(context).size.width < 1920;
  }

  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1920;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static int getGridColumns(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 1280) return 3;
    if (width < 1600) return 4;
    if (width < 1920) return 5;
    return 6;
  }

  static double getCardAspectRatio(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 1280) return 0.85;
    if (width < 1600) return 0.9;
    return 1.0;
  }

  static double getDrawerWidth(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 1280) return 220;
    if (width < 1366) return 240;
    if (width < 1600) return 260;
    return 350;
  }

  static double getFontSize(BuildContext context, double baseSize) {
    final width = getScreenWidth(context);
    if (width < 1280) return baseSize * 0.85;
    if (width < 1366) return baseSize * 0.9;
    if (width < 1600) return baseSize;
    return baseSize * 1.1;
  }

  static EdgeInsets getPadding(BuildContext context, {double base = 16.0}) {
    final width = getScreenWidth(context);
    if (width < 1280) return EdgeInsets.all(base * 0.7);
    if (width < 1366) return EdgeInsets.all(base * 0.8);
    if (width < 1600) return EdgeInsets.all(base);
    return EdgeInsets.all(base * 1.25);
  }

  static double getSpacing(BuildContext context, {double base = 16.0}) {
    final width = getScreenWidth(context);
    if (width < 1280) return base * 0.75;
    if (width < 1600) return base;
    return base * 1.25;
  }

  static double getItemImageHeight(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 1280) return 120;
    if (width < 1600) return 140;
    return 160;
  }

  static double getBillSectionFlex(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 1366) return 1.2;
    if (width < 1600) return 1.1;
    return 1.0;
  }

  static double getItemsSectionFlex(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 1366) return 1.8;
    if (width < 1600) return 1.9;
    return 2.0;
  }
}
