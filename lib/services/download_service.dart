import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadService {
  final Dio _dio = Dio();

  // Télécharger une image et la mettre dans la Galerie
  Future<bool> downloadImageToGallery(String url) async {
    try {
      // 1. Demander les permissions
      if (!await _requestPermission()) return false;

      // 2. Créer un chemin temporaire
      final tempDir = await getTemporaryDirectory();
      final String fileName = "scribo_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final String filePath = '${tempDir.path}/$fileName';

      // 3. Télécharger le fichier
      await _dio.download(url, filePath);

      // 4. Sauvegarder dans la galerie via GAL
      await Gal.putImage(filePath);
      
      // 5. Nettoyage
      File(filePath).delete();
      
      return true;
    } catch (e) {
      print("Erreur téléchargement: $e");
      return false;
    }
  }

  // Vérification des permissions
  Future<bool> _requestPermission() async {
    // Sur Android récent et iOS, GAL gère souvent ça tout seul, mais c'est une sécurité
    await Gal.requestAccess();
    return await Gal.hasAccess();
  }
}