import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final aiServiceProvider = Provider((ref) => AIService());

class AIService {
  late final GenerativeModel _model;

  AIService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception("No API Key found in .env");
    }
    // MISE À JOUR : On utilise le modèle le plus rapide et actuel
    _model = GenerativeModel(model: 'gemini-flash-latest', apiKey: apiKey);
  }

  Future<String?> processText(String text, String command) async {
    if (text.isEmpty) return null;

    String prompt = "";
    
    switch (command) {
      case 'SUMMARIZE':
        prompt = "Tout en conservant la langue du texte, résume et synthétise ce texte de manière courte, concise et factuelle (style rapport militaire) :\n\n$text";
        break;
      case 'PROFESSIONALIZE':
        prompt = "Tout en conservant la langue du texte, réécris ce message pour qu'il froid et professionnel. Utilise un vocabulaire précis. :\n\n$text";
        break;
      case 'CLEANUP':
        prompt = "Tout en conservant la langue du texte, corrige les fautes, améliore la syntaxe, rend le texte plus percutant :\n\n$text";
        break;
      case 'EXTRACT':
        prompt = "Tout en conservant la langue du texte, extrais uniquement les entités importantes (Noms, Lieux, Dates, Sommes d'argent, etc...) sous forme de liste à puces :\n\n$text";
        break;
    }

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text;
    } catch (e) {
      // En cas d'erreur, on retourne un message "système" stylisé
      return "NEURAL_LINK_FAILURE: ${e.toString().split(']').last.trim()}"; 
    }
  }
}