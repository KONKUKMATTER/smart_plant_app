// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async'; // Future.delayed를 위해 추가
import '../services/ai_service.dart';
import '../services/plant_service.dart';
import '../widgets/sensor_card.dart';
import '../widgets/control_panel.dart';
import '../widgets/automation_panel.dart';
import '../widgets/watering_history_panel.dart';

// HomeScreen과 다른 탭들은 이전과 동일하게 유지됩니다.
// ... (이전 코드와 동일한 부분은 생략) ...
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
            title: Text("SmartPlant"),
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
                Tab(text: '식물 정보'),
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
                      plantService.isAutoMode ? '수동 모드로 전환' : 'AI 자동 모드로 전환',
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

// 식물 정보 탭
class SensorInfoTab extends StatefulWidget {
  @override
  _SensorInfoTabState createState() => _SensorInfoTabState();
}

class _SensorInfoTabState extends State<SensorInfoTab> {
  late TextEditingController _plantNameController;
  bool _isLoadingAiInfo = false;
  String? _aiPlantInfo;

  @override
  void initState() {
    super.initState();
    _plantNameController = TextEditingController(
      text: Provider.of<PlantService>(context, listen: false).plantName,
    );
  }

  @override
  void dispose() {
    _plantNameController.dispose();
    super.dispose();
  }

  // AI 정보 가져오기 함수를 실제 API를 호출하도록 수정
  void _fetchAiPlantInfo(String plantName) async {
    setState(() {
      _isLoadingAiInfo = true;
      _aiPlantInfo = null;
    });

    try {
      // Provider를 통해 AiService 인스턴스를 가져와 API 호출
      final aiService = Provider.of<AiService>(context, listen: false);
      final result = await aiService.getPlantInfo(plantName);

      if (!mounted) return;
      setState(() {
        _aiPlantInfo = result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _aiPlantInfo = "정보를 불러오는 중 오류가 발생했습니다.";
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingAiInfo = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final plantService = Provider.of<PlantService>(context);
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
          // 식물 이름 입력 UI
          Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("식물 이름 설정", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  TextField(
                    controller: _plantNameController,
                    decoration: InputDecoration(
                      hintText: "예: 몬스테라",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.save),
                      label: Text("식물 이름 저장 및 AI 정보 조회"),
                      onPressed: () {
                        final newName = _plantNameController.text;
                        if (newName.isNotEmpty) {
                          plantService.updatePlantName(newName);

                          _fetchAiPlantInfo(newName); // 실제 AI 정보 조회 함수 호출
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('"${newName}"에 대한 AI 정보를 조회합니다.')),
                          );
                          FocusScope.of(context).unfocus();
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),

          // 👇 AI 식물 정보 카드 추가
          if (_isLoadingAiInfo || _aiPlantInfo != null)
            Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.blueAccent),
                        SizedBox(width: 8),
                        Text("AI 식물 정보", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 12),
                    if (_isLoadingAiInfo)
                      Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text("AI가 식물 정보를 분석하고 있습니다..."),
                          ],
                        ),
                      )
                    else if (_aiPlantInfo != null)
                    // 👇 이 부분을 MarkdownBody 위젯으로 변경
                      MarkdownBody(
                        data: _aiPlantInfo!,
                        selectable: true, // 텍스트 선택 가능하게
                        // Markdown 스타일을 좀 더 예쁘게 커스터마이징할 수 있습니다.
                        styleSheet: MarkdownStyleSheet(
                          h1: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                          h2: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade600),
                          p: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey.shade800),
                          strong: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                          listBullet: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey.shade800),
                          // 필요에 따라 다른 요소들도 스타일 지정 가능
                        ),
                      ),
                  ],
                ),
              ),
            ),


          // --- 기존 센서 카드 ---
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
            value: data.ledStatus ?? false ? 'ON (${data.ledBrightness}%)' : 'OFF',
            icon: Icons.lightbulb,
            color: data.ledStatus ?? false ? Colors.green : Colors.grey,
          ),
          SensorCard(
            title: '펌프 상태',
            value: data.pumpStatus ?? false ? '작동중' : '정지',
            icon: Icons.water_drop_rounded,
            color: data.pumpStatus ?? false ? Colors.green : Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '최종 업데이트: ${DateFormat('HH:mm:ss').format(data.lastUpdated!)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}


// 제어 탭 (변경 없음)
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

// 기록 탭 (변경 없음)
class HistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WateringHistoryPanel();
  }
}