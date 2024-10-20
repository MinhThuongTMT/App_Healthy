import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Thêm import

class NotificationsScreen extends StatelessWidget {
  final List<String> notifications;

  NotificationsScreen({required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Back'),
        backgroundColor: Colors.blue[800],
      ),
      body: notifications.isNotEmpty
          ? ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                // Lấy thời gian hiện tại và chuyển đổi sang giờ Việt Nam
                DateTime now = DateTime.now().toUtc().add(Duration(hours: 7));
                String formattedTime =
                    DateFormat('dd-MM-yyyy HH:mm').format(now);

                return ListTile(
                  leading:
                      Icon(Icons.notification_important, color: Colors.red),
                  title: Text(notifications[index]),
                  subtitle: Text(
                    'Received at: $formattedTime', // Sử dụng thời gian đã định dạng
                    style: TextStyle(
                        fontSize: 12,
                        color: const Color.fromARGB(255, 23, 24, 1)),
                  ),
                  onTap: () {
                    // Optional: Handle notification tap if needed
                  },
                );
              },
            )
          : Center(
              child: Text(
                'No new notifications',
                style: TextStyle(fontSize: 18, color: Colors.blueGrey),
              ),
            ),
    );
  }
}
