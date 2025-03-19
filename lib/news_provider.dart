import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';

class NewsProvider extends ChangeNotifier {
  final String apiKey = "5129fc16637b46fcbfadc5c0e01ab425";
  List<Article> _articles = [];
  bool _isLoading = false;
  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  Future<void> fetchNews() async {
    try {
      _isLoading = true;
      notifyListeners();
      NewsAPI newsAPI = NewsAPI(apiKey: apiKey);
      _articles = await newsAPI.getTopHeadlines(
        sources: ["fox-sports"].join(","),
        pageSize: 50,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Error fetching news: $e");
    }
  }
}
