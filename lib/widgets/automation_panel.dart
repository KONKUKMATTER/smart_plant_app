// lib/widgets/automation_panel.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/plant_service.dart';
import '../models/automation_rule.dart';
import 'automation_rule_dialog.dart';

class AutomationPanel extends StatefulWidget {
  @override
  _AutomationPanelState createState() => _AutomationPanelState();
}

class _AutomationPanelState extends State<AutomationPanel> {
  bool _isLoadingAiRules = false;
  List<AutomationRule>? _aiRecommendedRules;

  void _fetchAiRecommendedRules(String plantName) {
    setState(() {
      _isLoadingAiRules = true;
      _aiRecommendedRules = null;
    });

    Future.delayed(Duration(seconds: 2), () {
      if (!mounted) return;

      // This is a simulation. In a real scenario, you would call an AI service.
      final recommendedRules = [
        AutomationRule(
          id: 'ai_soil_moisture_rule',
          name: 'AI 추천: 토양 건조 시 물 주기',
          sensorType: 'soilMoisture',
          threshold: 30.0,
          condition: 'below',
          action: 'pump_on',
          actionValue: 120,
          isActive: true,
        ),
        AutomationRule(
          id: 'ai_temperature_rule',
          name: 'AI 추천: 서늘할 때 온열등 켜기',
          sensorType: 'temperature',
          threshold: 20.0,
          condition: 'below',
          action: 'heat_led_on', // Updated action
          isActive: true,
        ),
        AutomationRule(
          id: 'ai_light_rule',
          name: 'AI 추천: 어두울 때 조명 켜기',
          sensorType: 'lightIntensity',
          threshold: 400.0,
          condition: 'below',
          action: 'led_on',
          isActive: true,
        ),
      ];

      setState(() {
        _isLoadingAiRules = false;
        _aiRecommendedRules = recommendedRules;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlantService>(
      builder: (context, plantService, child) {
        return Column(
          children: [
            Card(
              elevation: 2,
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.blueAccent),
                        SizedBox(width: 8),
                        Text("AI 자동화 추천", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      "현재 설정된 '${plantService.plantName}'에 맞춰\nAI가 최적의 자동화 규칙을 제안해 드려요.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoadingAiRules ? null : () => _fetchAiRecommendedRules(plantService.plantName),
                        icon: Icon(Icons.recommend),
                        label: Text('AI 추천 받기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    if (_isLoadingAiRules)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (_aiRecommendedRules != null)
                      _buildAiRecommendations(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddRuleDialog(context),
                icon: Icon(Icons.add),
                label: Text('수동으로 조건 추가'),
              ),
            ),
            SizedBox(height: 16),
            if (plantService.automationRules.isEmpty)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '설정된 자동화 규칙이 없습니다.\n조건을 추가해보세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ...plantService.automationRules.map((rule) => _buildRuleCard(rule)),
          ],
        );
      },
    );
  }

  Widget _buildAiRecommendations() {
    return Container(
      padding: const EdgeInsets.only(top: 16.0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("AI 추천 규칙:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _aiRecommendedRules!.map((rule) {
              return ActionChip(
                avatar: Icon(Icons.add, size: 16, color: Colors.white),
                label: Text(_buildRuleDescription(rule), style: TextStyle(color: Colors.white)),
                onPressed: () {
                  final newRule = rule.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
                  context.read<PlantService>().addAutomationRule(newRule);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("'${rule.name}' 규칙이 추가되었습니다.")),
                  );
                },
                backgroundColor: Colors.blueAccent.withOpacity(0.8),
                shape: StadiumBorder(),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(AutomationRule rule) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          rule.isActive ? Icons.check_circle : Icons.circle_outlined,
          color: rule.isActive ? Colors.green : Colors.grey,
        ),
        title: Text(rule.name),
        subtitle: Text(_buildRuleDescription(rule)),
        trailing: PopupMenuButton(
          onSelected: (value) {
            if (value == 'edit') {
              _showEditRuleDialog(context, rule);
            } else if (value == 'delete') {
              _showDeleteConfirmDialog(context, rule);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'edit', child: Text('수정')),
            PopupMenuItem(value: 'delete', child: Text('삭제')),
          ],
        ),
        onTap: () {
          final updatedRule = rule.copyWith(isActive: !rule.isActive);
          context.read<PlantService>().updateAutomationRule(updatedRule);
        },
      ),
    );
  }

  // 시간 포맷을 H:mm 형태로 변환하는 헬퍼 함수
  String _formatTime(int timeValue) {
    final hour = (timeValue ~/ 100).toString().padLeft(2, '0');
    final minute = (timeValue % 100).toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _buildRuleDescription(AutomationRule rule) {
    String sensorName = _getSensorName(rule.sensorType);
    String conditionText = rule.condition == 'above' ? '이상' : '이하';
    String actionText = _getActionText(rule.action, rule.actionValue);
    String timeText = '';

    // 시작과 종료 시간이 모두 설정되었을 때만 시간 텍스트 추가
    if (rule.startTime != null && rule.endTime != null) {
      timeText = ' (${_formatTime(rule.startTime!)}~${_formatTime(rule.endTime!)})';
    }

    return '$sensorName ${rule.threshold}${_getUnit(rule.sensorType)} $conditionText일 때 $actionText$timeText';
  }

  String _getSensorName(String sensorType) {
    switch (sensorType) {
      case 'temperature': return '온도';
      case 'humidity': return '습도';
      case 'soilMoisture': return '토양수분';
      case 'lightIntensity': return '조도';
      default: return sensorType;
    }
  }

  String _getUnit(String sensorType) {
    switch (sensorType) {
      case 'temperature': return '°C';
      case 'humidity': return '%';
      case 'soilMoisture': return '%';
      case 'lightIntensity': return ' lux';
      default: return '';
    }
  }

  String _getActionText(String action, dynamic actionValue) {
    switch (action) {
      case 'led_on': return 'LED 켜기';
      case 'led_off': return 'LED 끄기';
      case 'pump_on': return '물 주기 (${actionValue}ml)';
      case 'led_brightness': return 'LED 밝기 ${actionValue}%';
      case 'heat_led_on': return '온열등 켜기'; // 👈 온열등 액션 추가
      default: return action;
    }
  }

  void _showAddRuleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AutomationRuleDialog(),
    );
  }

  void _showEditRuleDialog(BuildContext context, AutomationRule rule) {
    showDialog(
      context: context,
      builder: (context) => AutomationRuleDialog(rule: rule),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, AutomationRule rule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('규칙 삭제'),
        content: Text('정말로 이 규칙을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              context.read<PlantService>().deleteAutomationRule(rule.id);
              Navigator.pop(context);
            },
            child: Text('삭제'),
          ),
        ],
      ),
    );
  }
}