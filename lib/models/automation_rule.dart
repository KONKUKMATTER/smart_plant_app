// lib/models/automation_rule.dart

class AutomationRule {
  final String id;
  final String name;
  final String sensorType;
  final double threshold;
  final String condition;
  final String action;
  final dynamic actionValue;
  final bool isActive;
  final int? startTime; // 👈 시작 시간 추가 (예: 1230 -> 12:30)
  final int? endTime;   // 👈 종료 시간 추가 (예: 1830 -> 18:30)

  AutomationRule({
    required this.id,
    required this.name,
    required this.sensorType,
    required this.threshold,
    required this.condition,
    required this.action,
    this.actionValue,
    required this.isActive,
    this.startTime, // 👈 생성자에 추가
    this.endTime,   // 👈 생성자에 추가
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
      startTime: json['startTime'], // 👈 fromJson에 추가
      endTime: json['endTime'],     // 👈 fromJson에 추가
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
      'startTime': startTime, // 👈 toJson에 추가
      'endTime': endTime,     // 👈 toJson에 추가
    };
  }

  AutomationRule copyWith({
    String? id,
    String? name,
    String? sensorType,
    double? threshold,
    String? condition,
    String? action,
    dynamic actionValue,
    bool? isActive,
    int? startTime,
    int? endTime,
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
      // copyWith는 null로 값을 덮어쓸 수 있도록 수정
      startTime: startTime,
      endTime: endTime,
    );
  }
}