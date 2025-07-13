// models/watering_history.dart
class WateringHistory {
  final DateTime timestamp;
  final int amount; // ml
  final bool isAutomatic;

  WateringHistory({
    required this.timestamp,
    required this.amount,
    required this.isAutomatic,
  });

  factory WateringHistory.fromJson(Map<String, dynamic> json) {
    return WateringHistory(
      timestamp: DateTime.parse(json['timestamp']),
      amount: json['amount'],
      isAutomatic: json['isAutomatic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'amount': amount,
      'isAutomatic': isAutomatic,
    };
  }
}