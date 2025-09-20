// lib/widgets/automation_rule_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/automation_rule.dart';
import '../services/plant_service.dart';

class AutomationRuleDialog extends StatefulWidget {
  final AutomationRule? rule;

  AutomationRuleDialog({this.rule});

  @override
  _AutomationRuleDialogState createState() => _AutomationRuleDialogState();
}

class _AutomationRuleDialogState extends State<AutomationRuleDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _sensorType;
  late double _threshold;
  late String _condition;
  late String _action;
  dynamic _actionValue;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _useTimeSettings = false;

  @override
  void initState() {
    super.initState();
    _name = widget.rule?.name ?? '';
    _sensorType = widget.rule?.sensorType ?? 'temperature';
    _threshold = widget.rule?.threshold ?? 20.0;
    _condition = widget.rule?.condition ?? 'below';
    _action = widget.rule?.action ?? 'led_on';
    _actionValue = widget.rule?.actionValue;

    if (widget.rule?.startTime != null && widget.rule?.endTime != null) {
      _useTimeSettings = true;
      _startTime = TimeOfDay(hour: widget.rule!.startTime! ~/ 100, minute: widget.rule!.startTime! % 100);
      _endTime = TimeOfDay(hour: widget.rule!.endTime! ~/ 100, minute: widget.rule!.endTime! % 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.rule == null ? '새 규칙 추가' : '규칙 수정'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: '규칙 이름'),
                validator: (value) => value!.isEmpty ? '이름을 입력하세요' : null,
                onSaved: (value) => _name = value!,
              ),
              DropdownButtonFormField<String>(
                value: _sensorType,
                decoration: InputDecoration(labelText: '센서'),
                items: [
                  DropdownMenuItem(value: 'temperature', child: Text('온도')),
                  DropdownMenuItem(value: 'humidity', child: Text('습도')),
                  DropdownMenuItem(value: 'soilMoisture', child: Text('토양 수분')),
                  DropdownMenuItem(value: 'lightIntensity', child: Text('조도')),
                ],
                onChanged: (value) => setState(() => _sensorType = value!),
              ),
              DropdownButtonFormField<String>(
                value: _condition,
                decoration: InputDecoration(labelText: '조건'),
                items: [
                  DropdownMenuItem(value: 'below', child: Text('이하일 때')),
                  DropdownMenuItem(value: 'above', child: Text('이상일 때')),
                ],
                onChanged: (value) => setState(() => _condition = value!),
              ),
              TextFormField(
                initialValue: _threshold.toString(),
                decoration: InputDecoration(labelText: '기준값'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? '기준값을 입력하세요' : null,
                onSaved: (value) => _threshold = double.parse(value!),
              ),
              DropdownButtonFormField<String>(
                value: _action,
                decoration: InputDecoration(labelText: '실행'),
                items: [
                  DropdownMenuItem(value: 'led_on', child: Text('LED 켜기')),
                  DropdownMenuItem(value: 'led_off', child: Text('LED 끄기')),
                  DropdownMenuItem(value: 'pump_on', child: Text('물 주기')),
                  DropdownMenuItem(value: 'led_brightness', child: Text('LED 밝기 조절')),
                  DropdownMenuItem(value: 'heat_led_on', child: Text('온열등 켜기')),
                  DropdownMenuItem(value: 'heat_led_off', child: Text('온열등 끄기')), // 👈 **'온열등 끄기' 옵션 추가**
                ],
                onChanged: (value) => setState(() => _action = value!),
              ),
              if (_action == 'pump_on' || _action == 'led_brightness')
                TextFormField(
                  initialValue: _actionValue?.toString() ?? '',
                  decoration: InputDecoration(labelText: _action == 'pump_on' ? '급수량 (ml)' : '밝기 (%)'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _actionValue = int.tryParse(value ?? ''),
                ),
              SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _useTimeSettings,
                    onChanged: (value) {
                      setState(() {
                        _useTimeSettings = value ?? false;
                        if (!_useTimeSettings) {
                          _startTime = null;
                          _endTime = null;
                        }
                      });
                    },
                  ),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          _useTimeSettings = !_useTimeSettings;
                          if (!_useTimeSettings) {
                            _startTime = null;
                            _endTime = null;
                          }
                        });
                      },
                      child: Text("특정 시간에만 규칙 활성화")
                  ),
                ],
              ),
              if (_useTimeSettings)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("시작: ${_startTime?.format(context) ?? '미설정'}"),
                          ElevatedButton(
                            onPressed: () async {
                              final time = await showTimePicker(context: context, initialTime: _startTime ?? TimeOfDay(hour: 8, minute: 0));
                              if (time != null) setState(() => _startTime = time);
                            },
                            child: Text("선택"),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("종료: ${_endTime?.format(context) ?? '미설정'}"),
                          ElevatedButton(
                            onPressed: () async {
                              final time = await showTimePicker(context: context, initialTime: _endTime ?? TimeOfDay(hour: 18, minute: 0));
                              if (time != null) setState(() => _endTime = time);
                            },
                            child: Text("선택"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('취소')),
        TextButton(onPressed: _saveRule, child: Text('저장')),
      ],
    );
  }

  void _saveRule() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final plantService = context.read<PlantService>();

      final int? startTime = _useTimeSettings ? (_startTime != null ? _startTime!.hour * 100 + _startTime!.minute : null) : null;
      final int? endTime = _useTimeSettings ? (_endTime != null ? _endTime!.hour * 100 + _endTime!.minute : null) : null;

      final newRule = AutomationRule(
        id: widget.rule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _name,
        sensorType: _sensorType,
        threshold: _threshold,
        condition: _condition,
        action: _action,
        actionValue: _actionValue,
        isActive: widget.rule?.isActive ?? true,
        startTime: startTime,
        endTime: endTime,
      );

      if (widget.rule == null) {
        plantService.addAutomationRule(newRule);
      } else {
        plantService.updateAutomationRule(newRule);
      }
      Navigator.pop(context);
    }
  }
}