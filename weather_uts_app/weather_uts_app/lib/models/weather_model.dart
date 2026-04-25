class Weather {
  final String cityName;
  final double temp;
  final String condition;
  final int humidity;
  final double windSpeed;
  final String iconCode;

  Weather({
    required this.cityName,
    required this.temp,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.iconCode,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temp: json['main']['temp'].toDouble(),
      condition: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      iconCode: json['weather'][0]['icon'],
    );
  }
}