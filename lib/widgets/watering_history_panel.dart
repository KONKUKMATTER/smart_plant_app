// lib/widgets/watering_history_panel.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; // 그래프 패키지
import '../services/plant_service.dart';
import '../models/watering_history.dart';

class WateringHistoryPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PlantService>(
      builder: (context, plantService, child) {
        final todayHistory = plantService.getTodayWateringHistory();
        final allHistory = plantService.wateringHistory;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '오늘의 데이터 요약',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              // 하루 동안의 급수량 + 펌프 작동 횟수 그래프
              _buildWateringSummaryChart(todayHistory),
              SizedBox(height: 24),

              // --- 기존 UI ---
              // 오늘 급수 현황
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '오늘 급수 현황',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('총 급수 횟수'),
                              Text(
                                '${todayHistory.length}회',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('총 급수량'),
                              Text(
                                '${todayHistory.fold(0, (sum, h) => sum + h.amount)}ml',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (todayHistory.isNotEmpty) ...[
                        SizedBox(height: 16),
                        Divider(),
                        SizedBox(height: 8),
                        Text('오늘 급수 기록', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        ...todayHistory.map((history) => _buildHistoryItem(history)),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // 전체 급수 기록
              Text(
                '전체 급수 기록',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              if (allHistory.isEmpty)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        '급수 기록이 없습니다.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
                )
              else
                ...allHistory.map((history) => _buildHistoryCard(history)),
            ],
          ),
        );
      },
    );
  }

  /// 하루 동안의 급수량 및 횟수 막대 그래프
  Widget _buildWateringSummaryChart(List<WateringHistory> todayHistory) {
    final double totalAmount = todayHistory.fold(0.0, (sum, h) => sum + h.amount);
    final int totalCount = todayHistory.length;
    final double maxValue = (totalAmount > totalCount ? totalAmount : totalCount.toDouble());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('오늘의 급수', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue == 0 ? 50 : maxValue * 1.2, // 데이터가 0일 때 maxY 기본값 설정
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(fontSize: 12);
                          String text = '';
                          switch (value.toInt()) {
                            case 0: text = '총 급수량 (ml)'; break;
                            case 1: text = '펌프 작동 (회)'; break;
                          }
                          return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(text, style: style));
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxValue > 100 ? 50 : 10),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(toY: totalAmount, color: Colors.blue, width: 25, borderRadius: BorderRadius.circular(4)),
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(toY: totalCount.toDouble(), color: Colors.green, width: 25, borderRadius: BorderRadius.circular(4)),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(WateringHistory history) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                history.isAutomatic ? Icons.auto_mode : Icons.touch_app,
                size: 16,
                color: history.isAutomatic ? Colors.green : Colors.blue,
              ),
              SizedBox(width: 8),
              Text(DateFormat('HH:mm').format(history.timestamp)),
            ],
          ),
          Text('${history.amount}ml'),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(WateringHistory history) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: history.isAutomatic ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
          child: Icon(
            history.isAutomatic ? Icons.auto_mode : Icons.touch_app,
            color: history.isAutomatic ? Colors.green : Colors.blue,
          ),
        ),
        title: Text('${history.amount}ml'),
        subtitle: Text(
          DateFormat('yyyy년 MM월 dd일 HH:mm').format(history.timestamp),
        ),
        trailing: Text(
          history.isAutomatic ? '자동' : '수동',
          style: TextStyle(
            color: history.isAutomatic ? Colors.green : Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}