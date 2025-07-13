// widgets/automation_panel.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/plant_service.dart';
import '../models/automation_rule.dart';
import 'automation_rule_dialog.dart';

class AutomationPanel extends StatefulWidget {
  @override
  _AutomationPanelState createState() => _AutomationPanelState();
}

class _AutomationPanelState extends State<AutomationPanel> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PlantService>(
      builder: (context, plantService, child) {
        return Column(
          children: [
            // 자동화 규칙 추가 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddRuleDialog(context),
                icon: Icon(Icons.add),
                label: Text('조건 추가'),
              ),
            ),
            SizedBox(height: 16),
            // 자동화 규칙 목록
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
          final updatedRule = AutomationRule(
            id: rule.id,
            name: rule.name,
            sensorType: rule.sensorType,
            threshold: rule.threshold,
            condition: rule.condition,
            action: rule.action,
            actionValue: rule.actionValue,
            isActive: !rule.isActive,
          );
          context.read<PlantService>().updateAutomationRule(updatedRule);
        },
      ),
    );
  }

  String _buildRuleDescription(AutomationRule rule) {
    String sensorName = _getSensorName(rule.sensorType);
    String conditionText = rule.condition == 'above' ? '이상' : '이하';
    String actionText = _getActionText(rule.action, rule.actionValue);

    return '$sensorName ${rule.threshold}${_getUnit(rule.sensorType)} $conditionText일 때 $actionText';
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
