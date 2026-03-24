import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../main_navigation_page.dart';

class RegisterPage extends StatefulWidget {
  final String phoneNumber;

  const RegisterPage({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _acceptMarketing = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu dois accepter les conditions.')),
      );
      return;
    }

    context.read<AuthBloc>().add(
          AuthRegisterSubmitted(
            phoneNumber: widget.phoneNumber,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim().isNotEmpty
                ? _emailController.text.trim()
                : null,
            dateOfBirth: null,
            gender: null,
            country: 'SN',
            city: _cityController.text.trim(),
            address: _addressController.text.trim().isNotEmpty
                ? _addressController.text.trim()
                : null,
            language: 'fr',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft()),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'S’inscrire',
          style: AppTextStyles.h3,
        ),
      ),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainNavigationPage()),
                (route) => false,
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isRegistering = state is AuthRegistering;

              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  children: [
                    const SizedBox(height: 8),
                    _LineField(
                      controller: _firstNameController,
                      hint: 'Nom d’utilisateur',
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 26),
                    _LineField(
                      controller: _emailController,
                      hint: 'Adresse email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 26),
                    _LineField(
                      controller: _cityController,
                      hint: 'Ville',
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 26),
                    _LineField(
                      controller: _addressController,
                      hint: 'Adresse (optionnel)',
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 42),
                    _ConsentRow(
                      value: _acceptMarketing,
                      onChanged: (value) =>
                          setState(() => _acceptMarketing = value ?? false),
                      child: Text(
                        'Je souhaite recevoir par email des offres personnalisées et les dernières mises à jour de Makiti.',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    _ConsentRow(
                      value: _acceptTerms,
                      onChanged: (value) =>
                          setState(() => _acceptTerms = value ?? false),
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(
                              text: 'En t’inscrivant, tu confirmes que tu acceptes les ',
                            ),
                            TextSpan(
                              text: 'Conditions et confidentialité de Makiti',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(
                              text: ', et que tu as au moins 18 ans.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    ElevatedButton(
                      onPressed: isRegistering ? null : _submitForm,
                      child: isRegistering
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white,
                                ),
                              ),
                            )
                          : const Text('S’inscrire'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LineField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;

  const _LineField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    required this.textInputAction,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
      style: AppTextStyles.body.copyWith(fontSize: 18),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(
          fontSize: 18,
          color: AppColors.textTertiary,
        ),
        filled: false,
        contentPadding: const EdgeInsets.only(bottom: 14),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 1.4),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.accentRed),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.accentRed),
        ),
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Widget child;

  const _ConsentRow({
    required this.value,
    required this.onChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.translate(
          offset: const Offset(-10, -8),
          child: Checkbox(
            value: value,
            onChanged: onChanged,
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
