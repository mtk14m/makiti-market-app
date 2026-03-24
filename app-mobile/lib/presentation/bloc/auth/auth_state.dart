part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

/// State: Checking existing session
class AuthCheckingSession extends AuthState {}

/// State: Phone number is being submitted
class AuthPhoneSubmitting extends AuthState {
  final String phoneNumber;

  const AuthPhoneSubmitting({
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [phoneNumber];
}

/// State: OTP has been sent
class AuthOTPSent extends AuthState {
  final String phoneNumber;
  final String otpCode;

  const AuthOTPSent({
    required this.phoneNumber,
    required this.otpCode,
  });

  @override
  List<Object?> get props => [phoneNumber, otpCode];
}

/// State: OTP is being verified
class AuthOTPVerifying extends AuthState {
  final String phoneNumber;

  const AuthOTPVerifying({
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [phoneNumber];
}

/// State: OTP verified - user exists, needs login
class AuthOTPVerifiedUserExists extends AuthState {
  final String phoneNumber;
  final String role;

  const AuthOTPVerifiedUserExists({
    required this.phoneNumber,
    required this.role,
  });

  @override
  List<Object?> get props => [phoneNumber, role];
}

/// State: OTP verified - new user, needs registration
class AuthOTPVerifiedNewUser extends AuthState {
  final String phoneNumber;

  const AuthOTPVerifiedNewUser({
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [phoneNumber];
}

/// State: Registration is being processed
class AuthRegistering extends AuthState {
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String role;

  const AuthRegistering({
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  @override
  List<Object?> get props => [phoneNumber, firstName, lastName, role];
}

/// State: Login is being processed
class AuthLoggingIn extends AuthState {
  final String phoneNumber;

  const AuthLoggingIn({
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [phoneNumber];
}

/// State: User is authenticated
class AuthAuthenticated extends AuthState {
  final AuthTokens tokens;
  final User? user;

  const AuthAuthenticated(this.tokens, {this.user});

  @override
  List<Object?> get props => [tokens, user];
}

/// State: Additional info is being submitted
class AuthAdditionalInfoSubmitting extends AuthState {
  final AuthTokens tokens;

  const AuthAdditionalInfoSubmitting(this.tokens);

  @override
  List<Object?> get props => [tokens];
}

/// State: Profile is being loaded
class AuthProfileLoading extends AuthState {
  final AuthTokens tokens;

  const AuthProfileLoading(this.tokens);

  @override
  List<Object?> get props => [tokens];
}

/// State: Error occurred
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
