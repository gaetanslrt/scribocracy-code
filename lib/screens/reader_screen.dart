import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:scribocracy_new/theme.dart';
import 'package:scribocracy_new/widgets/glass_container.dart';
import 'package:scribocracy_new/widgets/background_scaffold.dart';

class ReaderScreen extends StatefulWidget {
  final String title;
  final String htmlContent;

  const ReaderScreen({super.key, required this.title, required this.htmlContent});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.lusterWhite)
      ..loadHtmlString(_buildHtmlPage());
  }

  // On construit une page HTML locale avec VOTRE design
  String _buildHtmlPage() {
    return """
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,700;1,400&family=Montserrat:wght@400;500;600&display=swap" rel="stylesheet">
        <style>
          body {
            background-color: #F4F1EC; /* Luster White */
            color: #1A1A1A; /* Dark Text */
            font-family: 'Playfair Display', serif; /* Police principale */
            font-size: 18px;
            line-height: 1.8;
            padding: 20px;
            margin: 0;
          }
          h1 { font-size: 32px; font-weight: 700; margin-bottom: 10px; line-height: 1.2; }
          h2, h3 { font-family: 'Montserrat', sans-serif; font-weight: 600; margin-top: 30px; }
          p { margin-bottom: 20px; }
          img { max-width: 100%; height: auto; border-radius: 12px; margin: 20px 0; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
          a { color: #F98513; text-decoration: none; border-bottom: 1px solid #F98513; } /* Liens Habanero */
          blockquote { border-left: 4px solid #F98513; padding-left: 15px; font-style: italic; color: #6E6E73; }
          
          /* Nettoyage des éléments inutiles qui auraient pu survivre */
          nav, footer, .ad, .advertisement, button { display: none !important; }
        </style>
      </head>
      <body>
        <h1>${widget.title}</h1>
        <hr style="border: 0; border-top: 1px solid #9BACD8; margin: 20px 0 40px 0; opacity: 0.5;">
        ${widget.htmlContent}
        <div style="height: 100px; display: flex; align-items: center; justify-content: center; opacity: 0.5; margin-top: 50px;">
          <span style="font-family: 'Montserrat'; font-size: 12px; color: #6E6E73;">LECTURE ZEN PAR SCRIBOCRACY</span>
        </div>
      </body>
      </html>
    """;
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      // AppBar flottante pour fermer
      appBar: AppBar(
        backgroundColor: AppTheme.lusterWhite.withOpacity(0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Mode Lecture", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.format_size, color: AppTheme.darkText),
            onPressed: () {
              // Idée pour plus tard : Changer la taille de la police
            },
          )
        ],
      ),
      child: WebViewWidget(controller: _controller),
    );
  }
}