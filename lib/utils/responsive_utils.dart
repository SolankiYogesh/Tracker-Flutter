import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double baseWidth = 375.0;
  static const double baseHeight = 812.0;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 600 &&
      MediaQuery.sizeOf(context).width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1200;

  static double scaleWidth(BuildContext context, double value) {
    return (screenWidth(context) / baseWidth) * value;
  }

  static double scaleHeight(BuildContext context, double value) {
    return (screenHeight(context) / baseHeight) * value;
  }

  static double scaleText(BuildContext context, double value) {
    final width = screenWidth(context);
    final scale = width / baseWidth;

    // Dampen the scaling factor for text to avoid extremes.
    // Text doesn't need to scale as aggressively as container widths.
    double dampenedScale = 1.0 + (scale - 1.0) * 0.5;

    // Clamp the scale factor to ensure text stays within readable bounds
    dampenedScale = dampenedScale.clamp(0.85, 1.3);

    return MediaQuery.textScalerOf(context).scale(value * dampenedScale);
  }
}

extension ResponsiveExtension on BuildContext {
  double get sw => ResponsiveUtils.screenWidth(this);
  double get sh => ResponsiveUtils.screenHeight(this);
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);

  double w(double value) => ResponsiveUtils.scaleWidth(this, value);
  double h(double value) => ResponsiveUtils.scaleHeight(this, value);
  double sp(double value) => ResponsiveUtils.scaleText(this, value);
}
