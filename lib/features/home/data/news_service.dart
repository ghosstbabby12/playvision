import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:playvision/core/constants/app_constants.dart';

class NewsArticle {
  final String title;
  final String category;
  final String timeAgo;
  final String? imageUrl;
  final String link;
  final String? summary;

  const NewsArticle({
    required this.title,
    required this.category,
    required this.timeAgo,
    required this.link,
    this.imageUrl,
    this.summary,
  });
}

class NewsService {
  NewsService._();
  static final instance = NewsService._();

  // ── RSS fallback feeds ─────────────────────────────────────────────────────
  static const _feeds = [
    (url: 'https://feeds.bbci.co.uk/sport/football/rss.xml',  category: 'BBC Sport'),
    (url: 'https://www.espn.com/espn/rss/soccer/news',        category: 'ESPN FC'),
    (url: 'https://en.as.com/rss/futbol.xml',                 category: 'AS.com'),
    (url: 'https://www.goal.com/feeds/en/news',               category: 'Goal.com'),
    (url: 'https://www.skysports.com/rss/12040',              category: 'Sky Sports'),
  ];

  static const _headers = {
    'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
        'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
    'Accept': 'application/rss+xml, application/xml, text/xml, */*',
    'Accept-Language': 'en-US,en;q=0.9,es;q=0.8',
  };

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<List<NewsArticle>> fetchNews({int count = 20, String? topic}) async {
    // 1. Intentar backend primero
    try {
      final articles = await _fetchFromBackend(count: count, topic: topic);
      if (articles.isNotEmpty) return articles;
    } catch (_) {}

    // 2. Fallback a RSS
    return _fetchFromRss(count: count);
  }

  // ── Backend (/api/news) ────────────────────────────────────────────────────

  Future<List<NewsArticle>> _fetchFromBackend({
    int count = 20,
    String? topic,
  }) async {
    var uri = Uri.parse('${AppConstants.apiBase}/api/news');
    if (topic != null) uri = uri.replace(queryParameters: {'topic': topic});

    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) throw Exception('backend ${res.statusCode}');

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['articulos'] as List?) ?? [];

    return list
        .take(count)
        .map((a) => NewsArticle(
              title:    a['titulo']  ?? '',
              category: a['etiqueta'] ?? 'Fútbol',
              timeAgo:  _timeAgoFromIso(a['fecha'] ?? ''),
              link:     a['url']    ?? '',
              imageUrl: (a['imagen'] as String?)?.isNotEmpty == true
                  ? a['imagen']
                  : null,
              summary:  a['resumen'],
            ))
        .where((a) => a.title.isNotEmpty)
        .toList();
  }

  // ── RSS fallback ───────────────────────────────────────────────────────────

  Future<List<NewsArticle>> _fetchFromRss({int count = 10}) async {
    final articles = <NewsArticle>[];

    for (final feed in _feeds) {
      if (articles.length >= count * 2) break;
      try {
        final res = await http
            .get(Uri.parse(feed.url), headers: _headers)
            .timeout(const Duration(seconds: 12));
        if (res.statusCode != 200) continue;
        final body = utf8.decode(res.bodyBytes, allowMalformed: true);
        articles.addAll(_parseRss(body, feed.category));
      } catch (_) {
        continue;
      }
    }

    articles.shuffle();
    return articles.take(count).toList();
  }

  // ── RSS parser ─────────────────────────────────────────────────────────────

  List<NewsArticle> _parseRss(String xml, String category) {
    final items = <NewsArticle>[];
    final itemRx = RegExp(r'<item\b[^>]*>([\s\S]*?)</item>', caseSensitive: false);

    for (final m in itemRx.allMatches(xml)) {
      final block = m.group(1) ?? '';
      final title = _extract(block, 'title');
      if (title.isEmpty) continue;

      items.add(NewsArticle(
        title:    title,
        category: category,
        timeAgo:  _timeAgo(_extract(block, 'pubDate')),
        link:     _extractLink(block),
        imageUrl: _extractImage(block),
      ));
    }
    return items;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _timeAgoFromIso(String iso) {
    try {
      final dt   = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt.toLocal());
      return _formatDiff(diff);
    } catch (_) {
      return '';
    }
  }

  String _extract(String block, String tag) {
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
    var m = RegExp(r'<media:content[^>]+url="([^"]+)"', caseSensitive: false)
        .firstMatch(block);
    if (m != null) return m.group(1);

    m = RegExp(r'<media:thumbnail[^>]+url="([^"]+)"', caseSensitive: false)
        .firstMatch(block);
    if (m != null) return m.group(1);

    m = RegExp(r'<enclosure[^>]+url="([^"]+)"[^>]+type="image/',
            caseSensitive: false)
        .firstMatch(block);
    if (m != null) return m.group(1);

    m = RegExp(r'<img[^>]+src="([^"]+)"', caseSensitive: false)
        .firstMatch(block);
    return m?.group(1);
  }

  String _timeAgo(String pubDate) {
    if (pubDate.isEmpty) return '';
    try {
      return _timeAgoFromIso(pubDate);
    } catch (_) {}

    try {
      final parts = pubDate.trim().split(RegExp(r'\s+'));
      if (parts.length >= 5) {
        const months = {
          'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
          'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
          'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
        };
        final day   = int.parse(parts[1]);
        final month = months[parts[2]] ?? 1;
        final year  = int.parse(parts[3]);
        final time  = parts[4].split(':');
        final dt    = DateTime.utc(year, month, day, int.parse(time[0]), int.parse(time[1]));
        return _formatDiff(DateTime.now().difference(dt));
      }
    } catch (_) {}
    return '';
  }

  String _formatDiff(Duration diff) {
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24)   return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7)     return 'Hace ${diff.inDays} días';
    return 'Hace ${(diff.inDays / 7).floor()} sem';
  }
}
