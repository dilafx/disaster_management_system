import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Disaster Relief',
      theme: ThemeData(
        primarySwatch: Colors.red, // Red for emergency theme
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Disaster Management System '),
        ),
      ),
    );
  }
}