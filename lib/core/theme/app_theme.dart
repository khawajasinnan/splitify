import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

/// App theme configuration with premium dark and light themes
class AppTheme {
  AppTheme._();

  // Dark Theme - Magma Obsidian Spectrum
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.dark(
      primary: AppColors.magmaOrange,
      secondary: AppColors.primaryLight,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimary,
      onError: Colors.white,
    ),
    
    // App Bar Theme
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.surface,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: AppConstants.fontHeading,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.cardBg,
      elevation: 4,
      shadowColor: AppColors.shadowDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        side: BorderSide(
          color: AppColors.border,
          width: 1.5,
        ),
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 4,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing24,
          vertical: AppConstants.spacing16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        backgroundColor: AppColors.magmaOrange,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.inter(
          fontSize: AppConstants.fontMedium,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.magmaOrange,
        textStyle: GoogleFonts.inter(
          fontSize: AppConstants.fontMedium,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        borderSide: BorderSide(color: AppColors.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        borderSide: BorderSide(color: AppColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        borderSide: BorderSide(color: AppColors.magmaOrange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
      labelStyle: GoogleFonts.inter(
        color: AppColors.textSecondary,
        fontSize: AppConstants.fontMedium,
      ),
      hintStyle: GoogleFonts.inter(
        color: AppColors.textTertiary,
        fontSize: AppConstants.fontMedium,
      ),
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: AppConstants.fontTitle,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: AppConstants.fontHeading,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: AppConstants.fontXLarge,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: AppConstants.fontLarge,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: AppConstants.fontMedium,
        color: AppColors.textPrimary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: AppConstants.fontSmall,
        color: AppColors.textSecondary,
      ),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.textPrimary,
      size: AppConstants.iconMedium,
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryTeal,
      foregroundColor: AppColors.textWhite,
      elevation: AppConstants.elevationHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkNavyLight,
      selectedItemColor: AppColors.primaryTeal,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: AppConstants.elevationHigh,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: AppConstants.fontSmall,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: AppConstants.fontSmall,
      ),
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: AppColors.glassBorder,
      thickness: 1,
      space: AppConstants.spacing16,
    ),
  );

  // Light Theme - Magma Obsidian Light
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Soft white
    colorScheme: ColorScheme.light(
      primary: AppColors.magmaOrange,
      secondary: AppColors.primaryLight,
      surface: Colors.white,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF2D3748), // Dark gray
      onError: Colors.white,
    ),
    
    // App Bar Theme
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: AppConstants.fontHeading,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF2D3748),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xFF2D3748),
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing24,
          vertical: AppConstants.spacing16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        backgroundColor: AppColors.magmaOrange,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.inter(
          fontSize: AppConstants.fontMedium,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.magmaOrange,
        textStyle: GoogleFonts.inter(
          fontSize: AppConstants.fontMedium,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.magmaOrange,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
      labelStyle: GoogleFonts.inter(
        color: const Color(0xFF718096),
        fontSize: AppConstants.fontMedium,
      ),
      hintStyle: GoogleFonts.inter(
        color: const Color(0xFFA0AEC0),
        fontSize: AppConstants.fontMedium,
      ),
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: AppConstants.fontTitle,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF2D3748),
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: AppConstants.fontHeading,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2D3748),
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: AppConstants.fontXLarge,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2D3748),
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: AppConstants.fontLarge,
        color: const Color(0xFF2D3748),
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: AppConstants.fontMedium,
        color: const Color(0xFF2D3748),
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: AppConstants.fontSmall,
        color: const Color(0xFF718096),
      ),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: Color(0xFF2D3748),
      size: AppConstants.iconMedium,
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.magmaOrange,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.magmaOrange,
      unselectedItemColor: const Color(0xFF718096),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: AppConstants.fontSmall,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: AppConstants.fontSmall,
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE2E8F0),
      thickness: 1,
      space: AppConstants.spacing16,
    ),
  );
}
