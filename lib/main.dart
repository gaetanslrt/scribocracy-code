import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:scribocracy_new/screens/browser_screen.dart'; // Importez le browser
import 'package:scribocracy_new/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scribocracy Browser',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.modernGlassTheme,
      home: const BrowserScreen(), // Nouvelle page d'accueil
    );
  }
}