import 'dart:io'

class ApiConfig{
    ApiConfig._();

    static String? baseUrlOverride;

    static String get baseUrl {
        if (baseUrlOverride != null && baseUrlOverride!.isNotEmpty){
            return baseUrlOverride!;
        }
        if (Platform.isAndroid){
            return 'http://10.0.2.2:8000/api/v1';
        }else{
            return 'http://localhost:8000/api/v1';
        }
    }

    static const int timeoutSeconds = 30;

    static Map<String, String> get defaultHeaders => {
        'Content-Type': 'appication/json',
        'Accept': 'application/json',
    }
}