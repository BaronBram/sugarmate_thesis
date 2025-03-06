import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sugarmate_thesis/View/article_content_view.dart';

class ArticleListView extends StatefulWidget {
  const ArticleListView({super.key});

  @override
  _ArticleListViewState createState() => _ArticleListViewState();
}

class _ArticleListViewState extends State<ArticleListView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  void fetchArticles() {
    _firestore.collection('article').snapshots().listen((snapshot) {
      if (mounted) {
        setState(() {
          _articles = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Articles')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _articles.isEmpty
          ? const Center(child: Text('No articles found.'))
          : ListView.builder(
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          var article = _articles[index];
          var title = article['title'] ?? 'No Title';
          var author = article['author'] ?? 'Unknown Author';
          var imgUrl = article['imgUrl'] ?? '';
          var content = article['article'] ?? 'No Content';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleViewPage(
                    title: title,
                    author: author,
                    imgUrl: imgUrl,
                    content: content,
                  ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 5,
              child: ListTile(
                leading: imgUrl.isNotEmpty
                    ? Image.network(
                  imgUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
                    : const Icon(Icons.image, size: 60),
                trailing: const Icon(Icons.arrow_forward_ios),
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('By $author'),
              ),
            ),
          );
        },
      ),
    );
  }
}
