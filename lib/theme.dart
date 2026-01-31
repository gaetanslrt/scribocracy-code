import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- PALETTE IDENTITÉ VISUELLE ---
  
  // Fond principal : Luster White (Papier chaud)
  static const Color lusterWhite = Color(0xFFF4F1EC); 
  
  // Accents doux : Aster Flower Blue
  static const Color asterBlue = Color(0xFF9BACD8);
  
  // Action / Highlight : Habañero (Orange vif)
  static const Color habanero = Color(0xFFF98513);
  
  // Textes (On garde un noir doux pour le contraste sur le blanc crème)
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color greyText = Color(0xFF6E6E73);

  // --- CONFIGURATION THÈME ---

  static ThemeData get modernGlassTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lusterWhite, // Le fond crème
      primaryColor: asterBlue,
      
      colorScheme: const ColorScheme.light(
        primary: asterBlue,
        secondary: habanero,
        surface: lusterWhite,
        onSurface: darkText,
        background: lusterWhite,
      ),
      
      // --- TYPOGRAPHIE ---
      textTheme: TextTheme(
        // TITRES : Playfair Display (Élégant, Sérif)
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32, 
          fontWeight: FontWeight.w700, 
          color: darkText,
          letterSpacing: -0.5
        ),
        headlineSmall: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkText
        ),
        
        // CORPS DE TEXTE : Montserrat (Moderne, Sans-Sérif)
        bodyLarge: GoogleFonts.montserrat(
          fontSize: 16, 
          height: 1.5, 
          color: darkText, 
          fontWeight: FontWeight.w500
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 14, 
          color: greyText,
          fontWeight: FontWeight.w500
        ),
        titleMedium: GoogleFonts.montserrat( // Pour les champs de texte
          fontSize: 16,
          color: darkText,
          fontWeight: FontWeight.w600
        ),
      ),

      // Styles globaux
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: darkText),
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20, fontWeight: FontWeight.w700, color: darkText
        )
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.5),
        hintStyle: GoogleFonts.montserrat(color: Colors.black38),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}