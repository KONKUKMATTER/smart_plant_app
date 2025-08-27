// services/plant_service.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plant_data.dart';
import '../models/automation_rule.dart';
import '../models/watering_history.dart';

class PlantService extends ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  PlantData? _currentData;
  List<AutomationRule> _automationRules = [];
  List<WateringHistory> _wateringHistory = [];
  bool _isAutoMode = false;
  String _plantName = "Smart Plant";

  PlantData? get currentData => _currentData;
  List<AutomationRule> get automationRules => _automationRules;
  List<WateringHistory> get wateringHistory => _wateringHistory;
  bool get isAutoMode => _isAutoMode;
  String get plantName => _plantName;

  PlantService() {
    _initializeService();
  }

  Future<void> updatePlantName(String newName) async {
    if (newName.isEmpty) return;

    _plantName = newName;

    // 1. SharedPreferences에 저장하여 앱 재시작 시 유지
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('plantName', newName);

    // 2. Firebase Realtime Database에 저장하여 서버와 동기화
    await _database.child('settings').update({'plantName': newName});

    // 3. 변경사항을 앱의 모든 화면에 알림
    notifyListeners();
  }


  Future<void> _initializeService() async {
    await _loadPreferences();
    _setupDatabaseListeners();
    _loadAutomationRules();
    _loadWateringHistory();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isAutoMode = prefs.getBool('isAutoMode') ?? false;
    _plantName = prefs.getString('plantName') ?? "Smart Plant";
    notifyListeners();
  }

  void _setupDatabaseListeners() {
    _database.child('plant_data').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        _currentData = PlantData.fromJson(data);
        notifyListeners();
      }
    });
  }

  Future<void> _loadAutomationRules() async {
    try {
      final snapshot = await _database.child('automationRules').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        _automationRules = data.values
            .map((rule) => AutomationRule.fromJson(Map<String, dynamic>.from(rule)))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading automation rules: $e');
    }
  }

  Future<void> _loadWateringHistory() async {
    try {
      final snapshot = await _database.child('wateringHistory').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        _wateringHistory = data.values
            .map((history) => WateringHistory.fromJson(Map<String, dynamic>.from(history)))
            .toList();
        _wateringHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notifyListeners();
      }
    } catch (e) {
      print('Error loading watering history: $e');
    }
  }

  Future<void> toggleAutoMode() async {
    _isAutoMode = !_isAutoMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAutoMode', _isAutoMode);
    await _database.child('settings').update({'autoMode': _isAutoMode});
    notifyListeners();
  }

  Future<void> controlLED(bool status) async {
    await _database.child('commands').push().set({
      'type': 'led_control',
      'status': status,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> adjustLEDBrightness(int brightness) async {
    await _database.child('commands').push().set({
      'type': 'led_brightness',
      'brightness': brightness,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> activatePump(int amount) async {
    await _database.child('commands').push().set({
      'type': 'pump_activate',
      'amount': amount,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Add to watering history
    final history = WateringHistory(
      timestamp: DateTime.now(),
      amount: amount,
      isAutomatic: false,
    );

    await _database.child('wateringHistory').push().set(history.toJson());
    _wateringHistory.insert(0, history);
    notifyListeners();
  }

  Future<void> addAutomationRule(AutomationRule rule) async {
    await _database.child('automationRules').child(rule.id).set(rule.toJson());
    _automationRules.add(rule);
    notifyListeners();
  }

  Future<void> updateAutomationRule(AutomationRule rule) async {
    await _database.child('automationRules').child(rule.id).update(rule.toJson());
    final index = _automationRules.indexWhere((r) => r.id == rule.id);
    if (index != -1) {
      _automationRules[index] = rule;
      notifyListeners();
    }
  }

  Future<void> deleteAutomationRule(String ruleId) async {
    await _database.child('automationRules').child(ruleId).remove();
    _automationRules.removeWhere((rule) => rule.id == ruleId);
    notifyListeners();
  }

  int getTodayWateringCount() {
    final today = DateTime.now();
    return _wateringHistory.where((history) {
      return history.timestamp.year == today.year &&
          history.timestamp.month == today.month &&
          history.timestamp.day == today.day;
    }).length;
  }

  List<WateringHistory> getTodayWateringHistory() {
    final today = DateTime.now();
    return _wateringHistory.where((history) {
      return history.timestamp.year == today.year &&
          history.timestamp.month == today.month &&
          history.timestamp.day == today.day;
    }).toList();
  }
}
