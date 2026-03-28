import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static TextTheme _buildTextTheme(Color t1, Color t2, Color t3) {
    return TextTheme(
      // Display
      displayLarge:  GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w800, color: t1, height: 1.1, letterSpacing: -1.0),
      displayMedium: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w800, color: t1, height: 1.15, letterSpacing: -0.8),
      displaySmall:  GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: t1, height: 1.2, letterSpacing: -0.5),
      // Headline
      headlineLarge:  GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: t1, height: 1.3, letterSpacing: -0.3),
      headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: t1, height: 1.3),
      headlineSmall:  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: t1, height: 1.3),
      // Title
      titleLarge:  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: t1, height: 1.4),
      titleMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: t1, height: 1.4),
      titleSmall:  GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: t2, height: 1.4),
      // Body
      bodyLarge:   GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: t1, height: 1.55),
      bodyMedium:  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: t2, height: 1.55),
      bodySmall:   GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: t3, height: 1.5),
      // Label
      labelLarge:  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: t1, height: 1.3),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: t2, height: 1.3),
      labelSmall:  GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: t3, height: 1.3, letterSpacing: 0.2),
    );
  }

  static ThemeData get light {
    final txt = _buildTextTheme(AppColors.t1Light, AppColors.t2Light, AppColors.t3Light);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary:    AppColors.primary,
        secondary:  AppColors.secondary,
        surface:    AppColors.surfaceLight,
        error:      AppColors.error,
        onPrimary:  Colors.white,
        onSecondary: Colors.white,
        onSurface:  AppColors.t1Light,
      ),
      scaffoldBackgroundColor: AppColors.bgLight,
      textTheme: txt,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.bgLight,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: txt.headlineSmall,
        iconTheme: const IconThemeData(color: AppColors.t1Light, size: 22),
        actionsIconTheme: const IconThemeData(color: AppColors.t2Light, size: 22),
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: txt.bodyMedium?.copyWith(color: AppColors.t3Light),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.t3Light,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        dividerColor: AppColors.borderLight,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight, thickness: 1, space: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: StadiumBorder(),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final txt = _buildTextTheme(AppColors.t1Dark, AppColors.t2Dark, AppColors.t3Dark);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary:    AppColors.primary,
        secondary:  AppColors.secondary,
        surface:    AppColors.surfaceDark,
        error:      AppColors.error,
        onPrimary:  Colors.white,
        onSecondary: Colors.white,
        onSurface:  AppColors.t1Dark,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
      textTheme: txt,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.bgDark,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: txt.headlineSmall,
        iconTheme: const IconThemeData(color: AppColors.t1Dark, size: 22),
        actionsIconTheme: const IconThemeData(color: AppColors.t2Dark, size: 22),
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: txt.bodyMedium?.copyWith(color: AppColors.t3Dark),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.t3Dark,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        dividerColor: AppColors.borderDark,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark, thickness: 1, space: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: StadiumBorder(),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}
