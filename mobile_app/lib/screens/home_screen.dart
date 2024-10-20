import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';
import '../widgets/sensor_card.dart';
import '../widgets/datetime_display.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  var nhietdo = "0".obs;
  var nhiptim = "0".obs;
  var spo2 = "0".obs;
  var notificationCount = 0.obs;
  List<String> notifications = [];
  final ref = FirebaseDatabase.instance.ref().child("sensor");

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Variables for chart data
  List<FlSpot> temperatureSpots = [];
  List<FlSpot> heartRateSpots = [];
  List<FlSpot> spo2Spots = [];
  List<DateTime> timestamps = []; // Timestamps for data points
  int dataPointCount = 0; // Count the number of data points

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    getData();
  }

  void initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(String title, String body) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );

    notifications.add('$title: $body');
    notificationCount.value++;
  }

  void getData() async {
    ref.onValue.listen((event) {
      var snapshot = event.snapshot;
      if (snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        nhietdo.value = data["temperature"].toString();
        nhiptim.value = data["heartRate"].toString();
        spo2.value = data["spo2"].toString();

        // Update chart data
        _updateChartData();
        checkThresholds();
      }
    });
  }

  void _updateChartData() {
    dataPointCount++;

    // Add current timestamp
    timestamps.add(DateTime.now());

    temperatureSpots
        .add(FlSpot(dataPointCount.toDouble(), double.parse(nhietdo.value)));
    heartRateSpots
        .add(FlSpot(dataPointCount.toDouble(), double.parse(nhiptim.value)));
    spo2Spots.add(FlSpot(dataPointCount.toDouble(), double.parse(spo2.value)));

    // Limit the number of data points in the chart
    if (dataPointCount > 20) {
      temperatureSpots.removeAt(0);
      heartRateSpots.removeAt(0);
      spo2Spots.removeAt(0);
      timestamps.removeAt(0); // Remove oldest timestamp
    }
    setState(() {}); // Update UI
  }

  void checkThresholds() {
    final double temperature = double.parse(nhietdo.value);
    final int heartRate = int.parse(nhiptim.value);
    final int spo2Level = int.parse(spo2.value);

    if (temperature > 37.5) {
      showNotification("Cảnh báo", "Nhiệt độ cơ thể cao: $temperature °C");
    } else if (temperature < 35.0) {
      showNotification("Cảnh báo", "Nhiệt độ cơ thể thấp: $temperature °C");
    }

    if (heartRate > 100) {
      showNotification("Cảnh báo", "Nhịp tim cao: $heartRate BPM");
    } else if (heartRate < 60) {
      showNotification("Cảnh báo", "Nhịp tim thấp: $heartRate BPM");
    }

    if (spo2Level < 90) {
      showNotification("Cảnh báo", "SpO2 thấp: $spo2Level%");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsScreen(
          notifications: notifications,
        ),
      ),
    ).then((_) {
      notificationCount.value = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.local_hospital, color: Colors.white, size: 30),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to 03-SV-2024-VT2',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Design by TKT',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.blue[800],
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: _showNotifications,
              ),
              Obx(() => notificationCount.value > 0
                  ? Positioned(
                      right: 11,
                      top: 11,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints:
                            BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text(
                          '${notificationCount.value}',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Container()),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.green[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _selectedIndex == 0
            ? _buildSensorData()
            : (_selectedIndex == 1 ? _buildChart() : SettingsScreen()),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Chart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.blueGrey,
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSensorData() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          color: Colors.blue[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A total of 3 sensors',
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                  ),
                  Text(
                    'Data sensor',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ],
              ),
              DateTimeDisplay(),
            ],
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => HealthCard(
                      title: 'Body Temperature',
                      value: '${nhietdo.value} °C',
                      icon: Icons.thermostat,
                      color: Colors.orange,
                      backgroundColor: Colors.orange[50]!,
                    )),
                SizedBox(height: 15),
                Obx(() => HealthCard(
                      title: 'Heart Rate',
                      value: '${nhiptim.value} BPM',
                      icon: Icons.favorite,
                      color: Colors.red,
                      backgroundColor: Colors.red[50]!,
                    )),
                SizedBox(height: 15),
                Obx(() => HealthCard(
                      title: 'SpO2',
                      value: '${spo2.value} %',
                      icon: Icons.monitor_heart,
                      color: Colors.blue,
                      backgroundColor: Colors.blue[50]!,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    return Column(
      children: [
        SizedBox(height: 20),
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(10),
            children: [
              _buildLineChart(
                'Body Temperature',
                temperatureSpots,
                Colors.orange,
                '°C',
                Colors.orange[50]!,
              ),
              SizedBox(height: 20),
              _buildLineChart(
                'Heart Rate',
                heartRateSpots,
                Colors.red,
                'BPM',
                Colors.red[50]!,
              ),
              SizedBox(height: 20),
              _buildLineChart(
                'SpO2',
                spo2Spots,
                Colors.blue,
                '%',
                Colors.blue[50]!,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart(String title, List<FlSpot> spots, Color lineColor,
      String unit, Color bgColor) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                borderData: FlBorderData(
                  border: Border.all(color: Colors.grey[300]!),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                      reservedSize: 40,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < timestamps.length) {
                          DateTime timestamp = timestamps[index];
                          return Text(
                            '${timestamp.hour}:${timestamp.minute}:${timestamp.second}',
                            style: TextStyle(fontSize: 10),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                ),
                minX: spots.isNotEmpty ? spots.first.x : 0,
                maxX: spots.isNotEmpty ? spots.last.x : 0,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    dotData: FlDotData(show: true),
                    color: lineColor,
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
