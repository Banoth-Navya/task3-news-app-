import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:news_api_flutter_package/model/article.dart';
class NewsApiService {
  final String apiKey = "bb45c5eb58db4f08bc794670a422d1b1";
  final String baseUrl = "https://newsapi.org/v2/top-headlines";
  Future<List<Article>> fetchNews({String? category, String? query, int page = 1}) async {
    String url = "$baseUrl?category=$category&page=$page&pageSize=10&apiKey=$apiKey";
    if (query != null && query.isNotEmpty) {
      url += "&q=$query";
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List articles = data["articles"];
      return articles.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load news");
    }
  }
}
