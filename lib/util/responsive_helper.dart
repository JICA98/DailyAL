import 'package:flutter/material.dart';

/// Screen size classification following Material Design guidelines
enum ScreenSize {
  compact,      // 0-599dp (phones)
  medium,       // 600-839dp (small tablets, foldables)
  expanded,     // 840-1199dp (large tablets)
  large,        // 1200-1599dp (desktops)
  extraLarge,   // 1600dp+ (ultra-wide)
}

/// Helper class for responsive design across different screen sizes
class ResponsiveHelper {
  /// Get the current screen size classification
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return ScreenSize.compact;
    if (width < 840) return ScreenSize.medium;
    if (width < 1200) return ScreenSize.expanded;
    if (width < 1600) return ScreenSize.large;
    return ScreenSize.extraLarge;
  }
  
  /// Check if device is tablet or larger
  static bool isTabletOrLarger(BuildContext context) {
    return getScreenSize(context).index >= ScreenSize.medium.index;
  }
  
  /// Check if device is compact (phone)
  static bool isCompact(BuildContext context) {
    return getScreenSize(context) == ScreenSize.compact;
  }
  
  /// Check if device is medium (small tablet)
  static bool isMedium(BuildContext context) {
    return getScreenSize(context) == ScreenSize.medium;
  }
  
  /// Check if device is expanded or larger (large tablet+)
  static bool isExpandedOrLarger(BuildContext context) {
    return getScreenSize(context).index >= ScreenSize.expanded.index;
  }
  
  /// Get horizontal padding based on screen size
  static double getHorizontalPadding(BuildContext context) {
    final size = getScreenSize(context);
    return switch (size) {
      ScreenSize.compact => 12.0,
      ScreenSize.medium => 16.0,
      ScreenSize.expanded => 24.0,
      ScreenSize.large => 32.0,
      ScreenSize.extraLarge => 40.0,
    };
  }
  
  /// Get content padding based on screen size
  static EdgeInsets getContentPadding(BuildContext context) {
    final horizontalPadding = getHorizontalPadding(context);
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: 16.0,
    );
  }
  
  /// Get adaptive grid cross axis count
  static int getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) return 3; // Phone: 3 columns
    if (screenWidth < 840) return 4; // Small tablet: 4 columns
    if (screenWidth < 1200) return 5; // Large tablet: 5 columns
    return 6; // Desktop: 6 columns
  }
  
  /// Get adaptive poster width
  static double getPosterWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) return 120; // Phone
    if (screenWidth < 840) return 160; // Small tablet
    if (screenWidth < 1200) return 200; // Large tablet
    return 240; // Desktop
  }
  
  /// Get adaptive poster height (maintains 1:1.4 aspect ratio)
  static double getPosterHeight(BuildContext context) {
    return getPosterWidth(context) * 1.4;
  }
  
  /// Get adaptive section spacing
  static double getSectionSpacing(BuildContext context) {
    final size = getScreenSize(context);
    return switch (size) {
      ScreenSize.compact => 16.0,
      ScreenSize.medium => 20.0,
      ScreenSize.expanded => 24.0,
      ScreenSize.large => 28.0,
      ScreenSize.extraLarge => 32.0,
    };
  }
  
  /// Get adaptive card spacing
  static double getCardSpacing(BuildContext context) {
    final size = getScreenSize(context);
    return switch (size) {
      ScreenSize.compact => 8.0,
      ScreenSize.medium => 12.0,
      ScreenSize.expanded => 16.0,
      ScreenSize.large => 16.0,
      ScreenSize.extraLarge => 16.0,
    };
  }
}
