// widgets/control_panel.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/plant_service.dart';

class ControlPanel extends StatefulWidget {
  @override
  _ControlPanelState createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  double _ledBrightness = 50.0;
  bool _ledStatus = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<PlantService>(
      builder: (context, plantService, child) {
        return Column(
          children: [
            // LED 제어
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LED 제어',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('LED 상태'),
                        Switch(
                          value: _ledStatus,
                          onChanged: (value) {
                            setState(() {
                              _ledStatus = value;
                            });
                            plantService.controlLED(value);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text('밝기 조절'),
                    Slider(
                      value: _ledBrightness,
                      min: 0,
                      max: 100,
                      divisions: 10,
                      label: '${_ledBrightness.toInt()}%',
                      onChanged: (value) {
                        setState(() {
                          _ledBrightness = value;
                        });
                      },
                      onChangeEnd: (value) {
                        plantService.adjustLEDBrightness(value.toInt());
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // 펌프 제어
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '물 주기',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => plantService.activatePump(50),
                            child: Text('50ml'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => plantService.activatePump(100),
                            child: Text('100ml'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => plantService.activatePump(150),
                            child: Text('150ml'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}