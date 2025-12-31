import 'package:flutter/widgets.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 900;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  static bool isTV(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  static bool isDesktopOrTV(BuildContext context) {
    return isDesktop(context) || isTV(context);
  }

  static double getCardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 140;
    if (width < 900) return 160;
    if (width < 1200) return 180;
    return 200;
  }

  static double getCardHeight(BuildContext context) {
    final cardWidth = getCardWidth(context);
    return cardWidth * 1.5;
  }

  static int getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 2;
    if (width < 900) return 3;
    if (width < 1200) return 4;
    if (width < 1600) return 5;
    return 6;
  }

  static double getPadding(BuildContext context) {
    if (isMobile(context)) return 12;
    if (isTablet(context)) return 16;
    return 24;
  }
}
