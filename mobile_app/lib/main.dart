import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_app/firebase/firebase_optionss.dart'; // Chỉnh lại đường dẫn nếu cần

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kiểm tra xem Firebase đã được khởi tạo chưa
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NCKH',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
