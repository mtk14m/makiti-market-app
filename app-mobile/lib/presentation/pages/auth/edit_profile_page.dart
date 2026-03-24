import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/animated_button.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedGender;
  String _selectedCountry = 'SN';
  DateTime? _dateOfBirth;

  final Map<String, String> _countryNames = {
    'SN': 'Sénégal',
    'ML': 'Mali',
    'CI': 'Côte d\'Ivoire',
    'BF': 'Burkina Faso',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  void _loadInitialData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.user != null) {
      final user = authState.user!;
      setState(() {
        _firstNameController.text = user.firstName ?? '';
        _lastNameController.text = user.lastName ?? '';
        _emailController.text = user.email ?? '';
        _cityController.text = user.city ?? '';
        _addressController.text = user.address ?? '';
        _selectedGender = user.gender;
        _selectedCountry = user.country ?? 'SN';
        _dateOfBirth = user.dateOfBirth;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthProfileUpdateSubmitted(
            firstName: _firstNameController.text.trim().isNotEmpty
                ? _firstNameController.text.trim()
                : null,
            lastName: _lastNameController.text.trim().isNotEmpty
                ? _lastNameController.text.trim()
                : null,
            email: _emailController.text.trim().isNotEmpty
                ? _emailController.text.trim()
                : null,
            dateOfBirth: _dateOfBirth,
            gender: _selectedGender,
            country: _selectedCountry,
            city: _cityController.text.trim().isNotEmpty
                ? _cityController.text.trim()
                : null,
            address: _addressController.text.trim().isNotEmpty
                ? _addressController.text.trim()
                : null,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            PhosphorIcons.arrowLeft(),
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Modifier le profil',
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) =>
            prev is AuthProfileLoading &&
            (curr is AuthAuthenticated || curr is AuthError),
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil mis à jour'),
                backgroundColor: AppColors.primary,
              ),
            );
            Navigator.of(context).pop();
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
          builder: (context, authState) {
            final isLoading = authState is AuthProfileLoading;

            return SingleChildScrollView(
              padding: AppSpacing.paddingHorizontalLG,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: AppSpacing.lg),

                    // Prénom
                    _buildLabel('Prénom'),
                    TextFormField(
                      controller: _firstNameController,
                      enabled: !isLoading,
                      decoration: _inputDecoration(),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Nom
                    _buildLabel('Nom'),
                    TextFormField(
                      controller: _lastNameController,
                      enabled: !isLoading,
                      decoration: _inputDecoration(),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Email
                    _buildLabel('Email'),
                    TextFormField(
                      controller: _emailController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration(hint: 'email@exemple.com'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(v)) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Date de naissance et Genre
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Date de naissance'),
                              InkWell(
                                onTap: isLoading ? null : _selectDateOfBirth,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.greyBorder),
                                    borderRadius:
                                        BorderRadius.circular(AppSpacing.sm),
                                  ),
                                  child: Row(
                                      children: [
                                        Icon(
                                        PhosphorIcons.calendarBlank(),
                                        size: 18,
                                        color: AppColors.textSecondary,
                                      ),
                                      SizedBox(width: AppSpacing.xs),
                                      Expanded(
                                        child: Text(
                                          _dateOfBirth != null
                                              ? DateFormat('dd/MM/yyyy')
                                                  .format(_dateOfBirth!)
                                              : 'JJ/MM/AAAA',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: _dateOfBirth != null
                                                ? AppColors.textPrimary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Genre'),
                              DropdownButtonFormField<String>(
                                value: _selectedGender,
                                decoration: _inputDecoration(),
                                hint: const Text('Sélectionner'),
                                items: ['male', 'female'].map((g) {
                                  return DropdownMenuItem(
                                    value: g,
                                    child: Text(g == 'male' ? 'Homme' : 'Femme'),
                                  );
                                }).toList(),
                                onChanged: isLoading
                                    ? null
                                    : (v) => setState(() => _selectedGender = v),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Pays
                    _buildLabel('Pays'),
                    DropdownButtonFormField<String>(
                      value: _selectedCountry,
                      decoration: _inputDecoration(),
                      items: _countryNames.entries
                          .map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ))
                          .toList(),
                      onChanged: isLoading
                          ? null
                          : (v) => setState(() => _selectedCountry = v ?? 'SN'),
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Ville
                    _buildLabel('Ville'),
                    TextFormField(
                      controller: _cityController,
                      enabled: !isLoading,
                      decoration: _inputDecoration(
                        hint: 'Ex: Dakar, Abidjan, Bamako',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Obligatoire' : null,
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Adresse
                    _buildLabel('Adresse'),
                    TextFormField(
                      controller: _addressController,
                      enabled: !isLoading,
                      maxLines: 2,
                      decoration: _inputDecoration(hint: 'Adresse complète'),
                    ),
                    SizedBox(height: AppSpacing.xl),

                    AnimatedButton(
                      label: isLoading ? 'Enregistrement...' : 'Enregistrer',
                      onPressed: isLoading ? null : _submitForm,
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      icon: PhosphorIcons.floppyDisk(),
                    ),
                    SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs / 2),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
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
    );
  }
}
