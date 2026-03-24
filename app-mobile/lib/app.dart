import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bloc/products/products_bloc.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/pages/auth/auth_wrapper.dart';
import 'presentation/pages/auth/auth_landing_page.dart';
import 'presentation/pages/auth/otp_verification_page.dart';
import 'presentation/pages/auth/register_page.dart';

/// Clé globale pour le Navigator racine (déconnexion, redirections)
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class MakitiApp extends StatelessWidget {
  const MakitiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => ProductsBloc()),
      ],
      child: MaterialApp(
        navigatorKey: rootNavigatorKey,
        title: 'Makiti',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        locale: const Locale('fr', 'FR'),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr', 'FR'),
          Locale('en', 'US'),
        ],
        home: const AuthWrapper(),
        routes: {
          '/auth/landing': (context) => const AuthLandingPage(),
          '/auth/otp': (context) => const OTPVerificationPage(),
          '/auth/register': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
            return RegisterPage(
              phoneNumber: args?['phoneNumber'] ?? '',
            );
          },
        },
      ),
    );
  }
}
