import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/auth/login_view.dart';
import 'views/Teknisi/list_pengajuan_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/network_service.dart';
import 'views/main_dashboard.dart';
import 'views/userProfile_view.dart';
import 'views/Teknisi/main_dashboard_teknisi.dart';

final GlobalKey<ScaffoldMessengerState> globalMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('pending_requests');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      scaffoldMessengerKey: globalMessengerKey,
      title: 'InventIF',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2A2C8F)),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginView(),
        '/dashboard': (context) => const MainDashboard(),
        '/profile': (context) => const UserProfileView(),
        '/dashboard-teknisi': (context) => const MainDashboardTeknisi(),
        '/list-pengajuan': (context) => const ListPengajuanScreen(),
      },
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      // home: KatalogAlatView(controller: KatalogAlatController()),
    );
  }
}
