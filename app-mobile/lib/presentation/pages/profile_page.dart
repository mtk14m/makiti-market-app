import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../bloc/auth/auth_bloc.dart';
import 'auth/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Charger le profil au démarrage si l'utilisateur est authentifié
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated && authState.user == null) {
        context.read<AuthBloc>().add(const AuthLoadProfile());
      }
    });
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
          'Profile',
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(
              PhosphorIcons.signOut(),
              color: Colors.red,
            ),
            tooltip: 'Déconnexion',
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLoggedOut());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            // Recharger le profil si l'utilisateur est authentifié mais sans profil
            if (state is AuthAuthenticated && state.user == null) {
              context.read<AuthBloc>().add(const AuthLoadProfile());
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is! AuthAuthenticated) {
                return Center(
                  child: Text(
                    'Non connecté',
                    style: AppTextStyles.body,
                  ),
                );
              }

              final user = authState.user;
            final displayName = user?.displayName ?? 'User';
            final email = user?.email ?? '';
            final phoneNumber = user?.phoneNumber ?? authState.tokens.phoneNumber;
            final dateOfBirth = user?.dateOfBirth;
            final gender = user?.gender;
            final country = user?.country;
            final city = user?.city;
            final address = user?.address;
            final locationLabel = user?.locationLabel;
            final profileCompletion = user?.profileCompletion ?? 0;
            final missingProfileFields = user?.missingProfileFields ?? const <String>[];
            final profileSections = user?.profileSections ?? const [];

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Header Profile Section
                  Container(
                    width: double.infinity,
                    padding: AppSpacing.paddingXL,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.primary.withOpacity(0.2),
                              child: Icon(
                                PhosphorIcons.user(),
                                size: 50,
                                color: AppColors.primary,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.surfaceLight,
                                    width: 3,
                                  ),
                                ),
                                child: Icon(
                                  PhosphorIcons.camera(),
                                  size: 16,
                                  color: AppColors.textOnPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.md),
                        // Name
                        Text(
                          displayName,
                          style: AppTextStyles.h2.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        // Email or Phone
                        Text(
                          email.isNotEmpty ? email : phoneNumber,
                          style: AppTextStyles.bodySecondary.copyWith(
                            fontSize: 14,
                          ),
                        ),
                        if (locationLabel != null && locationLabel.isNotEmpty) ...[
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            locationLabel,
                            style: AppTextStyles.bodySecondary.copyWith(
                              fontSize: 13,
                            ),
                          ),
                        ],
                    SizedBox(height: AppSpacing.md),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Profil complet a $profileCompletion%',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primaryDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    // Edit Profile Button
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EditProfilePage(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                      child: Text(
                        'Edit Profile',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.lg),

              // Profile Information Section
              Container(
                margin: AppSpacing.paddingHorizontalLG,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: PhosphorIcons.phone(),
                      label: 'Téléphone',
                      value: phoneNumber,
                      onTap: () {},
                    ),
                    if (dateOfBirth != null) ...[
                      _buildDivider(),
                      _buildInfoRow(
                        icon: PhosphorIcons.calendarBlank(),
                        label: 'Date de naissance',
                        value: DateFormat('dd MMMM yyyy', 'fr_FR').format(dateOfBirth),
                        onTap: () {},
                      ),
                    ],
                    if (gender == 'male' || gender == 'female') ...[
                      _buildDivider(),
                      _buildInfoRow(
                        icon: PhosphorIcons.genderIntersex(),
                        label: 'Genre',
                        value: gender == 'male' ? 'Homme' : 'Femme',
                        onTap: () {},
                      ),
                    ],
                    if (country != null) ...[
                      _buildDivider(),
                      _buildInfoRow(
                        icon: PhosphorIcons.flag(),
                        label: 'Pays',
                        value: country,
                        onTap: () {},
                      ),
                    ],
                    if (city != null && city.isNotEmpty) ...[
                      _buildDivider(),
                      _buildInfoRow(
                        icon: PhosphorIcons.buildings(),
                        label: 'Ville',
                        value: city,
                        onTap: () {},
                      ),
                    ],
                    if (address != null && address.isNotEmpty) ...[
                      _buildDivider(),
                      _buildInfoRow(
                        icon: PhosphorIcons.mapPin(),
                        label: 'Adresse',
                        value: address,
                        onTap: () {},
                      ),
                    ],
                  ],
                ),
              ),

              if (missingProfileFields.isNotEmpty) ...[
                SizedBox(height: AppSpacing.lg),
                Container(
                  margin: AppSpacing.paddingHorizontalLG,
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations a completer',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        missingProfileFields
                            .map(_formatMissingFieldLabel)
                            .join(', '),
                        style: AppTextStyles.bodySecondary,
                      ),
                    ],
                  ),
                ),
              ],

              if (profileSections.isNotEmpty) ...[
                SizedBox(height: AppSpacing.lg),
                Container(
                  margin: AppSpacing.paddingHorizontalLG,
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Etat du profil',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      ...profileSections.map(
                        (section) => Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      section.label,
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: AppSpacing.xs),
                                    Text(
                                      '${section.filledFields}/${section.totalFields} champs completes',
                                      style: AppTextStyles.bodySecondary.copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: section.isComplete
                                      ? Colors.green.withOpacity(0.12)
                                      : AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${section.completion}%',
                                  style: AppTextStyles.body.copyWith(
                                    color: section.isComplete
                                        ? Colors.green.shade700
                                        : AppColors.primaryDark,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
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
              ],

              SizedBox(height: AppSpacing.lg),

              // Preferences Section
              Container(
                margin: AppSpacing.paddingHorizontalLG,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: AppSpacing.paddingMD,
                      child: Text(
                        'Preferences',
                        style: AppTextStyles.sectionTitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildSwitchRow(
                      icon: Icons.notifications_outlined,
                      label: 'Push Notifications',
                      value: true,
                      onChanged: (value) {},
                    ),
                    _buildDivider(),
                    _buildSwitchRow(
                      icon: Icons.email_outlined,
                      label: 'Email Notifications',
                      value: false,
                      onChanged: (value) {},
                    ),
                    _buildDivider(),
                    _buildSwitchRow(
                      icon: Icons.language_outlined,
                      label: 'Language',
                      value: false,
                      subtitle: 'English',
                      onChanged: (value) {},
                    ),
                  ],
                ),
              ),

                  SizedBox(height: AppSpacing.xxl),
                ],
              ),
            );
            },
          ),
        ),
      ),
    );
  }

  String _formatMissingFieldLabel(String field) {
    switch (field) {
      case 'first_name':
        return 'prenom';
      case 'last_name':
        return 'nom';
      case 'country':
        return 'pays';
      case 'city':
        return 'ville';
      case 'address':
        return 'adresse';
      case 'email':
        return 'email';
      case 'gender':
        return 'genre';
      case 'date_of_birth':
        return 'date de naissance';
      default:
        return field;
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodySecondary.copyWith(
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs / 2),
                    Text(
                      value,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String label,
    required bool value,
    String? subtitle,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: AppSpacing.paddingMD,
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppSpacing.xs / 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySecondary.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.greyBorder,
      indent: 56,
    );
  }
}
