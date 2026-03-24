import 'package:equatable/equatable.dart';

class UserProfileSection extends Equatable {
  final String key;
  final String label;
  final int completion;
  final bool isComplete;
  final int filledFields;
  final int totalFields;
  final List<String> missingFields;

  const UserProfileSection({
    required this.key,
    required this.label,
    required this.completion,
    required this.isComplete,
    required this.filledFields,
    required this.totalFields,
    required this.missingFields,
  });

  @override
  List<Object?> get props => [
        key,
        label,
        completion,
        isComplete,
        filledFields,
        totalFields,
        missingFields,
      ];
}

/// Entite User unifiee pour Makiti.
class User extends Equatable {
  final String id;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? email;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? country;
  final String? city;
  final String? address;
  final String? language;
  final String? locationLabel;
  final bool? isVerified;
  final bool? isActive;
  final bool? isSellerEnabled;
  final bool? isBuyerEnabled;
  final bool? isBoxOwnerEnabled;
  final String? role;
  final int? profileCompletion;
  final bool? isProfileComplete;
  final List<String>? missingProfileFields;
  final List<UserProfileSection>? profileSections;

  const User({
    required this.id,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.fullName,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.country,
    this.city,
    this.address,
    this.language,
    this.locationLabel,
    this.isVerified,
    this.isActive,
    this.isSellerEnabled,
    this.isBuyerEnabled,
    this.isBoxOwnerEnabled,
    this.role,
    this.profileCompletion,
    this.isProfileComplete,
    this.missingProfileFields,
    this.profileSections,
  });

  String get displayName {
    final combined = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    if (combined.isNotEmpty) return combined;
    if (fullName != null && fullName!.trim().isNotEmpty) return fullName!.trim();
    return phoneNumber;
  }

  @override
  List<Object?> get props => [
        id,
        phoneNumber,
        firstName,
        lastName,
        fullName,
        email,
        dateOfBirth,
        gender,
        country,
        city,
        address,
        language,
        locationLabel,
        isVerified,
        isActive,
        isSellerEnabled,
        isBuyerEnabled,
        isBoxOwnerEnabled,
        role,
        profileCompletion,
        isProfileComplete,
        missingProfileFields,
        profileSections,
      ];
}
