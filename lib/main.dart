import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:workmanager/workmanager.dart';
import 'firebase_options.dart';
import 'views/auth/login_view.dart';
import 'views/Teknisi/list_pengajuan_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/network_service.dart';
import 'services/notification_service.dart';
import 'views/main_dashboard.dart';
import 'views/profile/userProfile_view.dart';
import 'views/auth/register_view.dart';
import 'views/auth/register_identity_input_view.dart';
import 'views/Teknisi/main_dashboard_teknisi.dart';
import 'views/coordinator/main_dashboard_coordinator.dart';
import 'views/auth/onboarding_view.dart';


const String pendingSyncNotificationTask = 'pendingSyncNotificationTask';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    await NotificationService().init();
    final title = inputData?['title'] as String? ?? 'Pending Sync Reminder';
    final body = inputData?['body'] as String? ??
        'Segera online-kan aplikasi untuk menyinkronkan pinjaman offline.';
    await NotificationService().showNotification(task.hashCode, title, body);
    return Future.value(true);
  });
}

final GlobalKey<ScaffoldMessengerState> globalMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize workmanager only on mobile platforms (not on web)
  if (!kIsWeb) {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  await Hive.initFlutter();
  await Hive.openBox('pending_requests');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

// OLD MyApp CLASS
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
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingView(),
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/register-identity': (context) => const RegisterIdentityInputView(),
        '/dashboard': (context) => const MainDashboard(),
        '/profile': (context) => const UserProfileView(),
        '/dashboard-teknisi': (context) => const MainDashboardTeknisi(),
        '/list-pengajuan': (context) => const ListPengajuanScreen(),
        '/dashboard-coordinator': (context) => const MainDashboardCoordinator(),
      },
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      // home: KatalogAlatView(controller: KatalogAlatController()),
    );
  }
}

// TEMPORARY MyAppCoordinator - COMMENTED OUT
// class MyAppCoordinator extends StatelessWidget {
//   const MyAppCoordinator({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       scaffoldMessengerKey: globalMessengerKey,
//       title: 'InventIF - Coordinator',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2A2C8F)),
//         useMaterial3: true,
//       ),
//       home: const CoordinatorDashboardView(),
//     );
//   }
// }
