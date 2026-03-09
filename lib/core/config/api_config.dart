/// Konfigurasi endpoint AI
///
/// Production (Netlify):  Flutter → /.netlify/functions/analyze → OpenAI
/// Local dev:             Flutter → localhost:8080/proxy           → OpenAI
///
/// API key TIDAK pernah ada di Flutter — selalu di server.
class ApiConfig {
  /// Netlify Function proxy (production)
  static const String netlifyFunctionPath = '/.netlify/functions/analyze';

  /// Local proxy script: jalankan `node scripts/proxy.js`
  static const String localProxyUrl = 'http://localhost:8080/proxy';

  static const String openAiModel = 'gpt-4o-mini';
}
