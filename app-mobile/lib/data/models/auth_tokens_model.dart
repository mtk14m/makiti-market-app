import '../../domain/entities/auth_tokens.dart';

class AuthTokensModel extends AuthTokens {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
    required super.tokenType,
    required super.userId,
    required super.role,
    required super.phoneNumber,
    required super.isNewUser,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
      userId: json['user_id'] as String,
      role: (json['role'] ?? json['user_type'] ?? 'buyer_seller') as String,
      phoneNumber: json['phone_number'] as String,
      isNewUser: json['is_new_user'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'user_id': userId,
      'role': role,
      'phone_number': phoneNumber,
      'is_new_user': isNewUser,
    };
  }
}






