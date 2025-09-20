// lib/services/plant_service.dart
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('plantName', newName);
    await _database.child('settings').update({'plantName': newName});
    notifyListeners();
  }

  Future<void> _initializeService() async {
    await _loadPreferences();
    _setupDatabaseListeners();
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

    _database.child('settings').onValue.listen((event) async {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        _isAutoMode = data['autoMode'] ?? false;
        _plantName = data['plantName'] ?? "Smart Plant";
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAutoMode', _isAutoMode);
        await prefs.setString('plantName', _plantName);
        notifyListeners();
      }
    });

    _database.child('automationRules').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        _automationRules = data.values
            .map((rule) => AutomationRule.fromJson(Map<String, dynamic>.from(rule)))
            .toList();
        notifyListeners();
      } else {
        _automationRules = [];
        notifyListeners();
      }
    });

    _database.child('wateringHistory').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        _wateringHistory = data.values
            .map((history) => WateringHistory.fromJson(Map<String, dynamic>.from(history)))
            .toList();
        _wateringHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notifyListeners();
      } else {
        _wateringHistory = [];
        notifyListeners();
      }
    });
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

  Future<void> controlHeatLed(bool status) async {
    await _database.child('commands').push().set({
      'type': 'heat_led_control',
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

    final history = WateringHistory(
      timestamp: DateTime.now(),
      amount: amount,
      isAutomatic: false,
    );
    await _database.child('wateringHistory').push().set(history.toJson());
  }

  Future<void> addAutomationRule(AutomationRule rule) async {
    await _database.child('automationRules').child(rule.id).set(rule.toJson());
  }

  Future<void> updateAutomationRule(AutomationRule rule) async {
    await _database.child('automationRules').child(rule.id).update(rule.toJson());
  }

  Future<void> deleteAutomationRule(String ruleId) async {
    await _database.child('automationRules').child(ruleId).remove();
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