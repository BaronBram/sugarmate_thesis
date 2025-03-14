import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sugarmate_thesis/Model/article_model.dart';

class ArticleController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ArticleModel>> fetchArticles() {
    return _firestore.collection('article').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ArticleModel.fromMap(doc.data())).toList();
    });
  }
}
