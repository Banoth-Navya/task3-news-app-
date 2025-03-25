import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
class NewsWebView extends StatefulWidget {
  final String url;
  const NewsWebView({super.key, required this.url});
  @override
  State<NewsWebView> createState() => _NewsWebViewState();
}
class _NewsWebViewState extends State<NewsWebView> {
  late WebViewController _controller;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    final WebViewController controller = WebViewController.fromPlatformCreationParams(
      const PlatformWebViewControllerCreationParams(),
    )..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    _controller = controller;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("NEWS NOW"),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}