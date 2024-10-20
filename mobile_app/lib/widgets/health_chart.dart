import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

class HealthChart extends StatelessWidget {
  final RxString temperature;
  final RxString heartRate;
  final RxString spo2;

  HealthChart({
    required this.temperature,
    required this.heartRate,
    required this.spo2,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSingleChart("Body Temperature", temperature, Colors.orange),
          SizedBox(height: 20),
          _buildSingleChart("Heart Rate", heartRate, Colors.redAccent),
          SizedBox(height: 20),
          _buildSingleChart("SpO2 Level", spo2, Colors.cyan),
        ],
      ),
    );
  }

  Widget _buildSingleChart(String title, RxString data, Color color) {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, _) {
                        return Text('T${value.toInt()}');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, _) {
                        return Text(value.toStringAsFixed(1));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _createSpots(data.value),
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _createSpots(String value) {
    double parsedValue = double.tryParse(value) ?? 0.0;
    // Example data, replace with actual dynamic data if needed
    return [
      FlSpot(0, parsedValue),
      FlSpot(1, parsedValue + 1),
      FlSpot(2, parsedValue - 0.5),
      FlSpot(3, parsedValue + 1.5),
      FlSpot(4, parsedValue),
    ];
  }
}
