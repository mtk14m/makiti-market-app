import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Profile',
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                            Icons.person,
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
                            child: const Icon(
                              Icons.camera_alt,
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
                      'John Doe',
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    // Email
                    Text(
                      'john.doe@example.com',
                      style: AppTextStyles.bodySecondary.copyWith(
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    // Edit Profile Button
                    OutlinedButton(
                      onPressed: () {
                        // TODO: Navigate to edit profile
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
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: '+221 77 123 45 67',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date of Birth',
                      value: 'January 15, 1990',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildInfoRow(
                      icon: Icons.transgender_outlined,
                      label: 'Gender',
                      value: 'Male',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

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
        ),
      ),
    );
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

