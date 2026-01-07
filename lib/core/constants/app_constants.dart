import 'package:flutter/material.dart';

/// App-wide constants for Splitlify
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Splitlify';
  static const String appTagline = 'Share expenses. Simplify life.';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Spacing
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Icon Sizes
  static const double iconSmall = 18.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Font Sizes (Slightly larger for better readability)
  static const double fontSmall = 13.0;
  static const double fontMedium = 15.0;
  static const double fontLarge = 17.0;
  static const double fontXLarge = 20.0;
  static const double fontHeading = 26.0;
  static const double fontTitle = 34.0;

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Split Types
  static const String splitTypeEqual = 'equal';
  static const String splitTypePercentage = 'percentage';
  static const String splitTypeCustom = 'custom';

  // Settlement Status
  static const String settlementPending = 'pending';
  static const String settlementCompleted = 'completed';
  static const String settlementCancelled = 'cancelled';

  // Transaction Types
  static const String transactionExpense = 'expense';
  static const String transactionSettlement = 'settlement';
  static const String transactionPayment = 'payment';

  // Group Member Roles
  static const String roleAdmin = 'admin';
  static const String roleMember = 'member';

  // Default Values
  static const String defaultCurrency = 'PKR';
  static const String defaultCurrencySymbol = '₨';

  // Supported Currencies
  static const Map<String, String> currencies = {
    'PKR': '₨',   // Pakistani Rupee
    'USD': '\$',  // US Dollar
    'EUR': '€',   // Euro
    'GBP': '£',   // British Pound
    'INR': '₹',   // Indian Rupee
    'AED': 'د.إ', // UAE Dirham
    'SAR': '﷼',   // Saudi Riyal
  };

  static const Map<String, String> currencyNames = {
    'PKR': 'Pakistani Rupee',
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'INR': 'Indian Rupee',
    'AED': 'UAE Dirham',
    'SAR': 'Saudi Riyal',
  };
}

/// Color constants - Magma Obsidian Spectrum
class AppColors {
  AppColors._();

  // Magma Obsidian Spectrum Palette
  static const Color magmaOrange = Color(0xFFFE3B15); // Vibrant magma orange-red
  static const Color obsidianDark = Color(0xFF3C3C4C); // Deep charcoal
  static const Color stoneGray = Color(0xFF545245); // Dark warm gray
  static const Color coolGray = Color(0xFF9DA1AA); // Cool medium gray
  static const Color lightStone = Color(0xFFB7B6AC); // Light warm gray

  // Primary Colors - Magma Theme
  static const Color primary = Color(0xFFFE3B15); // Magma orange (main brand)
  static const Color primaryDark = Color(0xFFD63210); // Darker magma
  static const Color primaryLight = Color(0xFFFF6B4A); // Lighter magma
  
  // Background Colors - Dark Obsidian Theme
  static const Color background = Color(0xFF2A2A35); // Deep background
  static const Color surface = Color(0xFF3C3C4C); // Obsidian dark
  static const Color surfaceLight = Color(0xFF4A4A5C); // Lighter surface
  static const Color cardBg = Color(0xFF45454F); // Card background
  
  // Text Colors - High Contrast on Dark
  static const Color textPrimary = Color(0xFFFFFFFF); // Pure white
  static const Color textSecondary = Color(0xFF9DA1AA); // Cool gray
  static const Color textTertiary = Color(0xFF6B6F7A); // Darker gray
  static const Color textOnMagma = Color(0xFFFFFFFF); // White on magma

  // Accent Colors
  static const Color accentYellow = Color(0xFFFFC107); // Warm yellow
  static const Color accentPurple = Color(0xFF9C27B0); // Rich purple
  static const Color accentTeal = Color(0xFF00BCD4); // Bright teal

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color error = Color(0xFFFE3B15); // Magma orange for errors
  static const Color warning = Color(0xFFFFC107); // Yellow
  static const Color info = Color(0xFF2196F3); // Blue

  // Gradients - Magma Theme
  static const LinearGradient magmaGradient = LinearGradient(
    colors: [Color(0xFFFE3B15), Color(0xFFFF6B4A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient obsidianGradient = LinearGradient(
    colors: [Color(0xFF3C3C4C), Color(0xFF2A2A35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient magmaObsidianGradient = LinearGradient(
    colors: [Color(0xFFFE3B15), Color(0xFFD63210), Color(0xFF3C3C4C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Avatar Colors
  static const Color avatarRed = Color(0xFFFE3B15);
  static const Color avatarOrange = Color(0xFFFF9800);
  static const Color avatarYellow = Color(0xFFFFC107);
  static const Color avatarBlue = Color(0xFF2196F3);
  static const Color avatarPurple = Color(0xFF9C27B0);
  static const Color avatarTeal = Color(0xFF00BCD4);

  // Borders & Dividers
  static const Color border = Color(0xFF545245);
  static const Color divider = Color(0xFF4A4A5C);
  static Color borderLight = const Color(0xFF6B6F7A).withOpacity(0.3);

  // Shadows
  static Color shadowDark = Colors.black.withOpacity(0.4);
  static Color shadowMedium = Colors.black.withOpacity(0.25);
  static Color shadowLight = Colors.black.withOpacity(0.15);
  static Color glowMagma = const Color(0xFFFE3B15).withOpacity(0.4);

  // Legacy compatibility
  static const Color primaryTeal = Color(0xFF00BCD4); // Keep for compatibility
  static const Color primaryCyan = Color(0xFF00BCD4);
  static const Color accentOrange = Color(0xFFFE3B15);
  static const Color accentCoral = Color(0xFFFE3B15);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color tealLight = Color(0xFF4DD0E1);
  static const Color tealDark = Color(0xFF0097A7);
  static const Color darkBackground = Color(0xFF2A2A35);
  static const Color darkNavy = Color(0xFF3C3C4C);
  static const Color darkNavyLight = Color(0xFF4A4A5C);
  static const Color cardDark = Color(0xFF45454F);
  static const Color lightMintBg = Color(0xFF2A2A35);
  static const Color lightBackground = Color(0xFF2A2A35);
  static const Color lightSurface = Color(0xFF3C3C4C);
  static const Color lightCard = Color(0xFF45454F);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textWhite = Color(0xFFFFFFFF);
  static Color glassBorder = const Color(0xFF6B6F7A).withOpacity(0.3);
  static Color glassLight = Colors.white.withOpacity(0.05);
  
  // Additional gradients for compatibility
  static const LinearGradient tealGradient = magmaGradient;
  static const LinearGradient orangeGradient = magmaGradient;
  static const LinearGradient coralGradient = magmaGradient;
  static const LinearGradient balanceGradient = magmaGradient;
}
