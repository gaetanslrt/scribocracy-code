import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // On utilise Open-Meteo (Gratuit, pas de clé API)
  // Ici hardcodé sur Paris pour l'exemple, mais on pourrait utiliser la géolocalisation
  static const String _url = "https://api.open-meteo.com/v1/forecast?latitude=48.8566&longitude=2.3522&current=temperature_2m,weather_code&timezone=auto";

  Future<Map<String, dynamic>?> getCurrentWeather() async {
    try {
      final response = await http.get(Uri.parse(_url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current'];
        
        return {
          'temp': current['temperature_2m'].round(),
          'code': current['weather_code'], // Code WMO (0=Soleil, 1-3=Nuages, etc.)
        };
      }
    } catch (e) {
      // En cas d'erreur (pas d'internet), on renvoie null
      print("Erreur météo: $e");
    }
    return null;
  }
  
  String getWeatherLabel(int code) {
    if (code == 0) return "Ensoleillé";
    if (code >= 1 && code <= 3) return "Nuageux";
    if (code >= 45 && code <= 48) return "Brouillard";
    if (code >= 51 && code <= 67) return "Pluvieux";
    if (code >= 71) return "Neige";
    return "Variable";
  }
}