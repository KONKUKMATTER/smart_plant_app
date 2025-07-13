// models/plant_data.dart
class PlantData {
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final double lightIntensity;
  final bool ledStatus;
  final int ledBrightness;
  final bool pumpStatus;
  final DateTime lastUpdated;

  PlantData({
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.lightIntensity,
    required this.ledStatus,
    required this.ledBrightness,
    required this.pumpStatus,
    required this.lastUpdated,
  });

  factory PlantData.fromJson(Map<String, dynamic> json) {
    return PlantData(
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      humidity: (json['humidity'] ?? 0.0).toDouble(),
      soilMoisture: (json['soilMoisture'] ?? 0.0).toDouble(),
      lightIntensity: (json['lightIntensity'] ?? 0.0).toDouble(),
      ledStatus: json['ledStatus'] ?? false,
      ledBrightness: json['ledBrightness'] ?? 0,
      pumpStatus: json['pumpStatus'] ?? false,
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'soilMoisture': soilMoisture,
      'lightIntensity': lightIntensity,
      'ledStatus': ledStatus,
      'ledBrightness': ledBrightness,
      'pumpStatus': pumpStatus,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}