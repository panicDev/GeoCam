class NewsModel {
  final int id;
  final String title;
  final String body;
  final String imageUrl;
  final bool isBookmarked;

  NewsModel({
    required this.id,
    required this.title,
    required this.body,
    String? imageUrl,
    this.isBookmarked = false,
  }) : imageUrl = imageUrl != null && imageUrl.isNotEmpty
      ? imageUrl
      : _generateDummyImageUrl(id, title);

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    final String rawImageUrl = json['imageUrl'] as String? ?? '';
    final int id = json['id'];
    final String title = json['title'] as String? ?? '';

    final String imageUrl = rawImageUrl.isNotEmpty
        ? rawImageUrl
        : _generateDummyImageUrl(id, title);

    return NewsModel(
      id: id,
      title: title,
      body: json['body'],
      imageUrl: imageUrl,
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }

  static String _generateDummyImageUrl(int id, String title) {
    final String truncatedTitle = title.length > 10 ? title.substring(0, 10) : title;
    final int width = 400 + (id % 3) * 50; // Varies width between 400, 450, 500
    final int height = 200 + (id % 2) * 50; // Varies height between 200, 250
    final List<String> bgColors = ['1abc9c', '3498db', '9b59b6', 'e74c3c', 'f39c12'];
    final String bgColor = bgColors[id % bgColors.length];
    final List<String> textColors = ['ffffff', '333333'];
    final String textColor = textColors[id % textColors.length];

    // Use 'x' instead of '×' (multiplication sign) for the dimensions
    return 'https://dummyjson.com/image/${width}x$height/$bgColor/$textColor?text=${Uri.encodeComponent(truncatedTitle)}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'isBookmarked': isBookmarked,
    };
  }

  NewsModel copyWith({
    int? id,
    String? title,
    String? body,
    String? imageUrl,
    bool? isBookmarked,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}