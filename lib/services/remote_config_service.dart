import 'dart:convert';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────
// Remote Config Service  (replaces PocketBase)
//
// Live balance/content overrides are a plain JSON file in the
// repo, served free by GitHub Pages alongside the web build:
//
//   assets/config/overrides.json   (committed to main)
//      → https://whoseyci.github.io/Strideborn/assets/assets/config/overrides.json
//
// Editing game balance = edit JSON → git push → all clients pick
// it up on next launch. Versioned, diffable, zero infrastructure.
//
// Later (multiplayer): swap `_url` for a Cloudflare Worker + KV/D1
// endpoint — the response shape stays identical, nothing else changes.
// ─────────────────────────────────────────────────────────

class RemoteConfigService {
  static const _url =
      'https://whoseyci.github.io/Strideborn/assets/assets/config/overrides.json';

  /// Fetch override config. Returns null on any failure —
  /// callers must treat bundled config as the fallback.
  static Future<Map<String, dynamic>?> fetchOverrides() async {
    try {
      final res = await http
          .get(Uri.parse(_url))
          .timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return null;
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
