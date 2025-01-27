import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'homepage.dart'; // Import your Homepage screen

class Load extends StatefulWidget {
  @override
  State<Load> createState() => _LoadState();
}

class _LoadState extends State<Load> {
  @override
  void initState() {
    super.initState();
    // Navigate to Homepage after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Homepage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset('assets/images/Animation.json'), // Path to your Lottie file
      ),
    );
  }
}

