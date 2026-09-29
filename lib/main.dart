import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'models/app_appearance.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/app_background.dart';

void main() {
  runApp(const LawyersBhApp());
}

class LawyersBhApp extends StatelessWidget {
  const LawyersBhApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const _ThemedApp(),
    );
  }
}

/// Rebuilds the app theme when the admin changes the flat background colour, so
/// screens that rely on the scaffold colour follow it without extra plumbing.
/// The image, overlay and decorative layers are painted globally by
/// [AppBackgroundScope], which sits **behind every route** (see `builder`
/// below), so the background is one layer under the whole app rather than a
/// per-screen copy.
class _ThemedApp extends StatelessWidget {
  const _ThemedApp();

  @override
  Widget build(BuildContext context) {
    final background = context.select<AppState, AppAppearance>((s) => s.appAppearance);
    return MaterialApp(
      title: 'محامون البحرين',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(backgroundColor: background.backgroundColor),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // One global background behind the entire navigator: every screen —
      // home, login, directory, profile, booking, appointments, dashboards and
      // dialogs — renders on top of the same layered background. The background
      // widgets ignore pointers, so navigation, taps and gestures reach the app
      // content above them.
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: AppBackgroundScope(
          child: child ?? const SizedBox.shrink(),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
