import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'news_provider.dart';
import 'news_web_view.dart';
class NewsPage extends StatefulWidget {
  const NewsPage({super.key});
  @override
  State<NewsPage> createState() => _NewsPageState();
}
class _NewsPageState extends State<NewsPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<NewsProvider>(context, listen: false).fetchNews("abc-news");
  }
  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("NEWS NOW"),
      ),
      body: newsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : newsProvider.articles.isEmpty
          ? const Center(child: Text("No news available"))
          : ListView.builder(
        itemCount: newsProvider.articles.length,
        itemBuilder: (context, index) {
          final article = newsProvider.articles[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsWebView(url: article.url!),
                ),
              );
            },
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 80,
                      width: 80,
                      child: Image.network(
                        article.urlToImage ?? "",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported);
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title!,
                            maxLines: 2,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            article.source.name!,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
