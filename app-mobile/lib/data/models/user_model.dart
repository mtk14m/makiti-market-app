import '../../domain/entities/user.dart';

class UserProfileSectionModel {
  final String key;
  final String label;
  final int completion;
  final bool isComplete;
  final int filledFields;
  final int totalFields;
  final List<String> missingFields;

  const UserProfileSectionModel({
    required this.key,
    required this.label,
    required this.completion,
    required this.isComplete,
    required this.filledFields,
    required this.totalFields,
    required this.missingFields,
  });

  factory UserProfileSectionModel.fromJson(Map<String, dynamic> json) {
    return UserProfileSectionModel(
      key: json['key'] as String,
      label: json['label'] as String,
      completion: json['completion'] as int? ?? 0,
      isComplete: json['is_complete'] as bool? ?? false,
      filledFields: json['filled_fields'] as int? ?? 0,
      totalFields: json['total_fields'] as int? ?? 0,
      missingFields: (json['missing_fields'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'completion': completion,
      'is_complete': isComplete,
      'filled_fields': filledFields,
      'total_fields': totalFields,
      'missing_fields': missingFields,
    };
  }

  UserProfileSection toEntity() {
    return UserProfileSection(
      key: key,
      label: label,
      completion: completion,
      isComplete: isComplete,
      filledFields: filledFields,
      totalFields: totalFields,
      missingFields: missingFields,
    );
  }
}

class UserModel {
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
  final List<UserProfileSectionModel>? profileSections;

  const UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime? dateOfBirth;
    final dob = json['date_of_birth'];
    if (dob != null) {
      if (dob is String) {
        dateOfBirth = DateTime.tryParse(dob);
      }
    }
    return UserModel(
      id: json['id'] as String,
      phoneNumber: json['phone_number'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      dateOfBirth: dateOfBirth,
      gender: json['gender'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      language: json['language'] as String?,
      locationLabel: json['location_label'] as String?,
      isVerified: json['is_verified'] as bool?,
      isActive: json['is_active'] as bool?,
      isSellerEnabled: json['is_seller_enabled'] as bool?,
      isBuyerEnabled: json['is_buyer_enabled'] as bool?,
      isBoxOwnerEnabled: json['is_box_owner_enabled'] as bool?,
      role: json['role'] as String?,
      profileCompletion: json['profile_completion'] as int?,
      isProfileComplete: json['is_profile_complete'] as bool?,
      missingProfileFields: (json['missing_profile_fields'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList(),
      profileSections: (json['profile_sections'] as List<dynamic>?)
          ?.map(
            (item) => UserProfileSectionModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'email': email,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
      'gender': gender,
      'country': country,
      'city': city,
      'address': address,
      'language': language,
      'location_label': locationLabel,
      'is_verified': isVerified,
      'is_active': isActive,
      'is_seller_enabled': isSellerEnabled,
      'is_buyer_enabled': isBuyerEnabled,
      'is_box_owner_enabled': isBoxOwnerEnabled,
      'role': role,
      'profile_completion': profileCompletion,
      'is_profile_complete': isProfileComplete,
      'missing_profile_fields': missingProfileFields,
      'profile_sections': profileSections?.map((item) => item.toJson()).toList(),
    };
  }

  User toEntity() {
    return User(
      id: id,
      phoneNumber: phoneNumber,
      firstName: firstName,
      lastName: lastName,
      fullName: fullName,
      email: email,
      dateOfBirth: dateOfBirth,
      gender: gender,
      country: country,
      city: city,
      address: address,
      language: language,
      locationLabel: locationLabel,
      isVerified: isVerified,
      isActive: isActive,
      isSellerEnabled: isSellerEnabled,
      isBuyerEnabled: isBuyerEnabled,
      isBoxOwnerEnabled: isBoxOwnerEnabled,
      role: role,
      profileCompletion: profileCompletion,
      isProfileComplete: isProfileComplete,
      missingProfileFields: missingProfileFields,
      profileSections: profileSections?.map((item) => item.toEntity()).toList(),
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      phoneNumber: user.phoneNumber,
      firstName: user.firstName,
      lastName: user.lastName,
      fullName: user.fullName,
      email: user.email,
      dateOfBirth: user.dateOfBirth,
      gender: user.gender,
      country: user.country,
      city: user.city,
      address: user.address,
      language: user.language,
      locationLabel: user.locationLabel,
      isVerified: user.isVerified,
      isActive: user.isActive,
      isSellerEnabled: user.isSellerEnabled,
      isBuyerEnabled: user.isBuyerEnabled,
      isBoxOwnerEnabled: user.isBoxOwnerEnabled,
      role: user.role,
      profileCompletion: user.profileCompletion,
      isProfileComplete: user.isProfileComplete,
      missingProfileFields: user.missingProfileFields,
      profileSections: user.profileSections
          ?.map(
            (item) => UserProfileSectionModel(
              key: item.key,
              label: item.label,
              completion: item.completion,
              isComplete: item.isComplete,
              filledFields: item.filledFields,
              totalFields: item.totalFields,
              missingFields: item.missingFields,
            ),
          )
          .toList(),
    );
  }
}
