import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../bloc/auth/auth_bloc.dart';
import 'otp_verification_page.dart';

class UnifiedPhonePage extends StatefulWidget {
  const UnifiedPhonePage({super.key});

  @override
  State<UnifiedPhonePage> createState() => _UnifiedPhonePageState();
}

class _UnifiedPhonePageState extends State<UnifiedPhonePage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _normalizePhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!cleaned.startsWith('+')) {
      if (cleaned.startsWith('221')) {
        cleaned = '+$cleaned';
      } else if (cleaned.startsWith('0')) {
        cleaned = '+221${cleaned.substring(1)}';
      } else {
        cleaned = '+221$cleaned';
      }
    }
    return cleaned;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final phoneNumber = _normalizePhoneNumber(_phoneController.text);
      context.read<AuthBloc>().add(
            AuthPhoneSubmitted(
              phoneNumber: phoneNumber,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Text(
          'Connexion',
          style: AppTextStyles.h3,
        ),
      ),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthOTPSent) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const OTPVerificationPage(),
                ),
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthPhoneSubmitting;

              return SingleChildScrollView(
                padding: AppSpacing.paddingXL,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppSpacing.xl * 2),
                      Text(
                        'Bienvenue sur Makiti',
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'Entrez votre numéro de téléphone pour continuer',
                        style: AppTextStyles.bodySecondary.copyWith(fontSize: 16),
                      ),
                      SizedBox(height: AppSpacing.xl * 2),

                      // Numéro de téléphone
                      Text(
                        'Numéro de téléphone',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-\(\)]')),
                        ],
                        decoration: InputDecoration(
                          hintText: '+221 77 123 45 67',
                          prefixIcon: Icon(
                            PhosphorIcons.phone(),
                            color: AppColors.textSecondary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: AppColors.greyBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: AppColors.greyBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submitForm(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez entrer votre numéro de téléphone';
                          }
                          final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                          if (cleaned.length < 8) {
                            return 'Numéro de téléphone invalide';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.xl * 2),

                      // Bouton continuer
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.textOnPrimary,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Continuer',
                                  style: AppTextStyles.cta.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}


