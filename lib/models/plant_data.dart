// lib/models/plant_data.dart

class PlantData {
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final double lightIntensity;
  final bool ledStatus;
  final int ledBrightness;
  final bool pumpStatus;
  final bool heatLedStatus; // 👈 온열등 상태 추가
  final DateTime lastUpdated;

  PlantData({
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.lightIntensity,
    required this.ledStatus,
    required this.ledBrightness,
    required this.pumpStatus,
    required this.heatLedStatus, // 👈 생성자에 추가
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
      heatLedStatus: json['heatLedStatus'] ?? false, // 👈 fromJson에 추가
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
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
      'heatLedStatus': heatLedStatus, // 👈 toJson에 추가
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}