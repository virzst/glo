import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'home_page.dart';
import 'seller_page.dart';
import 'admin_page.dart';
import 'owner_page.dart';
import 'landing.dart';
import 'btrapps/.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Api.loadGh();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PRIKITIWW APPS',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'ShareTechMono',
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.dark().copyWith(
          secondary: const Color(0xFF2196F3),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => LandingPage());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/dashboard':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => DashboardPage(
                userId: args['userId'] ?? "000000",  // <--- INI OBAT ERRORNYA
                level: args['level'] ?? "1",         // <--- INI JUGA
                username: args['username'],
                password: args['password'],
                role: args['role'],
                sessionKey: args['key'],
                expiredDate: args['expiredDate'],
                listBug: List<Map<String, dynamic>>.from(args['listBug'] ?? []),
                listDoos: List<Map<String, dynamic>>.from(args['listDoos'] ?? []),
                news: List<Map<String, dynamic>>.from(args['news'] ?? []),
              ),
            );

          case '/home':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => HomePage(
                username: args['username'],
                password: args['password'],
                listBug: List<Map<String, dynamic>>.from(args['listBug'] ?? []),
                role: args['role'],
                expiredDate: args['expiredDate'],
                sessionKey: args['sessionKey'],
              ),
            );

          case '/seller':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => SellerPage(
                keyToken: args['keyToken'], // Pastikan keyToken ada di args
              ),
            );

          case '/admin':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => AdminPage(
                sessionKey: args['sessionKey'], // Pastikan sessionKey ada di args
              ),
            );

        // --- ROUTE BARU: OWNER ---
          case '/owner':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => OwnerPage(
                sessionKey: args['sessionKey'], // Pastikan sessionKey ada di args
                username: args['username'], // Pastikan username ada di args
              ),
            );

          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text("404 - Not Found")),
              ),
            );
        }
      },
    );
  }
}