// widgets/automation_rule_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/plant_service.dart';
import '../models/automation_rule.dart';

class AutomationRuleDialog extends StatefulWidget {
  final AutomationRule? rule;

  const AutomationRuleDialog({Key? key, this.rule}) : super(key: key);

  @override
  _AutomationRuleDialogState createState() => _AutomationRuleDialogState();
}

class _AutomationRuleDialogState extends State<AutomationRuleDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _thresholdController;
  late TextEditingController _actionValueController;

  String _sensorType = 'temperature';
  String _condition = 'above';
  String _action = 'led_on';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _thresholdController = TextEditingController();
    _actionValueController = TextEditingController();

    if (widget.rule != null) {
      _nameController.text = widget.rule!.name;
      _thresholdController.text = widget.rule!.threshold.toString();
      _sensorType = widget.rule!.sensorType;
      _condition = widget.rule!.condition;
      _action = widget.rule!.action;
      _actionValueController.text = widget.rule!.actionValue?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _thresholdController.dispose();
    _actionValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.rule == null ? '자동화 규칙 추가' : '자동화 규칙 수정'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '규칙 이름'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '규칙 이름을 입력하세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _sensorType,
                decoration: InputDecoration(labelText: '센서 종류'),
                items: [
                  DropdownMenuItem(value: 'temperature', child: Text('온도')),
                  DropdownMenuItem(value: 'humidity', child: Text('습도')),
                  DropdownMenuItem(value: 'soilMoisture', child: Text('토양수분')),
                  DropdownMenuItem(value: 'lightIntensity', child: Text('조도')),
                ],
                onChanged: (value) {
                  setState(() {
                    _sensorType = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _thresholdController,
                      decoration: InputDecoration(labelText: '기준값'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '기준값을 입력하세요';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _condition,
                      decoration: InputDecoration(labelText: '조건'),
                      items: [
                        DropdownMenuItem(value: 'above', child: Text('이상')),
                        DropdownMenuItem(value: 'below', child: Text('이하')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _condition = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _action,
                decoration: InputDecoration(labelText: '동작'),
                items: [
                  DropdownMenuItem(value: 'led_on', child: Text('LED 켜기')),
                  DropdownMenuItem(value: 'led_off', child: Text('LED 끄기')),
                  DropdownMenuItem(value: 'pump_on', child: Text('물 주기')),
                  DropdownMenuItem(value: 'led_brightness', child: Text('LED 밝기 조절')),
                ],
                onChanged: (value) {
                  setState(() {
                    _action = value!;
                  });
                },
              ),
              if (_action == 'pump_on' || _action == 'led_brightness')
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: TextFormField(
                    controller: _actionValueController,
                    decoration: InputDecoration(
                      labelText: _action == 'pump_on' ? '물 양 (ml)' : '밝기 (%)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '값을 입력하세요';
                      }
                      return null;
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('취소'),
        ),
        TextButton(
          onPressed: _saveRule,
          child: Text('저장'),
        ),
      ],
    );
  }

  void _saveRule() {
    if (_formKey.currentState!.validate()) {
      final rule = AutomationRule(
        id: widget.rule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        sensorType: _sensorType,
        threshold: double.parse(_thresholdController.text),
        condition: _condition,
        action: _action,
        actionValue: _actionValueController.text.isNotEmpty
            ? int.parse(_actionValueController.text)
            : null,
        isActive: widget.rule?.isActive ?? true,
      );

      if (widget.rule == null) {
        context.read<PlantService>().addAutomationRule(rule);
      } else {
        context.read<PlantService>().updateAutomationRule(rule);
      }

      Navigator.pop(context);
    }
  }
}