import 'package:flutter/foundation.dart';

abstract class ApiConfig {
  static const String _urlDefinida = String.fromEnvironment('API_URL');

  static String get baseUrl {
    if (_urlDefinida.isNotEmpty) return _urlDefinida;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://localhost:8000/api';
  }

  static Uri uri(String caminho, [Map<String, String>? parametros]) {
    final uri = Uri.parse('$baseUrl$caminho');
    if (parametros == null || parametros.isEmpty) return uri;
    return uri.replace(queryParameters: parametros);
  }
}
