// lib/models/automation_rule.dart

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

  // 👇 이 메서드를 추가하는 것이 중요합니다!
  AutomationRule copyWith({
    String? id,
    String? name,
    String? sensorType,
    double? threshold,
    String? condition,
    String? action,
    dynamic actionValue,
    bool? isActive,
  }) {
    return AutomationRule(
      id: id ?? this.id,
      name: name ?? this.name,
      sensorType: sensorType ?? this.sensorType,
      threshold: threshold ?? this.threshold,
      condition: condition ?? this.condition,
      action: action ?? this.action,
      actionValue: actionValue ?? this.actionValue,
      isActive: isActive ?? this.isActive,
    );
  }
}