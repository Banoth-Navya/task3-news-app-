import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'news_provider.dart';
import 'news_web_view.dart';
import 'login_page.dart';
import 'theme_provider.dart';
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
    var themeProvider = Provider.of<ThemeProvider>(context); // Access ThemeProvider
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("NEWS NOW"),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          // Logout Button
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewsWebView(url: article.url!),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (article.urlToImage != null)
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                  child: Image.network(
                                    article.urlToImage!,
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(child: CircularProgressIndicator());
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(child: Icon(Icons.image_not_supported, size: 80));
                                    },
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      article.title ?? "No Title",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      article.source.name ?? "",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return newsProvider.hasMore
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox();
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
