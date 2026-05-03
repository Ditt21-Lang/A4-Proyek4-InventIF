import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/auth/login_view.dart';
import 'views/Teknisi/dashboard_teknisi_view.dart'; 
import 'views/Teknisi/list_pengajuan_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InventIF',
      debugShowCheckedModeBanner: false, 
      
      theme: ThemeData(
        primaryColor: const Color(0xFF283593),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF283593)),
      ),

      initialRoute: '/dashboard-teknisi',

      routes: {
        '/dashboard-teknisi': (context) => const DashboardTeknisiScreen(),
        '/list-pengajuan': (context) => const ListPengajuanScreen(),
      },
    );
  }
}