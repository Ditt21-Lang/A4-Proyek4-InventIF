import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/network_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Hive.initFlutter();
  await Hive.openBox('pending_requests'); 

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NetworkService _networkService = NetworkService();

  @override
  void initState() {
    super.initState();
    _networkService.startMonitoring();
  }

  @override
  void dispose() {
    _networkService.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InventIF',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Ini Branch Fitur Offline & Sinkronisasi', style: TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}