class ApiException implements Exception {
    final String message;
    final int? statusCode;
    final String? detail;

    ApiException({
        required this.message,
        this.statusCode,
        this.detail
    });

    @override
    String toString() {
        final detailStr = detail ?? message;
        if (statusCode != null) {
            return 'ApiException(statusCode: $statusCode): $detailStr'
        }
        return detailStr
    }

    String get userMessage => detail ?? message;
}