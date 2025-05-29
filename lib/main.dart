import 'package:diary/screen/homepage.dart';
import 'package:diary/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}class MyApp extends StatefulWidget {
  const MyApp({super.key});
 @override
  State<MyApp> createState() => _MyAppState();
}class _MyAppState extends State<MyApp> {
  var auth = FirebaseAuth.instance;
  var isLogin = false;
  checkIfLogin()async{
    auth.authStateChanges().listen((User? user){
      if(user!=null&&mounted){
        setState(() {
          isLogin=true;  });
      }  });
  } @override
  void initState() {
     checkIfLogin();
    super.initState();  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Diary',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isLogin? const Homepage() :const LoginScreen(), // Set Login as the home page
    );
  }
}
