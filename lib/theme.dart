import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ===========================================================================
  // 1. NOUVELLE IDENTITÉ VISUELLE (STYLE "TECH PREMIUM")
  // ===========================================================================

  // PRIMARY : "Indigo Electric" (Remplaçant du Habanero)
  // C'est la couleur de l'action, de la tech et de la confiance.
  static const Color primaryBrand = Color(0xFF4F46E5);

  // SECONDARY : "Sky Blue" (Pour les accents subtils)
  static const Color accentBrand = Color(0xFF0EA5E9);

  // NEUTRAL : "Slate" (Gris bleuté moderne, pas juste gris)
  static const Color greyText = Color(0xFF64748B);

  // ===========================================================================
  // 2. THÈME CLAIR (LIGHT MODE) - Style "Clean SaaS"
  // ===========================================================================
  // Un blanc cassé très froid, presque bleuté, très propre.
  static const Color lightBackground = Color(0xFFF8FAFC);

  // Blanc pur pour les surfaces
  static const Color lightSurface = Colors.white;

  // Texte : Un "Gunmetal" foncé, plus doux que le noir pur
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);

  // Bordures très fines et subtiles
  static const Color lightBorder = Color(0xFFE2E8F0);

  // ===========================================================================
  // 3. THÈME SOMBRE (DARK MODE) - Style "Deep Space"
  // ===========================================================================
  // Fini le noir #000000. On part sur un bleu nuit très profond.
  static const Color darkBackground = Color(0xFF020617);

  // Surface légèrement plus claire
  static const Color darkSurface = Color(0xFF0F172A);

  // Texte blanc cassé
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Bordures sombres
  static const Color darkBorder = Color(0xFF1E293B);

  // ===========================================================================
  // 4. ALIAS DE COMPATIBILITÉ (POUR NE RIEN CASSER)
  // ===========================================================================
  // L'ancien "Habanero" pointe maintenant vers notre nouvel Indigo
  static const Color habanero = primaryBrand;
  static const Color asterBlue = accentBrand;

  static const Color lusterWhite = lightBackground;
  static const Color darkText = lightTextPrimary; // L'ancien "Texte par défaut"

  // ===========================================================================
  // 5. CONFIGURATION GLOBALE DU THÈME
  // ===========================================================================
  static ThemeData get modernGlassTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: primaryBrand,

      // On applique la nouvelle police "Plus Jakarta Sans" partout
      textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
        bodyColor: lightTextPrimary,
        displayColor: lightTextPrimary,
      ),

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBrand,
        surface: lightSurface,
        // On force la brightness pour que les textes s'adaptent
        brightness: Brightness.light,
      ),
    );
  }
}
