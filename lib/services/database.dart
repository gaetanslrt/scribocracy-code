import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scribocracy_new/models/chat.dart';
import 'package:scribocracy_new/models/web_page.dart'; // NOUVEAU

class DatabaseService {
  late Future<Isar> db;

  DatabaseService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [ChatSessionSchema, WebPageSchema], // Ajout du Schema
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  // --- NAVIGATION WEB ---

  // Appelé à chaque fois qu'une page charge
  Future<void> recordVisit(String url, String title) async {
    final isar = await db;
    
    // On nettoie l'URL (retirer les slashs de fin pour éviter les doublons)
    final cleanUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    
    await isar.writeTxn(() async {
      // On cherche si la page existe déjà
      final existingPage = await isar.webPages.filter().urlEqualTo(cleanUrl).findFirst();

      if (existingPage != null) {
        // Mise à jour
        existingPage.visitCount += 1;
        existingPage.lastVisited = DateTime.now();
        if (title.isNotEmpty && !title.contains("http")) existingPage.title = title; // Màj du titre si valide
        await isar.webPages.put(existingPage);
      } else {
        // Création
        final newPage = WebPage(
          url: cleanUrl,
          title: title.isEmpty ? cleanUrl : title,
          lastVisited: DateTime.now(),
        );
        await isar.webPages.put(newPage);
      }
    });
  }

  // Chercher des suggestions dans l'historique
  Future<List<WebPage>> findSuggestions(String query) async {
    if (query.trim().isEmpty) return [];
    
    final isar = await db;
    // Recherche insensible à la casse dans l'URL ou le Titre
    // On trie par nombre de visites pour proposer les sites les plus pertinents d'abord
    return await isar.webPages
        .filter()
        .urlContains(query, caseSensitive: false)
        .or()
        .titleContains(query, caseSensitive: false)
        .sortByVisitCountDesc()
        .limit(5) // On limite à 5 suggestions pour ne pas encombrer
        .findAll();
  }

  // Récupérer tout l'historique trié par date (du plus récent au plus vieux)
  Future<List<WebPage>> getFullHistory() async {
    final isar = await db;
    return await isar.webPages
        .where()
        .sortByLastVisitedDesc()
        .findAll();
  }

  // Supprimer une page de l'historique
  Future<void> deletePage(int id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.webPages.delete(id);
    });
  }

  // Tout effacer (pour les paramètres plus tard)
  Future<void> clearHistory() async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.webPages.clear();
    });
  }

  // Récupérer les Speed Dials (Favoris + Plus visités)
  Future<List<WebPage>> getDashboardLinks() async {
    final isar = await db;
    
    // 1. Les favoris d'abord
    final favorites = await isar.webPages
        .filter()
        .isFavoriteEqualTo(true)
        .findAll();
        
    // 2. Les top sites (si on a pas assez de favoris pour remplir la grille)
    final topSites = await isar.webPages
        .filter()
        .isFavoriteEqualTo(false)
        .sortByVisitCountDesc()
        .limit(6)
        .findAll();

    return [...favorites, ...topSites].take(8).toList();
  }

  // Ajouter/Retirer des favoris
  Future<void> toggleFavorite(String url) async {
    final isar = await db;
    final cleanUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    
    await isar.writeTxn(() async {
      final page = await isar.webPages.filter().urlEqualTo(cleanUrl).findFirst();
      if (page != null) {
        page.isFavorite = !page.isFavorite;
        await isar.webPages.put(page);
      } else {
        // Si on met en favori une page jamais visitée (rare mais possible)
        await isar.webPages.put(WebPage(url: cleanUrl, lastVisited: DateTime.now(), isFavorite: true));
      }
    });
  }
  
  // Vérifier si une page est favorite
  Future<bool> isFavorite(String url) async {
    final isar = await db;
    final cleanUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    final page = await isar.webPages.filter().urlEqualTo(cleanUrl).findFirst();
    return page?.isFavorite ?? false;
  }

  // Récupérer UNIQUEMENT les vrais favoris
  Future<List<WebPage>> getFavorites() async {
    final isar = await db;
    return await isar.webPages
        .filter()
        .isFavoriteEqualTo(true) // Le filtre strict
        .findAll();
  }

  // --- CHATS (Existant) ---
  Future<void> saveChat(ChatSession chat) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.chatSessions.put(chat);
    });
  }

  Future<List<ChatSession>> getAllChats() async {
    final isar = await db;
    return await isar.chatSessions.where().sortByLastModifiedDesc().findAll();
  }
  
  Future<void> deleteChat(Id id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.chatSessions.delete(id);
    });
  }
}