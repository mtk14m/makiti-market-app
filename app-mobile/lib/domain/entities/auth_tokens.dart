import 'package:equatable/equatable.dart';

class AuthTokens extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String userId;
  final String role;
  final String phoneNumber;
  final bool isNewUser;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.userId,
    required this.role,
    required this.phoneNumber,
    required this.isNewUser,
  });

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        tokenType,
        userId,
        role,
        phoneNumber,
        isNewUser,
      ];
}






