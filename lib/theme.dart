import 'package:flutter/material.dart';

class AppTheme {
  // Palette Cyberpunk 2270
  static const Color voidBlack = Color(0xFF050505);
  static const Color carbon = Color(0xFF141414);
  static const Color neonCyan = Color(0xFF00F3FF);
  static const Color dangerRed = Color(0xFFFF0055);
  static const Color holoWhite = Color(0xDDFFFFFF);

  static ThemeData get cyberpunkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: voidBlack,
      primaryColor: neonCyan,
      
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: dangerRed,
        surface: carbon,
        background: voidBlack,
        error: dangerRed,
      ),

      // Typographie locale (Offline)
      textTheme: const TextTheme(
        // Titres : Orbitron
        displayLarge: TextStyle(
          fontFamily: 'Orbitron', 
          fontSize: 30, 
          fontWeight: FontWeight.bold, 
          color: neonCyan, 
          letterSpacing: 2.0
        ),
        displayMedium: TextStyle(
          fontFamily: 'Orbitron', 
          fontSize: 22, 
          fontWeight: FontWeight.w600, 
          color: Colors.white
        ),
        labelLarge: TextStyle(
          fontFamily: 'Orbitron', 
          fontSize: 14, 
          fontWeight: FontWeight.bold
        ),
        
        // Sous-titres : Orbitron (On remplace Rajdhani si vous ne l'avez pas téléchargé)
        headlineSmall: TextStyle(
          fontFamily: 'Orbitron', 
          fontSize: 18, 
          fontWeight: FontWeight.bold, 
          color: holoWhite
        ),
        
        // Corps de texte : Share Tech Mono
        bodyLarge: TextStyle(
          fontFamily: 'ShareTechMono', 
          fontSize: 16, 
          color: holoWhite, 
          height: 1.4
        ),
        bodyMedium: TextStyle(
          fontFamily: 'ShareTechMono', 
          fontSize: 14, 
          color: Colors.grey
        ),
      ),

      // Input : Style Terminal
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: carbon,
        border: const OutlineInputBorder(
           borderRadius: BorderRadius.zero,
           borderSide: BorderSide(color: Colors.grey, width: 0.5),
        ),
        enabledBorder: const OutlineInputBorder(
           borderRadius: BorderRadius.zero,
           borderSide: BorderSide(color: Colors.grey, width: 0.5),
        ),
        focusedBorder: const OutlineInputBorder(
           borderRadius: BorderRadius.zero,
           borderSide: BorderSide(color: neonCyan, width: 1.5),
        ),
        // Le hint text prend aussi le style code
        hintStyle: TextStyle(fontFamily: 'ShareTechMono', color: Colors.grey[700]),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: neonCyan,
        foregroundColor: Colors.black,
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      ),
    );
  }
}