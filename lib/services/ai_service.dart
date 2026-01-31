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
    
    _model = GenerativeModel(
      model: 'gemini-flash-latest', 
      apiKey: apiKey,
      // MISE A JOUR DE LA PERSONNALITE
      systemInstruction: Content.system(
        "Tu es le Concierge Exécutif de Scribocracy. "
        "Tu as accès aux notes personnelles de l'utilisateur (fournies en contexte). "
        "Ta mission est d'utiliser ces informations pour répondre précisément aux questions. "
        "Si la réponse se trouve dans les notes fournies, cite-les explicitement. "
        "Si l'information n'est pas dans les notes, utilise tes connaissances générales mais précise-le. "
        "Ton ton est professionnel, concis et élégant."
      ),
    );
  }

  // Mode simple (pour les boutons rapides dans l'éditeur)
  Future<String?> processText(String text, String command) async {
    // ... (Code existant inchangé, gardez-le ou copiez depuis l'ancien fichier)
    if (text.isEmpty) return null;
    String prompt = "";
    switch (command) {
      case 'SUMMARIZE': prompt = "Résume ceci avec élégance :\n\n$text"; break;
      case 'CLEANUP': prompt = "Corrige et améliore le style :\n\n$text"; break;
      default: prompt = text;
    }
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text;
    } catch (e) {
      return "Indisponible.";
    }
  }

  // Mode Chat (Avec mémoire)
  Future<String?> chatWithHistory(List<Content> history, String newMessage) async {
    try {
      final chat = _model.startChat(history: history);
      final response = await chat.sendMessage(Content.text(newMessage));
      return response.text;
    } catch (e) {
      return "Erreur de connexion IA: $e";
    }
  }
}