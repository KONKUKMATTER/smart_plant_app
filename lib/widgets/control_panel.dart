// lib/widgets/control_panel.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/plant_service.dart';

class ControlPanel extends StatefulWidget {
  @override
  _ControlPanelState createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  // UI의 즉각적인 반응을 위한 로컬 상태 변수
  bool _ledStatus = false;
  bool _heatLedStatus = false;

  @override
  void initState() {
    super.initState();
    // 위젯이 처음 생성될 때 서버의 초기 상태를 한 번만 가져와 로컬 변수에 할당합니다.
    final plantService = Provider.of<PlantService>(context, listen: false);
    _ledStatus = plantService.currentData?.ledStatus ?? false;
    _heatLedStatus = plantService.currentData?.heatLedStatus ?? false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Provider를 통해 서버 데이터가 변경될 때마다 이 함수가 호출됩니다.
    // (예: 자동화 규칙에 의해 상태가 바뀔 때)
    final plantService = Provider.of<PlantService>(context);
    final serverLedStatus = plantService.currentData?.ledStatus ?? false;
    final serverHeatLedStatus = plantService.currentData?.heatLedStatus ?? false;

    // 서버 상태와 UI 상태가 다를 경우, 서버의 상태를 신뢰하여 UI를 동기화합니다.
    if (_ledStatus != serverLedStatus) {
      setState(() {
        _ledStatus = serverLedStatus;
      });
    }
    if (_heatLedStatus != serverHeatLedStatus) {
      setState(() {
        _heatLedStatus = serverHeatLedStatus;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // build 메서드에서는 Provider를 listen할 필요가 없습니다. didChangeDependencies가 역할을 대신합니다.
    final plantService = Provider.of<PlantService>(context, listen: false);

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
                      value: _ledStatus, // 로컬 상태 변수를 사용해 즉시 반응
                      onChanged: (value) {
                        // 1. UI를 즉시 업데이트 (낙관적 업데이트)
                        setState(() {
                          _ledStatus = value;
                        });
                        // 2. 서버에 명령 전송
                        plantService.controlLED(value);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),

        // 온열등 제어 카드
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '온열등 제어',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('온열등 상태'),
                    Switch(
                      value: _heatLedStatus, // 로컬 상태 변수를 사용해 즉시 반응
                      onChanged: (value) {
                        // 1. UI를 즉시 업데이트 (낙관적 업데이트)
                        setState(() {
                          _heatLedStatus = value;
                        });
                        // 2. 서버에 명령 전송
                        plantService.controlHeatLed(value);
                      },
                      activeColor: Colors.orangeAccent,
                    ),
                  ],
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
  }
}