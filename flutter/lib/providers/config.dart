import 'dart:js' as js;

String getBaseUrl() {
  final config = js.context['flutterWebConfiguration'];
  if (config != null && config is js.JsObject) {
    final baseUrl = config['baseUrl'];
    if (baseUrl != null && baseUrl is String) {
      print('Base URL: $baseUrl'); // Debug print
      return baseUrl;
    }
  }
  throw Exception('Base URL not found in configuration');
}
