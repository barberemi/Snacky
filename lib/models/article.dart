class Article {
  final String id;
  final String title;
  final String source;
  final String time;
  final String description;
  final String url;
  final String? image;
  final List<String> tags;

  Article({
    required this.id,
    required this.title,
    required this.source,
    required this.time,
    required this.description,
    required this.url,
    this.image,
    this.tags = const [],
  });

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
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Article && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
