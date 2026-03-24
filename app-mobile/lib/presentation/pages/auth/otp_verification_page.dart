import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_animations.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../main_navigation_page.dart';
import 'auth_landing_page.dart';
import 'register_page.dart';

class OTPVerificationPage extends StatefulWidget {
  const OTPVerificationPage({super.key});

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );
  String? _phoneNumber;
  String? _otpCode; // Pour affichage en développement
  String? _submittedOtpCode; // Code OTP soumis pour le login automatique
  StreamSubscription<AuthState>? _authSubscription;

  void _prefillOtpCode(String otpCode) {
    if (otpCode.length != 6) return;
    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].text = otpCode[i];
    }
  }

  @override
  void initState() {
    super.initState();
    _authSubscription = context.read<AuthBloc>().stream.listen((state) {
      if (state is AuthOTPSent && mounted) {
        setState(() {
          _phoneNumber = state.phoneNumber;
          _otpCode = state.otpCode;
        });
        _prefillOtpCode(state.otpCode);
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onOTPChanged(int index, String value) {
    if (value.length == 1) {
      // Déplacer le focus vers le champ suivant
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Dernier champ, soumettre automatiquement
        _submitOTP();
      }
    } else if (value.isEmpty && index > 0) {
      // Retour au champ précédent si on supprime
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _submitOTP() {
    final otpCode = _controllers.map((c) => c.text).join();
    // Vérifier que le code OTP contient exactement 6 chiffres
    if (otpCode.length == 6 && 
        RegExp(r'^\d{6}$').hasMatch(otpCode) &&
        _phoneNumber != null) {
      // Stocker le code OTP pour le login automatique si nécessaire
      _submittedOtpCode = otpCode;
      context.read<AuthBloc>().add(
            AuthOTPSubmitted(
              otpCode: otpCode,
              phoneNumber: _phoneNumber!,
            ),
          );
    } else if (otpCode.length == 6 && !RegExp(r'^\d{6}$').hasMatch(otpCode)) {
      // Afficher une erreur si le code contient des caractères non numériques
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le code OTP doit contenir uniquement des chiffres'),
          backgroundColor: Colors.red,
        ),
      );
      // Réinitialiser les champs
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  void _resendOTP() {
    if (_phoneNumber != null) {
      // Réinitialiser les champs OTP
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
      
      context.read<AuthBloc>().add(
            AuthOTPResent(
              phoneNumber: _phoneNumber!,
            ),
          );
      
      // Afficher un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nouveau code OTP envoyé'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Empêcher un pop sur une pile vide et revenir proprement à la landing
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AuthLandingPage(),
          ),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundLight,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              PhosphorIcons.arrowLeft(),
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const AuthLandingPage(),
                ),
              );
            },
          ),
          title: Text(
            'Vérification',
            style: AppTextStyles.h2.copyWith(color: AppColors.primaryDark),
          ),
        ),
        body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthOTPVerifiedUserExists) {
              final otpCode = _submittedOtpCode ?? _controllers.map((c) => c.text).join();
              if (otpCode.isNotEmpty && otpCode.length == 6) {
                context.read<AuthBloc>().add(
                      AuthLoginSubmitted(
                        phoneNumber: state.phoneNumber,
                        otpCode: otpCode,
                      ),
                    );
              } else {
                // Si le code n'est pas disponible, afficher une erreur
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur: Code OTP non disponible'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } else if (state is AuthOTPVerifiedNewUser) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => RegisterPage(
                    phoneNumber: state.phoneNumber,
                  ),
                ),
              );
            } else if (state is AuthAuthenticated) {
              Navigator.of(context).pushAndRemoveUntil(
                AppAnimations.fadeRoute(
                  const MainNavigationPage(),
                ),
                (route) => false,
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
              // Réinitialiser les champs OTP en cas d'erreur
              for (var controller in _controllers) {
                controller.clear();
              }
              _focusNodes[0].requestFocus();
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              // Récupérer les infos depuis l'état et mettre à jour les variables
              String? currentOtpCode = _otpCode;
              String? currentPhoneNumber = _phoneNumber;
              
              if (state is AuthOTPSent) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _phoneNumber = state.phoneNumber;
                      _otpCode = state.otpCode;
                    });
                    _prefillOtpCode(state.otpCode);
                  }
                });
                currentOtpCode = state.otpCode;
                currentPhoneNumber = state.phoneNumber;
              }

              final isVerifying = state is AuthOTPVerifying || state is AuthLoggingIn;

              return Column(
                children: [
                  // Espace flexible pour pousser le contenu en bas
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo Makiti
                          Text(
                            'Makiti',
                            style: AppTextStyles.h2.copyWith(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: AppSpacing.lg),
                          Text(
                            'Code de vérification',
                            style: AppTextStyles.h2.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs / 2),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                            child: Text(
                              'Nous avons envoyé un code à 6 chiffres au\n${currentPhoneNumber ?? _phoneNumber ?? "..."}',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
                            ),
                          ),
                          
                          // Afficher le code OTP en développement
                          if (currentOtpCode != null) ...[
                            SizedBox(height: AppSpacing.md),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                              child: Container(
                                padding: AppSpacing.paddingSM,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      PhosphorIcons.info(),
                                      size: 16,
                                      color: AppColors.primaryDark,
                                    ),
                                    SizedBox(width: AppSpacing.xs),
                                    Text(
                                      'Code OTP (dev): $currentOtpCode',
                                      style: AppTextStyles.bodySecondary.copyWith(
                                        fontSize: 12,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: AppSpacing.xs),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                              child: Text(
                                'Mode developpement: aucun SMS reel n\'est envoye pour le moment. Utilise le code affiche ci-dessus.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodySecondary.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  // Champs OTP et boutons en bas
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        // Cases OTP
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            6,
                            (index) => SizedBox(
                              width: 45,
                              height: 55,
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: AppTextStyles.h2.copyWith(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                                    borderSide: BorderSide(color: AppColors.greyBorder),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                                    borderSide: BorderSide(color: AppColors.greyBorder),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.surfaceLight,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (value) => _onOTPChanged(index, value),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: AppSpacing.lg),

                        // Bouton vérifier
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isVerifying ? null : _submitOTP,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textOnPrimary,
                              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSpacing.sm),
                              ),
                              elevation: 0,
                            ),
                            child: isVerifying
                                ? SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.textOnPrimary,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Vérifier',
                                    style: AppTextStyles.cta.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: AppSpacing.md),

                        // Bouton renvoyer le code
                        Center(
                          child: TextButton(
                            onPressed: isVerifying ? null : _resendOTP,
                            child: Text(
                              'Renvoyer le code',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 14,
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        ),
      ),
    );
  }
}
