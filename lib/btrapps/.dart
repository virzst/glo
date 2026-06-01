import 'dart:convert';
import 'package:http/http.dart' as http;

class Api {
  static const String _fallbackUrl = 'http://209.97.170.188:4082';

  static const String _remoteConfigUrl =
      'https://raw.githubusercontent.com/virzst/Virzdb/main/x.json';

  static String _baseUrl = _fallbackUrl;

  static String get api => _baseUrl;

  static bool get isUsingFallback => _baseUrl == _fallbackUrl;

  static Future<void> loadGh() async {
    try {
      final response = await http
          .get(
            Uri.parse(_remoteConfigUrl),
            headers: const {
              'Accept': 'application/json',
              'Cache-Control': 'no-cache',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        _baseUrl = _fallbackUrl;
        return;
      }

      final dynamic decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        _baseUrl = _fallbackUrl;
        return;
      }

      final String? remoteUrl = decoded['x']?.toString().trim();
      if (_isValidBaseUrl(remoteUrl)) {
        _baseUrl = _normalizeBaseUrl(remoteUrl!);
      } else {
        _baseUrl = _fallbackUrl;
      }
    } catch (_) {
      _baseUrl = _fallbackUrl;
    }
  }

  static bool _isValidBaseUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    if (!uri.hasScheme || !uri.hasAuthority) return false;
    if (uri.scheme != 'http' && uri.scheme != 'https') return false;

    return true;
  }

  static String _normalizeBaseUrl(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
}   