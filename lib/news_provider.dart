import 'package:flutter/material.dart';
import 'news_api_service.dart';
import 'package:news_api_flutter_package/model/article.dart';
class NewsProvider with ChangeNotifier {
  final NewsApiService _newsApiService = NewsApiService();
  List<Article> _articles = [];
  bool _isLoading = false;
  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  Future<void> fetchNews(String sourceId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _articles = await _newsApiService.fetchNews(sourceId: sourceId);
    } catch (e) {
      _articles = [];
    }
    _isLoading = false;
    notifyListeners();
  }
}
