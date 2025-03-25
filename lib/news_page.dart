import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'news_provider.dart';
import 'news_web_view.dart';
import 'login_page.dart';
class NewsPage extends StatefulWidget {
  const NewsPage({super.key});
  @override
  State<NewsPage> createState() => _NewsPageState();
}
class _NewsPageState extends State<NewsPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ScrollController _scrollController = ScrollController();
  final List<String> categories = ["General", "Technology", "Sports", "Health", "Business", "Entertainment"];
  String _selectedCategory = "General";
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<NewsProvider>(context, listen: false);
    provider.fetchNews(category: _selectedCategory.toLowerCase());
    _scrollController.addListener(_scrollListener);
  }
  void _scrollListener() {
    final provider = Provider.of<NewsProvider>(context, listen: false);
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 &&
        provider.hasMore &&
        !provider.isLoading) {
      provider.fetchNews(category: _selectedCategory.toLowerCase());
    }
  }
  Future<void> _logout() async {
    await _storage.delete(key: 'auth_token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("NEWS NOW"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search news...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<NewsProvider>(context, listen: false).searchNews("");
                  },
                )
                    : null,
              ),
              onChanged: (query) {
                Provider.of<NewsProvider>(context, listen: false).searchNews(query);
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    selectedColor: Colors.green,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                          _searchController.clear();
                        });
                        Provider.of<NewsProvider>(context, listen: false).setCategory(category.toLowerCase());
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await newsProvider.fetchNews(category: _selectedCategory.toLowerCase(), isRefresh: true);
              },
              child: newsProvider.isLoading && newsProvider.articles.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : newsProvider.errorMessage.isNotEmpty
                  ? Center(child: Text(newsProvider.errorMessage))
                  : newsProvider.articles.isEmpty
                  ? const Center(child: Text("No news available"))
                  : ListView.builder(
                controller: _scrollController,
                itemCount: newsProvider.articles.length + 1,
                itemBuilder: (context, index) {
                  if (index < newsProvider.articles.length) {
                    final article = newsProvider.articles[index];
                    return ListTile(
                      title: Text(article.title ?? "No Title"),
                      subtitle: Text(article.source.name ?? ""),
                      leading: article.urlToImage != null
                          ? Image.network(article.urlToImage!, width: 80, fit: BoxFit.cover)
                          : const Icon(Icons.image_not_supported),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => NewsWebView(url: article.url!)));
                      },
                    );
                  } else {
                    return newsProvider.hasMore ? const Center(child: CircularProgressIndicator()) : const SizedBox();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
