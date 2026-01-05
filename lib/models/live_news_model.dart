class LiveNewsModel {
  final String title;
  final String description;
  final String? urlToImage;
  final String url;
  final String sourceName;
  final DateTime publishedAt;

  LiveNewsModel({
    required this.title,
    required this.description,
    this.urlToImage,
    required this.url,
    required this.sourceName,
    required this.publishedAt,
  });

  factory LiveNewsModel.fromJson(Map<String, dynamic> json) {
    return LiveNewsModel(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description Available',
      urlToImage: json['urlToImage'],
      url: json['url'] ?? '',
      sourceName: json['source']?['name'] ?? 'Unknown Source',
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
