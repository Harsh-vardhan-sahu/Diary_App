import 'package:diary/screen/darksplash.dart';
import 'package:diary/screen/homepage.dart';
import 'package:diary/screen/login.dart';
import 'package:diary/screen/splash_screen.dart'; // Add this
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: FirebaseOptions(
      apiKey: 'AIzaSyBrZc-psY1k6cuIqyL-VUVswIDh_9kbNyU',
      appId: '1:409501972670:android:89c173a7bfd298f1dd46ef',
      messagingSenderId:'',
      projectId: 'diary-21900'));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isNightMode;

  @override
  void initState() {
    super.initState();
    final hour = DateTime.now().hour;
    _isNightMode = hour < 6 || hour >= 18;
  }

  void _updateTheme() {
    final hour = DateTime.now().hour;
    setState(() {
      _isNightMode = hour < 6 || hour >= 18;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Diary',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:_isNightMode?  splash():SplashScreen()
    );
  }
}

