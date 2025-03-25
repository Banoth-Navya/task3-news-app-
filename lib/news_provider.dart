import 'package:flutter/material.dart';
import 'news_api_service.dart';
import 'package:news_api_flutter_package/model/article.dart';
class NewsProvider with ChangeNotifier {
  final NewsApiService _newsApiService = NewsApiService();
  List<Article> _articles = [];
  bool _isLoading = false;
  String _errorMessage = "";
  int _page = 1;
  bool _hasMore = true;
  String _currentCategory = "general";
  String _searchQuery = "";
  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  Future<void> fetchNews({String? category, String? query, bool isRefresh = false}) async {
    if (isRefresh) {
      _page = 1;
      _articles.clear();
      _hasMore = true;
    }
    if (!_hasMore || _isLoading) return;
    _isLoading = true;
    _errorMessage = "";
    notifyListeners();
    try {
      List<Article> newArticles = await _newsApiService.fetchNews(
        category: category ?? _currentCategory,
        query: query ?? _searchQuery,
        page: _page,
      );
      if (newArticles.isEmpty) {
        _hasMore = false;
      } else {
        _articles.addAll(newArticles);
        _page++;
      }
    } catch (e) {
      _errorMessage = "Failed to fetch news. Please try again.";
      _hasMore = false;
    }
    _isLoading = false;
    notifyListeners();
  }
  void setCategory(String category) {
    _currentCategory = category;
    _searchQuery = ""; // Reset search when switching category
    fetchNews(category: category, isRefresh: true);
  }
  void searchNews(String query) {
    _searchQuery = query;
    fetchNews(category: _currentCategory, query: query, isRefresh: true);
  }
}
