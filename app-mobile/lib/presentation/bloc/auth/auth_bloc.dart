import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/services/auth_storage_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../domain/entities/auth_tokens.dart';
import '../../../domain/entities/user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final AuthStorageService _storageService;

  AuthBloc({
    AuthRepository? authRepository,
    AuthStorageService? storageService,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _storageService = storageService ?? AuthStorageService(),
        super(AuthCheckingSession()) {
    on<AuthPhoneSubmitted>(_onPhoneSubmitted);
    on<AuthOTPSubmitted>(_onOTPSubmitted);
    on<AuthOTPResent>(_onOTPResent);
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthRegisterSubmitted>(_onRegisterSubmitted);
    on<AuthAdditionalInfoSubmitted>(_onAdditionalInfoSubmitted);
    on<AuthLoggedOut>(_onLoggedOut);
    on<AuthCheckSession>(_onCheckSession);
    on<AuthLoadProfile>(_onLoadProfile);
    on<AuthProfileUpdateSubmitted>(_onProfileUpdateSubmitted);
  }

  Future<void> _onPhoneSubmitted(
    AuthPhoneSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthPhoneSubmitting(phoneNumber: event.phoneNumber));

    try {
      final otpCode = await _authRepository.sendOTP(
        phoneNumber: event.phoneNumber,
      );

      emit(AuthOTPSent(
        phoneNumber: event.phoneNumber,
        otpCode: otpCode,
      ));
    } catch (e) {
      emit(AuthError(_errorMessage(e)));
    }
  }

  Future<void> _onOTPSubmitted(
    AuthOTPSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthOTPVerifying(phoneNumber: event.phoneNumber));

    try {
      final result = await _authRepository.verifyOTP(
        phoneNumber: event.phoneNumber,
        otpCode: event.otpCode,
      );

      final userExists = result['user_exists'] as bool;
      final role = result['role'] as String?;

      if (userExists && role != null) {
        emit(AuthOTPVerifiedUserExists(
          phoneNumber: event.phoneNumber,
          role: role,
        ));
      } else {
        emit(AuthOTPVerifiedNewUser(
          phoneNumber: event.phoneNumber,
        ));
      }
    } catch (e) {
      emit(AuthError(_errorMessage(e)));
    }
  }

  Future<void> _onOTPResent(
    AuthOTPResent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final otpCode = await _authRepository.sendOTP(
        phoneNumber: event.phoneNumber,
      );

      emit(AuthOTPSent(
        phoneNumber: event.phoneNumber,
        otpCode: otpCode,
      ));
    } catch (e) {
      emit(AuthError(_errorMessage(e)));
    }
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoggingIn(phoneNumber: event.phoneNumber));

    try {
      final tokens = await _authRepository.login(
        phoneNumber: event.phoneNumber,
        otpCode: event.otpCode,
      );

      // Charger le profil automatiquement après connexion
      User? user;
      try {
        final profile = await _authRepository.getProfile(tokens.accessToken);
        user = UserModel.fromJson(profile).toEntity();
      } catch (_) {
        user = null;
      }

      // Sauvegarder la session (tokens + user éventuel)
      await _storageService.saveSession(tokens, user: user);

      emit(AuthAuthenticated(tokens, user: user));
    } catch (e) {
      emit(AuthError(_errorMessage(e)));
    }
  }

  Future<void> _onRegisterSubmitted(
    AuthRegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthRegistering(
      phoneNumber: event.phoneNumber,
      firstName: event.firstName,
      lastName: event.lastName,
      role: event.role,
    ));

    try {
      final tokens = await _authRepository.register(
        phoneNumber: event.phoneNumber,
        firstName: event.firstName,
        lastName: event.lastName,
        role: event.role,
        email: event.email,
        dateOfBirth: event.dateOfBirth,
        gender: event.gender,
        country: event.country,
        city: event.city,
        address: event.address,
        language: event.language,
      );

      // Pour l'inscription, on peut charger le profil ensuite
      User? user;
      try {
        final profile = await _authRepository.getProfile(tokens.accessToken);
        user = UserModel.fromJson(profile).toEntity();
      } catch (_) {
        user = null;
      }

      // Sauvegarder la session complète
      await _storageService.saveSession(tokens, user: user);

      emit(AuthAuthenticated(tokens, user: user));
    } catch (e) {
      emit(AuthError(_errorMessage(e)));
    }
  }

  void _onAdditionalInfoSubmitted(
    AuthAdditionalInfoSubmitted event,
    Emitter<AuthState> emit,
  ) {
    // Pour l'instant, on considère que les infos supplémentaires sont soumises
    // Dans le futur, on pourrait faire un appel API pour mettre à jour le profil
    if (state is AuthAuthenticated) {
      final currentState = state as AuthAuthenticated;
      emit(AuthAuthenticated(currentState.tokens));
    }
  }

  Future<void> _onCheckSession(
    AuthCheckSession event,
    Emitter<AuthState> emit,
  ) async {
    // Émettre l'état de vérification
    emit(AuthCheckingSession());
    
    // Vérifier les tokens stockés
    try {
      final tokens = await _storageService.getTokens();
      if (tokens != null && tokens.accessToken.isNotEmpty && tokens.accessToken.trim().isNotEmpty) {
        // Essayer de récupérer un user stocké localement
        User? user = await _storageService.getUser();

        // Si pas d'user stocké, tenter de recharger depuis l'API
        if (user == null) {
          try {
            final (profile, newTokens) = await _getProfileWithRefresh(tokens);
            user = UserModel.fromJson(profile).toEntity();
            final effectiveTokens = newTokens ?? tokens;
            if (newTokens != null) {
              await _storageService.saveSession(newTokens, user: user);
            } else {
              await _storageService.saveSession(tokens, user: user);
            }
            emit(AuthAuthenticated(effectiveTokens, user: user));
            return;
          } catch (err) {
            if (err is ApiException && err.statusCode == 401) {
              // Token expiré et refresh échoué → déconnecter
              await _storageService.clearTokens();
              emit(AuthInitial());
              return;
            }
            // Autre erreur (réseau, etc.), garder les tokens
          }
        }

        emit(AuthAuthenticated(tokens, user: user));
      } else {
        // Aucun token → utilisateur non authentifié
        emit(AuthInitial());
      }
    } catch (e) {
      // En cas d'erreur, considérer comme non authentifié
      emit(AuthInitial());
    }
  }

  Future<void> _onLoggedOut(
    AuthLoggedOut event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Supprimer les tokens du stockage
      await _storageService.clearTokens();
      // Émettre l'état initial après déconnexion
      emit(AuthInitial());
    } catch (e) {
      // Même en cas d'erreur, émettre AuthInitial pour permettre la navigation
      emit(AuthInitial());
    }
  }

  Future<void> _onLoadProfile(
    AuthLoadProfile event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthAuthenticated) {
      return;
    }

    final currentState = state as AuthAuthenticated;
    emit(AuthProfileLoading(currentState.tokens));

    try {
      final (profile, newTokens) = await _getProfileWithRefresh(
        currentState.tokens,
      );
      final user = UserModel.fromJson(profile).toEntity();
      final effectiveTokens = newTokens ?? currentState.tokens;
      await _storageService.saveSession(effectiveTokens, user: user);
      emit(AuthAuthenticated(effectiveTokens, user: user));
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        await _storageService.clearTokens();
        emit(AuthInitial());
      } else {
        emit(currentState);
      }
    }
  }

  Future<void> _onProfileUpdateSubmitted(
    AuthProfileUpdateSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthAuthenticated) return;

    final currentState = state as AuthAuthenticated;
    emit(AuthProfileLoading(currentState.tokens));

    try {
      final profile = await _authRepository.updateProfile(
        currentState.tokens.accessToken,
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        dateOfBirth: event.dateOfBirth,
        gender: event.gender,
        country: event.country,
        city: event.city,
        address: event.address,
      );
      final user = UserModel.fromJson(profile).toEntity();
      await _storageService.saveSession(currentState.tokens, user: user);
      emit(AuthAuthenticated(currentState.tokens, user: user));
    } catch (e) {
      emit(AuthError(_errorMessage(e)));
      emit(currentState);
    }
  }

  /// Récupère le profil avec refresh automatique si 401
  Future<(Map<String, dynamic>, AuthTokens?)> _getProfileWithRefresh(
    AuthTokens tokens,
  ) async {
    try {
      final profile = await _authRepository.getProfile(tokens.accessToken);
      return (profile, null);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        try {
          final newTokens = await _authRepository.refreshToken(
            tokens.refreshToken,
          );
          final profile = await _authRepository.getProfile(
            newTokens.accessToken,
          );
          return (profile, newTokens);
        } catch (_) {
          rethrow;
        }
      }
      rethrow;
    }
  }

  String _errorMessage(Object e) {
    if (e is ApiException) {
      return e.userMessage;
    }
    if (e is SocketException) {
      return 'Connexion au serveur impossible. Vérifie que le backend tourne et que l’application peut accéder à http://127.0.0.1:8000.';
    }
    if (e is TimeoutException) {
      return 'Le serveur met trop de temps à répondre. Réessaie dans un instant.';
    }
    return 'Une erreur est survenue. Veuillez réessayer.';
  }
}
