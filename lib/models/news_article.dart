class NewsArticle {
  final String title;
  final String content;
  final String source;
  final bool isFake;
  final double credibilityScore;
  final DateTime scanDate;
  final List<String> issues;
  final String status;
  final String? imageUrl;

  NewsArticle({
    required this.title,
    required this.content,
    required this.source,
    required this.isFake,
    required this.credibilityScore,
    required this.scanDate,
    required this.issues,
    required this.status,
    this.imageUrl,
  });
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'source': source,
      'isFake': isFake,
      'credibilityScore': credibilityScore,
      'scanDate': scanDate.millisecondsSinceEpoch,
      'issues': issues,
      'status': status,
      'imageUrl': imageUrl,
    };
  }

  factory NewsArticle.fromMap(Map<String, dynamic> map) {
    return NewsArticle(
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      source: map['source'] ?? '',
      isFake: map['isFake'] ?? false,
      credibilityScore: (map['credibilityScore'] ?? 0.0).toDouble(),
      scanDate: DateTime.fromMillisecondsSinceEpoch(map['scanDate'] ?? 0),
      issues: List<String>.from(map['issues'] ?? []),
      status: map['status'] ?? '',
      imageUrl: map['imageUrl'],
    );
  }
}
