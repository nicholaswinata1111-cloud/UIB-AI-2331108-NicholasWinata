import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/weather_model.dart';

/// =======================
/// 🔹 OFFLINE BANNER
/// =======================
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, color: Colors.white),
          SizedBox(width: 8),
          Text(
            "Mode Offline - Menampilkan data terakhir",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// 🔹 INFO CARD
/// =======================
class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue.shade50,
            child: Icon(icon, color: Colors.blueAccent, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// 🔹 MAIN WEATHER CARD
/// =======================
class MainWeatherCard extends StatelessWidget {
  final Weather data;

  const MainWeatherCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Image.network(
            "https://openweathermap.org/img/wn/${data.iconCode}@4x.png",
            height: 110,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.cloud_off, size: 100, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            data.cityName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "${data.temp.toStringAsFixed(1)}°C",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 55,
              fontWeight: FontWeight.w200,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            data.condition.toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// 🔹 SHIMMER LOADING
/// =======================
class WeatherShimmerGrid extends StatelessWidget {
  const WeatherShimmerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// =======================
/// 🔹 ERROR DISPLAY
/// =======================
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorDisplay({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }
}