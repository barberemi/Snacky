class Article {
  final String title;
  final String source;
  final String time;
  final String description;
  final String url;
  final String? image;

  Article({
    required this.title,
    required this.source,
    required this.time,
    required this.description,
    required this.url,
    this.image,
  });
}
