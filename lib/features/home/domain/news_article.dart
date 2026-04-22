class NewsArticle {
  final String title;
  final String category;
  final String timeAgo;
  final String link;
  final String? imageUrl;
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
