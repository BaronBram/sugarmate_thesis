class ArticleModel {
  final String title;
  final String author;
  final String imgUrl;
  final String content;

  ArticleModel({
    required this.title,
    required this.author,
    required this.imgUrl,
    required this.content,
  });

  factory ArticleModel.fromMap(Map<String, dynamic> map) {
    return ArticleModel(
      title: map['title'] ?? 'No Title',
      author: map['author'] ?? 'Unknown Author',
      imgUrl: map['imgUrl'] ?? '',
      content: map['article'] ?? 'No Content',
    );
  }
}
