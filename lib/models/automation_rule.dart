// models/automation_rule.dart
class AutomationRule {
  final String id;
  final String name;
  final String sensorType; // temperature, humidity, soilMoisture, lightIntensity
  final double threshold;
  final String condition; // above, below
  final String action; // led_on, led_off, pump_on, led_brightness
  final dynamic actionValue;
  final bool isActive;

  AutomationRule({
    required this.id,
    required this.name,
    required this.sensorType,
    required this.threshold,
    required this.condition,
    required this.action,
    this.actionValue,
    required this.isActive,
  });

  factory AutomationRule.fromJson(Map<String, dynamic> json) {
    return AutomationRule(
      id: json['id'],
      name: json['name'],
      sensorType: json['sensorType'],
      threshold: (json['threshold'] ?? 0.0).toDouble(),
      condition: json['condition'],
      action: json['action'],
      actionValue: json['actionValue'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sensorType': sensorType,
      'threshold': threshold,
      'condition': condition,
      'action': action,
      'actionValue': actionValue,
      'isActive': isActive,
    };
  }
}