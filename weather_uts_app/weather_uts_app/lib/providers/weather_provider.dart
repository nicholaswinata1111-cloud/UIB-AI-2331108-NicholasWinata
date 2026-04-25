import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _service = WeatherService();

  Weather? currentWeather;

  bool isLoading = false;
  bool isOffline = false;
  String errorMessage = "";

  Future<void> fetchWeather(String city) async {
    if (city.trim().isEmpty) {
      errorMessage = "Masukkan nama kota terlebih dahulu";
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = "";
    notifyListeners();

    try {
      final data = await _service.fetchWeather(city);

      currentWeather = data;

      // 🔥 dari cache = offline
      isOffline = _service.isFromCache;

    } catch (e) {
      // 🔥 INI YANG PALING PENTING
      currentWeather = null; // ❌ HAPUS DATA LAMA

      isOffline = false;

      errorMessage =
          "Data tidak tersedia saat offline.\nSilakan cari saat online dulu.";
    }

    isLoading = false;
    notifyListeners();
  }
}