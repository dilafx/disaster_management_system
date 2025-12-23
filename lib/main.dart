import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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