import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    controller.text = "Jakarta";

    Future.microtask(() {
      context.read<WeatherProvider>().fetchWeather("Jakarta");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App 🌤"),
        centerTitle: true,
      ),

      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchWeather(
                controller.text.isEmpty ? "Jakarta" : controller.text,
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  /// 🔥 OFFLINE BANNER (PINDAH KE PALING ATAS)
                  if (provider.isOffline)
                    const OfflineBanner(),

                  /// 🔍 SEARCH
                  TextField(
                    controller: controller,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: "Cari kota (contoh: Batam, Jakarta)",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          provider.fetchWeather(controller.text.trim());
                        },
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (value) {
                      provider.fetchWeather(value.trim());
                    },
                  ),

                  const SizedBox(height: 20),

                  /// 🔄 LOADING
                  if (provider.isLoading)
                    const WeatherShimmerGrid()

                  /// ❌ ERROR TANPA DATA
                  else if (provider.errorMessage.isNotEmpty &&
                      provider.currentWeather == null)
                    ErrorDisplay(
                      message: provider.errorMessage,
                      onRetry: () => provider.fetchWeather(
                        controller.text.isEmpty ? "Jakarta" : controller.text,
                      ),
                    )

                  /// ✅ DATA
                  else if (provider.currentWeather != null)
                    Column(
                      children: [
                        MainWeatherCard(
                          data: provider.currentWeather!,
                        ),

                        const SizedBox(height: 20),

                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          children: [
                            InfoCard(
                              title: "Humidity",
                              value:
                                  "${provider.currentWeather!.humidity}%",
                              icon: Icons.water_drop,
                            ),
                            InfoCard(
                              title: "Wind",
                              value:
                                  "${provider.currentWeather!.windSpeed} m/s",
                              icon: Icons.air,
                            ),
                          ],
                        ),
                      ],
                    ),

                  /// 🔴 ERROR + DATA (OFFLINE CASE)
                  if (provider.errorMessage.isNotEmpty &&
                      provider.currentWeather != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        provider.errorMessage,
                        style: const TextStyle(color: Colors.orange),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}