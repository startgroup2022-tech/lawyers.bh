import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color navy = Color(0xFF0F1E36);
  static const Color navyLight = Color(0xFF1E3258);
  static const Color crimson = Color(0xFF861F41);
  static const Color gold = Color(0xFFC59B27);
  static const Color goldBg = Color(0xFFFFF4DE);
  static const Color green = Color(0xFF1E7E34);
  static const Color greenBg = Color(0xFFE8F5E9);
  static const Color amber = Color(0xFFB7791F);
  static const Color amberBg = Color(0xFFFBF0DC);
  static const Color red = Color(0xFFA62A2A);
  static const Color redBg = Color(0xFFFAE7E7);

  static const Color bg = Color(0xFFF5F4F1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color line = Color(0xFFE7E3DA);
  static const Color ink = Color(0xFF171C26);
  static const Color ink2 = Color(0xFF5B6472);
  static const Color ink3 = Color(0xFF9AA1AC);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  static const Color benefitPayGreen = Color(0xFF00A651);
  static const Color applePayBlack = Color(0xFF0D0D0D);

  static const Color shadow = Color(0x190F1E36);

  static const Color overlayDark = Color(0x80000000);
  static const Color overlayLight = Color(0x80FFFFFF);
}

class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
        height: 1.2,
      );

  static TextStyle get displayMedium => GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
        height: 1.3,
      );

  static TextStyle get displaySmall => GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        height: 1.3,
      );

  static TextStyle get headlineLarge => GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
        height: 1.4,
      );

  static TextStyle get headlineMedium => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        height: 1.4,
      );

  static TextStyle get headlineSmall => GoogleFonts.cairo(
        fontSize: 14.5,
        fontWeight: FontWeight.w800,
        color: AppColors.navy,
        height: 1.5,
      );

  static TextStyle get titleLarge => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        height: 1.5,
      );

  static TextStyle get titleMedium => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
        height: 1.5,
      );

  static TextStyle get titleSmall => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        height: 1.5,
      );

  static TextStyle get bodyLarge => GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.ink,
        height: 1.6,
      );

  static TextStyle get bodyMedium => GoogleFonts.tajawal(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.ink,
        height: 1.6,
      );

  static TextStyle get bodySmall => GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.ink2,
        height: 1.6,
      );

  static TextStyle get labelLarge => GoogleFonts.cairo(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        height: 1.5,
      );

  static TextStyle get labelMedium => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
        height: 1.5,
      );

  static TextStyle get labelSmall => GoogleFonts.cairo(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.gold,
        height: 1.5,
      );

  static TextStyle get caption => GoogleFonts.tajawal(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.ink3,
        height: 1.5,
      );

  static TextStyle get overline => GoogleFonts.tajawal(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.ink3,
        height: 1.5,
      );

  static TextStyle get navLabel => GoogleFonts.cairo(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.ink3,
        height: 1.3,
      );

  static TextStyle get navLabelActive => GoogleFonts.cairo(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
        height: 1.3,
      );

  static TextStyle badgeStyle(Color bgColor, Color textColor) => GoogleFonts.cairo(
        fontSize: 9.5,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.3,
      );

  static TextStyle statValue => GoogleFonts.cairo(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
        height: 1.2,
      );

  static TextStyle statLabel => GoogleFonts.tajawal(
        fontSize: 9.5,
        fontWeight: FontWeight.w400,
        color: AppColors.ink3,
        height: 1.2,
      );

  static TextStyle ratingStyle => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
        height: 1.2,
      );
}

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      primaryColor: AppColors.navy,
      colorScheme: const ColorScheme.light(
        primary: AppColors.navy,
        secondary: AppColors.gold,
        tertiary: AppColors.crimson,
        surface: AppColors.surface,
        background: AppColors.bg,
        error: AppColors.red,
        onPrimary: AppColors.white,
        onSecondary: AppColors.navy,
        onSurface: AppColors.ink,
        onBackground: AppColors.ink,
        onError: AppColors.white,
        outline: AppColors.line,
        outlineVariant: AppColors.line,
      ),
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
      navigationBarTheme: _navigationBarTheme,
      tabBarTheme: _tabBarTheme,
      chipTheme: _chipTheme,
      dividerTheme: _dividerTheme,
      dialogTheme: _dialogTheme,
      bottomSheetTheme: _bottomSheetTheme,
      snackBarTheme: _snackBarTheme,
      floatingActionButtonTheme: _fabTheme,
      progressIndicatorTheme: _progressIndicatorTheme,
      checkboxTheme: _checkboxTheme,
      radioTheme: _radioTheme,
      switchTheme: _switchTheme,
      sliderTheme: _sliderTheme,
      tooltipTheme: _tooltipTheme,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.navy,
      primaryColor: AppColors.gold,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.gold,
        tertiary: AppColors.crimson,
        surface: AppColors.navyLight,
        background: AppColors.navy,
        error: AppColors.red,
        onPrimary: AppColors.navy,
        onSecondary: AppColors.navy,
        onSurface: AppColors.white,
        onBackground: AppColors.white,
        onError: AppColors.white,
        outline: AppColors.navyLight,
        outlineVariant: AppColors.navyLight,
      ),
      textTheme: _textTheme.apply(
        bodyColor: AppColors.white,
        displayColor: AppColors.white,
      ),
      appBarTheme: _appBarTheme.copyWith(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
      ),
      cardTheme: _cardTheme.copyWith(
        color: AppColors.navyLight,
        shadowColor: AppColors.black,
      ),
      bottomNavigationBarTheme: _bottomNavigationBarTheme.copyWith(
        backgroundColor: AppColors.navyLight,
      ),
      navigationBarTheme: _navigationBarTheme.copyWith(
        backgroundColor: AppColors.navyLight,
      ),
      dialogTheme: _dialogTheme.copyWith(
        backgroundColor: AppColors.navyLight,
      ),
      bottomSheetTheme: _bottomSheetTheme.copyWith(
        backgroundColor: AppColors.navyLight,
      ),
    );
  }

  static const TextTheme _textTheme = TextTheme(
    displayLarge: AppTextStyles.displayLarge,
    displayMedium: AppTextStyles.displayMedium,
    displaySmall: AppTextStyles.displaySmall,
    headlineLarge: AppTextStyles.headlineLarge,
    headlineMedium: AppTextStyles.headlineMedium,
    headlineSmall: AppTextStyles.headlineSmall,
    titleLarge: AppTextStyles.titleLarge,
    titleMedium: AppTextStyles.titleMedium,
    titleSmall: AppTextStyles.titleSmall,
    bodyLarge: AppTextStyles.bodyLarge,
    bodyMedium: AppTextStyles.bodyMedium,
    bodySmall: AppTextStyles.bodySmall,
    labelLarge: AppTextStyles.labelLarge,
    labelMedium: AppTextStyles.labelMedium,
    labelSmall: AppTextStyles.labelSmall,
  );

  static const AppBarTheme _appBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    scrolledUnderElevation: 1,
    surfaceTintColor: Colors.transparent,
    backgroundColor: AppColors.navy,
    foregroundColor: AppColors.white,
    titleTextStyle: AppTextStyles.headlineMedium,
    iconTheme: IconThemeData(color: AppColors.white, size: 24),
    actionsIconTheme: IconThemeData(color: AppColors.white, size: 24),
    toolbarHeight: 56,
  );

  static const CardThemeData _cardTheme = CardThemeData(
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppConstants.defaultBorderRadius)),
      side: BorderSide(color: AppColors.line, width: 1),
    ),
    color: AppColors.surface,
    shadowColor: AppColors.shadow,
    surfaceTintColor: Colors.transparent,
  );

  static final ElevatedButtonThemeData _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: AppColors.navy,
      foregroundColor: AppColors.white,
      disabledBackgroundColor: AppColors.line,
      disabledForegroundColor: AppColors.ink3,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
      minimumSize: const Size(double.infinity, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      textStyle: AppTextStyles.labelLarge,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      animationDuration: AppConstants.shortAnimationDuration,
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.ink2,
      disabledForegroundColor: AppColors.ink3,
      side: const BorderSide(color: AppColors.line, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
      minimumSize: const Size(double.infinity, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      textStyle: AppTextStyles.labelLarge.copyWith(color: AppColors.ink2),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      animationDuration: AppConstants.shortAnimationDuration,
    ),
  );

  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.navy,
      disabledForegroundColor: AppColors.ink3,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      minimumSize: const Size(88, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      textStyle: AppTextStyles.labelMedium,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      animationDuration: AppConstants.shortAnimationDuration,
    ),
  );

  static const InputDecorationTheme _inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: AppTextStyles.bodySmall,
    labelStyle: AppTextStyles.bodyMedium,
    floatingLabelStyle: AppTextStyles.labelMedium,
    errorStyle: AppTextStyles.caption.copyWith(color: AppColors.red),
    counterStyle: AppTextStyles.caption,
    prefixIconColor: AppColors.ink3,
    suffixIconColor: AppColors.ink3,
    iconColor: AppColors.ink3,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppConstants.smallBorderRadius)),
      borderSide: BorderSide(color: AppColors.line, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppConstants.smallBorderRadius)),
      borderSide: BorderSide(color: AppColors.line, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppConstants.smallBorderRadius)),
      borderSide: BorderSide(color: AppColors.navy, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppConstants.smallBorderRadius)),
      borderSide: BorderSide(color: AppColors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppConstants.smallBorderRadius)),
      borderSide: BorderSide(color: AppColors.red, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppConstants.smallBorderRadius)),
      borderSide: BorderSide(color: AppColors.line, width: 1),
    ),
  );

  static const BottomNavigationBarThemeData _bottomNavigationBarTheme = BottomNavigationBarThemeData(
    elevation: 8,
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.navy,
    unselectedItemColor: AppColors.ink3,
    selectedLabelStyle: AppTextStyles.navLabelActive,
    unselectedLabelStyle: AppTextStyles.navLabel,
    type: BottomNavigationBarType.fixed,
    showSelectedLabels: true,
    showUnselectedLabels: true,
    landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
  );

  static const NavigationBarThemeData _navigationBarTheme = NavigationBarThemeData(
    elevation: 8,
    backgroundColor: AppColors.surface,
    indicatorColor: AppColors.goldBg,
    labelTextStyle: WidgetStatePropertyAll(AppTextStyles.navLabel),
    iconTheme: WidgetStatePropertyAll(IconThemeData(color: AppColors.ink3, size: 24)),
    height: 70,
    animationDuration: AppConstants.shortAnimationDuration,
  );

  static const TabBarTheme _tabBarTheme = TabBarTheme(
    labelStyle: AppTextStyles.labelMedium,
    unselectedLabelStyle: AppTextStyles.labelMedium,
    labelColor: AppColors.navy,
    unselectedLabelColor: AppColors.ink3,
    indicator: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: AppColors.navy, width: 3),
      ),
    ),
    indicatorSize: TabBarIndicatorSize.label,
    dividerColor: Colors.transparent,
    overlayColor: WidgetStatePropertyAll(AppColors.goldBg),
    splashFactory: NoSplash.splashFactory,
  );

  static const ChipThemeData _chipTheme = ChipThemeData(
    backgroundColor: AppColors.surface,
    disabledColor: AppColors.line,
    selectedColor: AppColors.navy,
    secondarySelectedColor: AppColors.goldBg,
    padding: EdgeInsets.symmetric(horizontal: 13, vertical: 7),
    labelStyle: AppTextStyles.bodySmall,
    secondaryLabelStyle: AppTextStyles.labelSmall,
    brightness: Brightness.light,
    elevation: 0,
    pressElevation: 0,
    shape: StadiumBorder(
      side: BorderSide(color: AppColors.line, width: 1),
    ),
    showCheckmark: false,
    checkmarkColor: AppColors.white,
  );

  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: AppColors.line,
    thickness: 1,
    space: 1,
    indent: 0,
    endIndent: 0,
  );

  static const DialogThemeData _dialogTheme = DialogThemeData(
    elevation: 24,
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppConstants.largeBorderRadius)),
    ),
    titleTextStyle: AppTextStyles.headlineMedium,
    contentTextStyle: AppTextStyles.bodyMedium,
    alignment: Alignment.center,
  );

  static const BottomSheetThemeData _bottomSheetTheme = BottomSheetThemeData(
    elevation: 24,
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppConstants.largeBorderRadius),
      ),
    ),
    modalBarrierColor: AppColors.overlayDark,
    constraints: BoxConstraints(minWidth: double.infinity),
  );

  static const SnackBarThemeData _snackBarTheme = SnackBarThemeData(
    elevation: 8,
    backgroundColor: AppColors.navy,
    contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppConstants.defaultBorderRadius)),
    ),
    behavior: SnackBarBehavior.floating,
    actionTextColor: AppColors.gold,
    showCloseIcon: true,
    closeIconColor: AppColors.white,
  );

  static const FloatingActionButtonThemeData _fabTheme = FloatingActionButtonThemeData(
    elevation: 8,
    backgroundColor: AppColors.gold,
    foregroundColor: AppColors.navy,
    disabledBackgroundColor: AppColors.line,
    disabledForegroundColor: AppColors.ink3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppConstants.defaultBorderRadius)),
    ),
    extendedPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    extendedTextStyle: AppTextStyles.labelLarge.copyWith(color: AppColors.navy),
    extendedIconLabelSpacing: 8,
  );

  static const ProgressIndicatorThemeData _progressIndicatorTheme = ProgressIndicatorThemeData(
    color: AppColors.gold,
    linearTrackColor: AppColors.line,
    circularTrackColor: AppColors.line,
    refreshBackgroundColor: AppColors.goldBg,
  );

  static const CheckboxThemeData _checkboxTheme = CheckboxThemeData(
    fillColor: WidgetStatePropertyAll(AppColors.navy),
    checkColor: WidgetStatePropertyAll(AppColors.white),
    side: BorderSide(color: AppColors.line, width: 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
  );

  static const RadioThemeData _radioTheme = RadioThemeData(
    fillColor: WidgetStatePropertyAll(AppColors.navy),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
  );

  static const SwitchThemeData _switchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.navy;
      if (states.contains(WidgetState.disabled)) return AppColors.ink3;
      return AppColors.white;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.gold;
      if (states.contains(WidgetState.disabled)) return AppColors.line;
      return AppColors.line;
    }),
    trackOutlineColor: WidgetStatePropertyAll(AppColors.line),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  static const SliderThemeData _sliderTheme = SliderThemeData(
    activeTrackColor: AppColors.navy,
    inactiveTrackColor: AppColors.line,
    thumbColor: AppColors.navy,
    overlayColor: AppColors.goldBg,
    valueIndicatorColor: AppColors.navy,
    valueIndicatorTextStyle: AppTextStyles.caption.copyWith(color: AppColors.white),
    trackHeight: 6,
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
    overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
  );

  static const TooltipThemeData _tooltipTheme = TooltipThemeData(
    decoration: BoxDecoration(
      color: AppColors.navy,
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    textStyle: AppTextStyles.caption.copyWith(color: AppColors.white),
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    verticalOffset: 8,
    preferBelow: false,
  );
}

extension ThemeExtension on BuildContext {
  AppTextStyles get textStyles => AppTextStyles;
  AppColors get colors => AppColors;
}