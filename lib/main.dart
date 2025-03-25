import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'news_page.dart';
import 'login_page.dart';
import 'news_provider.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  String? authToken = await storage.read(key: 'auth_token');
  runApp(MyApp(startPage: authToken != null ? const NewsPage() : const LoginPage()));
}
class MyApp extends StatelessWidget {
  final Widget startPage;
  const MyApp({super.key, required this.startPage});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NewsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter News App',
        theme: ThemeData(),
        home: startPage,
      ),
    );
  }
}
