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
  bool isWebViewLoading = false;
  @override
  void initState() {
    super.initState();
    Provider.of<NewsProvider>(context, listen: false).fetchNews();
  }
  void openNewsArticle(BuildContext context, String url) async {
    setState(() {
      isWebViewLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isWebViewLoading = false;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewsWebView(url: url)),
    );
  }
  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("NEWS NOW"),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: newsProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : newsProvider.articles.isNotEmpty
                      ? ListView.builder(
                    itemCount: newsProvider.articles.length,
                    itemBuilder: (context, index) {
                      var article = newsProvider.articles[index];
                      return _buildNewsItem(context, article);
                    },
                  )
                      : const Center(child: Text("No news available")),
                ),
              ],
            ),
          ),
          if (isWebViewLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
  Widget _buildNewsItem(BuildContext context, dynamic article) {
    return InkWell(
      onTap: () => openNewsArticle(context, article.url!),
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
                  fit: BoxFit.fitHeight,
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
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      article.source.name!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
