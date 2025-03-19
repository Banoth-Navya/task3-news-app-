import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:news_api_flutter_package/model/article.dart';
class NewsApiService {
  final String apiKey = "5129fc16637b46fcbfadc5c0e01ab425";
  final String baseUrl = "https://newsapi.org/v2/top-headlines";
  Future<List<Article>> fetchNews({String? sourceId}) async {
    final response = await http.get(
      Uri.parse("$baseUrl?sources=$sourceId&apiKey=$apiKey"),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List articles = data["articles"];
      return articles.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load news");
    }
  }
}
