import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';

class WeatherService {
  final String apiKey = "7fc6a1acdd702839c19584eb30c13192";

  bool isFromCache = false;

  /// 🔥 FETCH DARI API + SIMPAN CACHE
  Future<Weather> fetchWeather(String city) async {
    final prefs = await SharedPreferences.getInstance();
    String queryKey = city.trim().toLowerCase();

    try {
      isFromCache = false;

      Uri url;

      if (queryKey.contains("batam")) {
        url = Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?lat=1.0456&lon=104.0305&appid=$apiKey&units=metric",
        );
      } else {
        url = Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?q=${city.trim()},ID&appid=$apiKey&units=metric",
        );
      }

      final response = await http.get(url);

      if (response.statusCode == 200) {
        await prefs.setString("weather_$queryKey", response.body);

        return Weather.fromJson(json.decode(response.body));
      } else {
        throw Exception("API Error");
      }
    } catch (e) {
      final cached = prefs.getString("weather_$queryKey");

      if (cached != null) {
        isFromCache = true;
        return Weather.fromJson(json.decode(cached));
      } else {
        throw Exception("No Cache");
      }
    }
  }

  /// 🔥 AMBIL CACHE LANGSUNG (UNTUK OFFLINE)
  Future<Weather?> getCachedWeather(String city) async {
    final prefs = await SharedPreferences.getInstance();
    String queryKey = city.trim().toLowerCase();

    final cached = prefs.getString("weather_$queryKey");

    if (cached != null) {
      return Weather.fromJson(json.decode(cached));
    }

    return null;
  }
}