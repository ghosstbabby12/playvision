import 'package:flutter/material.dart';

import 'package:playvision/core/theme/app_color_tokens.dart';
import 'package:playvision/features/home/data/news_service.dart';
import 'package:playvision/shared/widgets/glass_card.dart';

import '../../../../../../l10n/generated/app_localizations.dart';

class NewsSection extends StatefulWidget {
  const NewsSection({super.key});

  @override
  State<NewsSection> createState() => _NewsSectionState();
}

class _NewsSectionState extends State<NewsSection> {
  List<NewsArticle> _articles = [];
  bool _loading = true;
  bool _error   = false;

  static const _fallbackImages = [
    'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=400&q=80',
    'https://images.unsplash.com/photo-1517466787929-bc90951d0974?w=400&q=80',
    'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=400&q=80',
    'https://images.unsplash.com/photo-1459865264687-595d652de67e?w=400&q=80',
    'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=400&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = false; });
    try {
      final articles = await NewsService.instance.fetchNews(count: 8);
      if (mounted) setState(() { _articles = articles; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = true; });
    }
  }

  String _fallback(int index) => _fallbackImages[index % _fallbackImages.length];

  @override
  Widget build(BuildContext context) {
    final c    = context.colors;
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: c.accent, strokeWidth: 1.5)),
      );
    }

    if (_error || _articles.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: ErrorCard(onRetry: _load),
      );
    }

    final featured = _articles.first;
    final rest     = _articles.skip(1).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(children: [
        FeaturedArticleCard(article: featured, fallbackImage: _fallback(0)),
        const SizedBox(height: 12),
        ...rest.asMap().entries.map((e) => ArticleCard(
          article: e.value,
          fallbackImage: _fallback(e.key + 1),
        )),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: _load,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.refresh_rounded, color: c.accent, size: 14),
              const SizedBox(width: 6),
              Text(l10n.newsRefreshButton, style: TextStyle(color: c.accent, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ]),
    );
  }
}

class ErrorCard extends StatelessWidget {
  final VoidCallback onRetry;
  const ErrorCard({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c    = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        Icon(Icons.wifi_off_rounded, color: c.dim, size: 32),
        const SizedBox(height: 10),
        Text(l10n.newsErrorTitle, style: TextStyle(color: c.text, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(l10n.newsErrorSubtitle, style: TextStyle(color: c.muted, fontSize: 12)),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(color: c.accentLo, borderRadius: BorderRadius.circular(8)),
            child: Text(l10n.newsRetryButton, style: TextStyle(color: c.accent, fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }
}

class FeaturedArticleCard extends StatefulWidget {
  final NewsArticle article;
  final String fallbackImage;
  const FeaturedArticleCard({super.key, required this.article, required this.fallbackImage});

  @override
  State<FeaturedArticleCard> createState() => _FeaturedArticleCardState();
}

class _FeaturedArticleCardState extends State<FeaturedArticleCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c          = context.colors;
    final imageUrl   = widget.article.imageUrl ?? widget.fallbackImage;
    final hasSummary = widget.article.summary?.isNotEmpty == true;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(18),
            bottom: _expanded ? Radius.zero : const Radius.circular(18),
          ),
          child: SizedBox(
            height: 200,
            child: Stack(fit: StackFit.expand, children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.network(widget.fallbackImage, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: c.elevated)),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.88)],
                  ),
                ),
              ),
              Positioned(
                left: 16, right: 16, bottom: 16,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(6)),
                    child: Text(widget.article.category,
                        style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.article.title,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, height: 1.3)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Text(widget.article.timeAgo,
                        style: const TextStyle(color: Colors.white60, fontSize: 11)),
                    const Spacer(),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.white60, size: 20),
                    ),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          child: _expanded
              ? Container(
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                    border: Border.all(color: c.border),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: hasSummary
                      ? Text(widget.article.summary!,
                          style: TextStyle(color: c.text, fontSize: 13, height: 1.55))
                      : Text('Sin descripción disponible',
                          style: TextStyle(color: c.muted, fontSize: 12,
                              fontStyle: FontStyle.italic)),
                )
              : const SizedBox.shrink(),
        ),
      ]),
    );
  }
}

class ArticleCard extends StatefulWidget {
  final NewsArticle article;
  final String fallbackImage;
  const ArticleCard({super.key, required this.article, required this.fallbackImage});

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c          = context.colors;
    final imageUrl   = widget.article.imageUrl ?? widget.fallbackImage;
    final hasSummary = widget.article.summary?.isNotEmpty == true;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      radius: 16,
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        behavior: HitTestBehavior.opaque,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
              child: SizedBox(
                width: 90, height: 88,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.network(widget.fallbackImage, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: c.elevated,
                        child: Icon(Icons.sports_soccer, color: c.accent, size: 28),
                      )),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: c.accentLo, borderRadius: BorderRadius.circular(5)),
                  child: Text(widget.article.category,
                      style: TextStyle(color: c.accent, fontSize: 9, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 5),
                Text(widget.article.title,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: c.text, fontSize: 12, fontWeight: FontWeight.w600, height: 1.3)),
                const SizedBox(height: 4),
                Text(widget.article.timeAgo, style: TextStyle(color: c.muted, fontSize: 10)),
              ]),
            )),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 220),
                child: Icon(Icons.keyboard_arrow_down_rounded, color: c.dim, size: 20),
              ),
            ),
          ]),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Divider(color: c.border, height: 16),
                      hasSummary
                          ? Text(widget.article.summary!,
                              style: TextStyle(color: c.text, fontSize: 12, height: 1.55))
                          : Text('Sin descripción disponible',
                              style: TextStyle(color: c.muted, fontSize: 12,
                                  fontStyle: FontStyle.italic)),
                    ]),
                  )
                : const SizedBox.shrink(),
          ),
        ]),
      ),
    );
  }
}
