// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/plant_service.dart';
import '../models/plant_data.dart';
import '../models/automation_rule.dart';
import '../widgets/sensor_card.dart';
import '../widgets/control_panel.dart';
import '../widgets/automation_panel.dart';
import '../widgets/watering_history_panel.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlantService>(
      builder: (context, plantService, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(plantService.plantName),
            centerTitle: true,
            actions: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: plantService.isAutoMode ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      plantService.isAutoMode ? Icons.auto_mode : Icons.touch_app,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      plantService.isAutoMode ? '자동 모드' : '수동 모드',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: '센서 정보'),
                Tab(text: '제어'),
                Tab(text: '기록'),
              ],
            ),
          ),
          body: Column(
            children: [
              // 상태 정보 헤더
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.grey[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '오늘 날짜',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Text(
                          DateFormat('yyyy년 MM월 dd일').format(DateTime.now()),
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '오늘 물 준 횟수',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Text(
                          '${plantService.getTodayWateringCount()}회',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 모드 전환 버튼
              Container(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => plantService.toggleAutoMode(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: plantService.isAutoMode ? Colors.black26 : Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      plantService.isAutoMode ? '수동 모드로 전환' : '자동 모드로 전환',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
              // 탭 컨텐츠
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SensorInfoTab(),
                    ControlTab(),
                    HistoryTab(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 센서 정보 탭
class SensorInfoTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PlantService>(
      builder: (context, plantService, child) {
        final data = plantService.currentData;

        if (data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('센서 데이터를 불러오는 중...'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SensorCard(
                title: '온도',
                value: '${data.temperature.toStringAsFixed(1)}°C',
                icon: Icons.thermostat,
                color: Colors.red,
              ),
              SensorCard(
                title: '습도',
                value: '${data.humidity.toStringAsFixed(1)}%',
                icon: Icons.water_drop,
                color: Colors.blue,
              ),
              SensorCard(
                title: '토양 수분',
                value: '${data.soilMoisture.toStringAsFixed(1)}%',
                icon: Icons.grass,
                color: Colors.brown,
              ),
              SensorCard(
                title: '조도',
                value: '${data.lightIntensity.toStringAsFixed(0)} lux',
                icon: Icons.light_mode,
                color: Colors.orange,
              ),
              SensorCard(
                title: 'LED 상태',
                value: data.ledStatus ? 'ON (${data.ledBrightness}%)' : 'OFF',
                icon: Icons.lightbulb,
                color: data.ledStatus ? Colors.green : Colors.grey,
              ),
              SensorCard(
                title: '펌프 상태',
                value: data.pumpStatus ? '작동중' : '정지',
                icon: Icons.water_drop_rounded,
                color: data.pumpStatus ? Colors.green : Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                '최종 업데이트: ${DateFormat('HH:mm:ss').format(data.lastUpdated)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 제어 탭
class ControlTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PlantService>(
      builder: (context, plantService, child) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              if (!plantService.isAutoMode) ...[
                Text(
                  '수동 제어',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                ControlPanel(),
                SizedBox(height: 32),
              ],
              Text(
                '자동 제어 설정',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              AutomationPanel(),
            ],
          ),
        );
      },
    );
  }
}

// 기록 탭
class HistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WateringHistoryPanel();
  }
}
