import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:playvision/core/constants/app_constants.dart';
import 'package:playvision/features/home/domain/news_article.dart';

export 'package:playvision/features/home/domain/news_article.dart';

class NewsService {
  NewsService._();
  static final instance = NewsService._();

  // ─── Feeds RSS de respaldo ────────────────────────────────────────────────

  static const _feeds = [
    (url: 'https://feeds.bbci.co.uk/sport/football/rss.xml',  source: 'BBC Sport'),
    (url: 'https://www.espn.com/espn/rss/soccer/news',        source: 'ESPN FC'),
    (url: 'https://en.as.com/rss/futbol.xml',                 source: 'AS.com'),
    (url: 'https://www.goal.com/feeds/en/news',               source: 'Goal.com'),
    (url: 'https://www.skysports.com/rss/12040',              source: 'Sky Sports'),
  ];

  static const _headers = {
    'User-Agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
        'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
    'Accept': 'application/rss+xml, application/xml, text/xml, */*',
    'Accept-Language': 'en-US,en;q=0.9,es;q=0.8',
  };

  static const _backendTimeout = Duration(seconds: 10);
  static const _rssTimeout     = Duration(seconds: 12);

  // ─── API pública ──────────────────────────────────────────────────────────

  Future<List<NewsArticle>> fetchNews({int count = 20, String? topic}) async {
    try {
      final articles = await _fetchFromBackend(count: count, topic: topic);
      if (articles.isNotEmpty) return articles;
    } catch (_) {
      // Si el backend falla, usamos el fallback RSS silenciosamente.
    }
    return _fetchFromRss(count: count);
  }

  // ─── Backend (/api/news) ──────────────────────────────────────────────────

  Future<List<NewsArticle>> _fetchFromBackend({
    int count = 20,
    String? topic,
  }) async {
    var uri = Uri.parse('${AppConstants.apiBase}/api/news');
    if (topic != null) {
      uri = uri.replace(queryParameters: {'topic': topic});
    }

    final res = await http.get(uri).timeout(_backendTimeout);
    if (res.statusCode != 200) throw Exception('backend ${res.statusCode}');

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['articulos'] as List?) ?? [];

    return list
        .take(count)
        .map((a) => NewsArticle(
              title:    a['titulo']   ?? '',
              category: a['etiqueta'] ?? 'Fútbol',
              timeAgo:  _timeAgoFromIso(a['fecha'] ?? ''),
              link:     a['url']      ?? '',
              imageUrl: (a['imagen'] as String?)?.isNotEmpty == true
                  ? a['imagen']
                  : null,
              summary: a['resumen'],
            ))
        .where((a) => a.title.isNotEmpty)
        .toList();
  }

  // ─── Fallback RSS ─────────────────────────────────────────────────────────

  Future<List<NewsArticle>> _fetchFromRss({int count = 10}) async {
    final articles = <NewsArticle>[];

    for (final feed in _feeds) {
      if (articles.length >= count * 2) break;
      try {
        final res = await http
            .get(Uri.parse(feed.url), headers: _headers)
            .timeout(_rssTimeout);
        if (res.statusCode != 200) continue;
        final body = utf8.decode(res.bodyBytes, allowMalformed: true);
        articles.addAll(_parseRss(body, feed.source));
      } catch (_) {
        continue;
      }
    }

    articles.shuffle();
    return articles.take(count).toList();
  }

  // ─── Parser RSS ───────────────────────────────────────────────────────────

  List<NewsArticle> _parseRss(String xml, String source) {
    final items = <NewsArticle>[];
    final itemRx = RegExp(
      r'<item\b[^>]*>([\s\S]*?)</item>',
      caseSensitive: false,
    );

    for (final m in itemRx.allMatches(xml)) {
      final block = m.group(1) ?? '';
      final title = _extractTag(block, 'title');
      if (title.isEmpty) continue;

      final raw = _extractTag(block, 'description');
      items.add(NewsArticle(
        title:    title,
        category: source,
        timeAgo:  _timeAgo(_extractTag(block, 'pubDate')),
        link:     _extractLink(block),
        imageUrl: _extractImage(block),
        summary:  _cleanHtml(raw),
      ));
    }
    return items;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _extractTag(String block, String tag) {
    final rx = RegExp(
      '<$tag[^>]*>(?:<!\\[CDATA\\[([\\s\\S]*?)\\]\\]>|([^<]*))</$tag>',
      caseSensitive: false,
    );
    final m = rx.firstMatch(block);
    return (m?.group(1) ?? m?.group(2) ?? '').trim();
  }

  String _extractLink(String block) {
    var m = RegExp(
      r'<link[^>]*>(?:<!\[CDATA\[([\s\S]*?)\]\]>|([^<]*))</link>',
      caseSensitive: false,
    ).firstMatch(block);
    final plain = (m?.group(1) ?? m?.group(2) ?? '').trim();
    if (plain.isNotEmpty) return plain;

    m = RegExp(r'<link[^>]+href="([^"]+)"', caseSensitive: false)
        .firstMatch(block);
    return m?.group(1) ?? '';
  }

  String? _extractImage(String block) {
    final patterns = [
      RegExp(r'<media:content[^>]+url="([^"]+)"',   caseSensitive: false),
      RegExp(r'<media:thumbnail[^>]+url="([^"]+)"',  caseSensitive: false),
      RegExp(
        r'<enclosure[^>]+url="([^"]+)"[^>]+type="image/',
        caseSensitive: false,
      ),
      RegExp(r'<img[^>]+src="([^"]+)"', caseSensitive: false),
    ];
    for (final rx in patterns) {
      final m = rx.firstMatch(block);
      if (m != null) return m.group(1);
    }
    return null;
  }

  String _timeAgoFromIso(String iso) {
    try {
      final dt   = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt.toLocal());
      return _formatDiff(diff);
    } catch (_) {
      return '';
    }
  }

  String _timeAgo(String pubDate) {
    if (pubDate.isEmpty) return '';

    // Intento 1: ISO 8601
    final iso = _timeAgoFromIso(pubDate);
    if (iso.isNotEmpty) return iso;

    // Intento 2: RFC 2822 (ej. "Mon, 01 Jan 2024 10:00:00 +0000")
    try {
      const months = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
        'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
        'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
      };
      final parts = pubDate.trim().split(RegExp(r'\s+'));
      if (parts.length >= 5) {
        final day   = int.parse(parts[1]);
        final month = months[parts[2]] ?? 1;
        final year  = int.parse(parts[3]);
        final time  = parts[4].split(':');
        final dt    = DateTime.utc(
          year, month, day, int.parse(time[0]), int.parse(time[1]),
        );
        return _formatDiff(DateTime.now().difference(dt));
      }
    } catch (_) {}

    return '';
  }

  String _cleanHtml(String html) {
    if (html.isEmpty) return '';
    return html
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll("&apos;", "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _formatDiff(Duration diff) {
    if (diff.inMinutes < 60)  return 'Hace ${diff.inMinutes} min';
    if (diff.inHours   < 24)  return 'Hace ${diff.inHours} h';
    if (diff.inDays    < 7)   return 'Hace ${diff.inDays} días';
    return 'Hace ${(diff.inDays / 7).floor()} sem';
  }
}
