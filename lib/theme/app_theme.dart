import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens aligned with the live lawyers.bh website, so the app and the
/// site read as one brand. The site's palette is red-led:
///
///   brandRed   #B91D1C  primary / calls to action
///   brandDark  #07111F  headers, app bar
///   brandBlue  #082B67  secondary ink
///
/// The neutral and status tokens are unchanged.
class AppColors {
  /// Website brand red — the primary colour.
  static const brandRed = Color(0xFFB91D1C);
  static const brandRedDark = Color(0xFF8B1515);
  static const brandDark = Color(0xFF07111F);
  static const brandBlue = Color(0xFF082B67);

  static const navy = Color(0xFF07111F);
  static const navyLight = Color(0xFF1E3258);

  /// Brand red, kept under its previous name so existing call sites follow the
  /// site palette rather than the old maroon.
  static const crimson = brandRed;
  /// Neutral chip/ink pair used where the old palette reached for gold. Gold is
  /// not part of the official identity, so pending/neutral states read as
  /// slate instead.
  static const neutralBg = Color(0xFFEEF1F5);
  static const neutralInk = Color(0xFF4A5364);
  static const green = Color(0xFF1E7E34);
  static const greenBg = Color(0xFFE8F5E9);
  static const amber = Color(0xFFB7791F);
  static const amberBg = Color(0xFFFBF0DC);
  static const red = Color(0xFFA62A2A);
  static const redBg = Color(0xFFFAE7E7);
  static const bg = Color(0xFFF5F4F1);
  static const surface = Color(0xFFFFFFFF);
  static const line = Color(0xFFE7E3DA);
  static const ink = Color(0xFF171C26);
  static const ink2 = Color(0xFF5B6472);
  static const ink3 = Color(0xFF9AA1AC);
  static const payGreen = Color(0xFF00A651);
  static const payBlack = Color(0xFF0D0D0D);
}

/// Professional (lawyer) palette.
///
/// The lawyer workspace is the same product as the client's, so it carries the
/// same official brand red (#B91D1C) rather than the navy/gold identity that
/// used to separate the two. The distinction between the rooms now comes from
/// layout and density, not from a competing palette. The tokens below keep
/// their original names so every call site follows the brand without churn:
/// `base`/`base2` are the brand red pair behind mastheads and app bars, `accent`
/// is the same red used for rules and icons, and `emerald`/amber/red stay as
/// functional status colours only.
class LawyerColors {
  static const base = Color(0xFFB91D1C);
  static const base2 = Color(0xFF8B1515);
  static const accent = Color(0xFFB91D1C);
  static const accentSoft = Color(0xFFFBEAEA);
  static const emerald = Color(0xFF0F7B5F);
  static const emeraldSoft = Color(0xFFE4F3EE);
  static const surface = Color(0xFFFFFFFF);
  static const canvas = Color(0xFFF4F5F8);
  static const line = Color(0xFFE3E7EE);
  static const ink = Color(0xFF14203A);
  static const ink2 = Color(0xFF5A6478);
  static const ink3 = Color(0xFF9AA3B2);
}

class AppRadii {
  static const lg = 22.0;
  static const md = 14.0;
  static const sm = 10.0;
}

class AppTextStyles {
  // Cairo — used for the brand, headings, section titles and nav labels.
  static TextStyle cairo({
    double size = 14,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.ink,
    double? height,
  }) =>
      GoogleFonts.cairo(fontSize: size, fontWeight: weight, color: color, height: height);

  // Tajawal — used for body copy, field labels and descriptions.
  static TextStyle tajawal({
    double size = 13,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double? height,
  }) =>
      GoogleFonts.tajawal(fontSize: size, fontWeight: weight, color: color, height: height);
}

class AppShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.navy.withValues(alpha: 0.09),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}

ThemeData buildAppTheme({Color? backgroundColor}) {
  final base = ThemeData.light();
  return base.copyWith(
    // Transparent so the single global background layer (see
    // AppBackgroundScope) shows through every screen. Screens that painted an
    // opaque scaffold colour are switched to transparent as well, so the app
    // reads as content-on-background rather than content-on-a-white-sheet.
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.brandRed,
      secondary: AppColors.crimson,
      error: AppColors.red,
    ),
    textTheme: GoogleFonts.tajawalTextTheme(base.textTheme).apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.brandDark,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: AppTextStyles.cairo(size: 16, weight: FontWeight.w800, color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: const BorderSide(color: AppColors.line),
      ),
      margin: const EdgeInsets.only(bottom: 12),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        borderSide: const BorderSide(color: AppColors.brandRed, width: 1.4),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandRed,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.sm)),
        textStyle: AppTextStyles.cairo(size: 13.5, weight: FontWeight.w700, color: Colors.white),
      ),
    ),
  );
}
