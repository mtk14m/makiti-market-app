import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/home_page.dart';

void main() {
  runApp(const MakitiApp());
}

class MakitiApp extends StatelessWidget {
  const MakitiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Makiti Market',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      locale: const Locale('fr', 'FR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      home: const HomePage(),
    );
  }
}