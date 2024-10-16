import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';
import '../widgets/sensor_card.dart';
import '../widgets/datetime_display.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  var nhietdo = "0".obs;
  var nhiptim = "0".obs;
  var spo2 = "0".obs;
  var notificationCount = 0.obs; // Biến đếm thông báo
  List<String> notifications = []; // Danh sách các thông báo

  var ref = FirebaseDatabase.instance.ref().child("sensor");

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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

    // Thêm thông báo vào danh sách
    notifications.add('$title: $body');
    notificationCount.value += 1;
  }

  void getData() async {
    ref.onValue.listen((event) {
      var snapshot = event.snapshot;
      if (snapshot.value != null) {
        Object? data = snapshot.value;
        Map<dynamic, dynamic> map = data as Map<dynamic, dynamic>;
        nhietdo.value = map["temperature"].toString();
        nhiptim.value = map["heartRate"].toString();
        spo2.value = map["spo2"].toString();

        checkThresholds();
      }
    });
  }

  void checkThresholds() {
    double temperature = double.parse(nhietdo.value);
    int heartRate = int.parse(nhiptim.value);
    int spo2Level = int.parse(spo2.value);

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
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsScreen()),
      );
    }
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
      // Đặt lại số lượng thông báo sau khi xem
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
                      color: Colors.white),
                ),
                Text('Design by TKT',
                    style: TextStyle(fontSize: 14, color: Colors.white70)),
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
                            borderRadius: BorderRadius.circular(6)),
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
        child: Column(
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
                          color: Colors.redAccent,
                          backgroundColor: Colors.red[50]!,
                        )),
                    SizedBox(height: 15),
                    Obx(() => HealthCard(
                          title: 'SpO2 Level',
                          value: '${spo2.value} %',
                          icon: Icons.bloodtype,
                          color: const Color.fromARGB(255, 8, 207, 194),
                          backgroundColor: Colors.cyan[50]!,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
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
}
