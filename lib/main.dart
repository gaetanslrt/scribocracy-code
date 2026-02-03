import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribocracy_new/theme.dart'; // Notre nouveau fichier thème
import 'package:scribocracy_new/screens/browser_screen.dart';

// Import indispensable pour initialiser Isar (si vous l'utilisez déjà)
// import 'package:scribocracy_new/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // (Si vous avez déjà le code d'init de la DB ici, gardez-le)
  // final database = DatabaseService();
  // await database.init();

  runApp(const ProviderScope(child: ScribocracyApp()));
}

class ScribocracyApp extends StatelessWidget {
  const ScribocracyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scribocracy',
      debugShowCheckedModeBanner: false,

      // On utilise notre nouveau thème Tech Premium
      theme: AppTheme.modernGlassTheme,

      home: const BrowserScreen(),
    );
  }
}
