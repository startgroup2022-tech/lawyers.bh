import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'models/app_appearance.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

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
/// The image and opacity are painted per-screen by [AppBackground].
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
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const SplashScreen(),
    );
  }
}
