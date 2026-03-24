/// Exception dédiée aux erreurs API
///
/// CONCEPT : Une exception typée permet au Bloc de distinguer
/// les erreurs réseau (ApiException) des autres erreurs (Exception générique).
/// On peut afficher un message adapté à l'utilisateur.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? detail;

  ApiException({
    required this.message,
    this.statusCode,
    this.detail,
  });

  /// Message formaté pour l'affichage à l'utilisateur
  @override
  String toString() {
    final detailStr = detail ?? message;
    if (statusCode != null) {
      return 'ApiException(statusCode: $statusCode): $detailStr';
    }
    return detailStr;
  }

  /// Message court pour l'UI (sans info technique)
  String get userMessage => detail ?? message;
}
