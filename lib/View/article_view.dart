import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sugarmate_thesis/Controller/article_controller.dart';
import 'package:sugarmate_thesis/Model/article_model.dart';
import 'package:sugarmate_thesis/View/article_content_view.dart';


class ArticleListView extends StatefulWidget {
  const ArticleListView({Key? key}) : super(key: key);

  @override
  _ArticleListViewState createState() => _ArticleListViewState();
}

class _ArticleListViewState extends State<ArticleListView> {
  final ArticleController _articleController = ArticleController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Articles')),
      body: StreamBuilder<List<ArticleModel>>(
        stream: _articleController.fetchArticles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading articles.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No articles found.'));
          }

          List<ArticleModel> articles = snapshot.data!;

          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              var article = articles[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleViewPage(
                        title: article.title,
                        author: article.author,
                        imgUrl: article.imgUrl,
                        content: article.content,
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                  child: ListTile(
                    leading: article.imgUrl.isNotEmpty
                        ? Image.network(
                      article.imgUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                        : const Icon(Icons.image, size: 60),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    title: Text(article.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('By ${article.author}'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
