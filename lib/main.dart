import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventif/views/catalog/katalog_ruangan.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Membuat layar edge-to-edge (system navbar transparan)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Available Facilities',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: const KatalogRuanganScreen(),
    );
  }
}