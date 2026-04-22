import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsArticle {
  final String title;
  final String category;
  final String timeAgo;
  final String? imageUrl;
  final String link;

  const NewsArticle({
    required this.title,
    required this.category,
    required this.timeAgo,
    required this.link,
    this.imageUrl,
  });
}

class NewsService {
  NewsService._();
  static final instance = NewsService._();

  static const _feeds = [
    (
      url: 'https://feeds.bbci.co.uk/sport/football/rss.xml',
      category: 'BBC Sport'
    ),
    (url: 'https://www.espn.com/espn/rss/soccer/news', category: 'ESPN FC'),
    (url: 'https://en.as.com/rss/futbol.xml', category: 'AS.com'),
    (url: 'https://www.goal.com/feeds/en/news', category: 'Goal.com'),
    (url: 'https://www.skysports.com/rss/12040', category: 'Sky Sports'),
  ];

  static const _headers = {
    'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
        'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
    'Accept': 'application/rss+xml, application/xml, text/xml, */*',
    'Accept-Language': 'en-US,en;q=0.9,es;q=0.8',
  };

  Future<List<NewsArticle>> fetchNews({int count = 10}) async {
    final articles = <NewsArticle>[];

    for (final feed in _feeds) {
      if (articles.length >= count * 2) break;
      try {
        final res = await http
            .get(Uri.parse(feed.url), headers: _headers)
            .timeout(const Duration(seconds: 12));

        if (res.statusCode != 200) continue;

        final body = utf8.decode(res.bodyBytes, allowMalformed: true);
        final parsed = _parseRss(body, feed.category);
        articles.addAll(parsed);
      } catch (_) {
        continue;
      }
    }

    articles.shuffle();
    return articles.take(count).toList();
  }

  List<NewsArticle> _parseRss(String xml, String category) {
    final items = <NewsArticle>[];
    final itemRx =
        RegExp(r'<item\b[^>]*>([\s\S]*?)</item>', caseSensitive: false);

    for (final m in itemRx.allMatches(xml)) {
      final block = m.group(1) ?? '';

      final title = _extract(block, 'title');
      if (title.isEmpty) continue;

      final link = _extractLink(block);
      final pubDate = _extract(block, 'pubDate');
      final image = _extractImage(block);

      items.add(NewsArticle(
        title: title,
        category: category,
        timeAgo: _timeAgo(pubDate),
        link: link,
        imageUrl: image,
      ));
    }

    return items;
  }

  String _extract(String block, String tag) {
    final rx = RegExp(
      '<$tag[^>]*>(?:<!\\[CDATA\\[([\\s\\S]*?)\\]\\]>|([^<]*))</$tag>',
      caseSensitive: false,
    );
    final m = rx.firstMatch(block);
    return (m?.group(1) ?? m?.group(2) ?? '').trim();
  }

  // <link> can appear as plain text between tags or as href attribute
  String _extractLink(String block) {
    // Plain text form: <link>url</link>
    var m = RegExp(
      r'<link[^>]*>(?:<!\[CDATA\[([\s\S]*?)\]\]>|([^<]*))</link>',
      caseSensitive: false,
    ).firstMatch(block);
    final plain = (m?.group(1) ?? m?.group(2) ?? '').trim();
    if (plain.isNotEmpty) return plain;

    // Atom link with href: <link rel="alternate" href="..."/>
    m = RegExp(r'<link[^>]+href="([^"]+)"', caseSensitive: false)
        .firstMatch(block);
    return m?.group(1) ?? '';
  }

  String? _extractImage(String block) {
    // <media:content url="...">
    var m = RegExp(r'<media:content[^>]+url="([^"]+)"', caseSensitive: false)
        .firstMatch(block);
    if (m != null) return m.group(1);

    // <media:thumbnail url="...">
    m = RegExp(r'<media:thumbnail[^>]+url="([^"]+)"', caseSensitive: false)
        .firstMatch(block);
    if (m != null) return m.group(1);

    // <enclosure url="..." type="image/...">
    m = RegExp(r'<enclosure[^>]+url="([^"]+)"[^>]+type="image/',
            caseSensitive: false)
        .firstMatch(block);
    if (m != null) return m.group(1);

    // <img src="..."> inside description/content
    m = RegExp(r'<img[^>]+src="([^"]+)"', caseSensitive: false)
        .firstMatch(block);
    if (m != null) return m.group(1);

    return null;
  }

  String _timeAgo(String pubDate) {
    if (pubDate.isEmpty) return '';

    // Try ISO 8601 first
    try {
      final dt = DateTime.parse(pubDate);
      final diff = DateTime.now().difference(dt.toLocal());
      return _formatDiff(diff);
    } catch (_) {}

    // RFC 822: "Mon, 14 Apr 2025 10:00:00 +0000" or "Mon, 14 Apr 2025 10:00:00 GMT"
    try {
      final parts = pubDate.trim().split(RegExp(r'\s+'));
      if (parts.length >= 5) {
        const months = {
          'Jan': 1,
          'Feb': 2,
          'Mar': 3,
          'Apr': 4,
          'May': 5,
          'Jun': 6,
          'Jul': 7,
          'Aug': 8,
          'Sep': 9,
          'Oct': 10,
          'Nov': 11,
          'Dec': 12,
        };
        final day = int.parse(parts[1]);
        final month = months[parts[2]] ?? 1;
        final year = int.parse(parts[3]);
        final time = parts[4].split(':');
        final dt2 = DateTime.utc(
            year, month, day, int.parse(time[0]), int.parse(time[1]));
        return _formatDiff(DateTime.now().difference(dt2));
      }
    } catch (_) {}

    return '';
  }

  String _formatDiff(Duration diff) {
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return 'Hace ${(diff.inDays / 7).floor()} sem';
  }
}
