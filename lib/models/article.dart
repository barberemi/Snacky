class Article {
  final String id;
  final String title;
  final String source;
  final String time;
  final String description;
  final String url;
  final String? image;
  final List<String> tags;

  /// Date à laquelle l'article a été récupéré depuis l'API
  final DateTime fetchedAt;

  Article({
    required this.id,
    required this.title,
    required this.source,
    required this.time,
    required this.description,
    required this.url,
    this.image,
    this.tags = const [],
    DateTime? fetchedAt,
  }) : fetchedAt = fetchedAt ?? DateTime.now();

  /// Retourne true si l'article date d'un jour précédent (périmé)
  bool get isExpired {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final articleDay = DateTime(fetchedAt.year, fetchedAt.month, fetchedAt.day);
    return articleDay.isBefore(today);
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      source: json['source'] as String,
      time: json['time'] as String,
      description: json['description'] as String,
      url: json['url'] as String,
      image: json['image'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      fetchedAt: json['fetchedAt'] != null
          ? DateTime.parse(json['fetchedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'source': source,
      'time': time,
      'description': description,
      'url': url,
      'image': image,
      'tags': tags,
      'fetchedAt': fetchedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Article && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
