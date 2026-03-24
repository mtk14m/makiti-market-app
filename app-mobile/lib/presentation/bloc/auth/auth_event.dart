part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event: User submits phone number (unified for login/register)
class AuthPhoneSubmitted extends AuthEvent {
  final String phoneNumber;

  const AuthPhoneSubmitted({
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [phoneNumber];
}

/// Event: User submits OTP code (unified - checks if user exists)
class AuthOTPSubmitted extends AuthEvent {
  final String otpCode;
  final String phoneNumber;

  const AuthOTPSubmitted({
    required this.otpCode,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [otpCode, phoneNumber];
}

/// Event: Resend OTP code
class AuthOTPResent extends AuthEvent {
  final String phoneNumber;

  const AuthOTPResent({
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [phoneNumber];
}

/// Event: Login existing user after OTP verification
class AuthLoginSubmitted extends AuthEvent {
  final String phoneNumber;
  final String otpCode;

  const AuthLoginSubmitted({
    required this.phoneNumber,
    required this.otpCode,
  });

  @override
  List<Object?> get props => [phoneNumber, otpCode];
}

/// Event: Complete registration with name and role
class AuthRegisterSubmitted extends AuthEvent {
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String role;
  final String? email;
  final DateTime? dateOfBirth;
  final String? gender;
  final String country;
  final String city;
  final String? address;
  final String? language;

  const AuthRegisterSubmitted({
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    this.role = 'buyer_seller',
    this.email,
    this.dateOfBirth,
    this.gender,
    required this.country,
    required this.city,
    this.address,
    this.language,
  });

  @override
  List<Object?> get props => [
    phoneNumber,
    firstName,
    lastName,
    role,
    email,
    dateOfBirth,
    gender,
    country,
    city,
    address,
    language,
  ];
}

/// Event: Submit additional info (optional)
class AuthAdditionalInfoSubmitted extends AuthEvent {
  final Map<String, dynamic> additionalInfo;

  const AuthAdditionalInfoSubmitted(this.additionalInfo);

  @override
  List<Object?> get props => [additionalInfo];
}

/// Event: User logs out
class AuthLoggedOut extends AuthEvent {
  const AuthLoggedOut();
}

/// Event: Check existing session
class AuthCheckSession extends AuthEvent {
  const AuthCheckSession();
}

/// Event: Load user profile
class AuthLoadProfile extends AuthEvent {
  const AuthLoadProfile();
}

/// Event: Update user profile
class AuthProfileUpdateSubmitted extends AuthEvent {
  final String? firstName;
  final String? lastName;
  final String? email;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? country;
  final String? city;
  final String? address;

  const AuthProfileUpdateSubmitted({
    this.firstName,
    this.lastName,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.country,
    this.city,
    this.address,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        dateOfBirth,
        gender,
        country,
        city,
        address,
      ];
}
