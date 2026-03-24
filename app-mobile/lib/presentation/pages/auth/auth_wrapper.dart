import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../bloc/auth/auth_bloc.dart';
import 'auth_landing_page.dart';
import '../main_navigation_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _hasCheckedSession = false;

  @override
  void initState() {
    super.initState();
    // Vérifier la session au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasCheckedSession) {
        _hasCheckedSession = true;
        context.read<AuthBloc>().add(const AuthCheckSession());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        // Détecter toute transition vers AuthInitial (déconnexion),
        // quel que soit l'état précédent.
        return previous is! AuthInitial && current is AuthInitial;
      },
      listener: (context, state) {
        // Redirection vers la page de connexion lors de la déconnexion
        if (state is AuthInitial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final navigator = rootNavigatorKey.currentState;
            if (navigator != null && mounted) {
              navigator.pushAndRemoveUntil(
                AppAnimations.fadeRoute(
                  const AuthLandingPage(),
                ),
                (route) => false,
              );
            }
          });
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthCheckingSession) {
            return Scaffold(
              backgroundColor: AppColors.backgroundLight,
              body: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            );
          } else if (state is AuthAuthenticated) {
            return const MainNavigationPage();
          } else {
            return const AuthLandingPage();
          }
        },
      ),
    );
  }
}
