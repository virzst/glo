import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'splash.dart';
import 'btrapps/.dart';
import 'login_page.dart'; // <--- TAMBAHIN BARIS INI BRO
final baseUrl = Api.api;

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  final Color primaryDark = const Color(0xFF121212);
  
  // Tambahan state & animasi
  int _currentPage = 0;
  late AnimationController _indicatorAnimController;
  late Animation<double> _indicatorAnimation;
  final Color primaryPink = const Color(0xFF2196F3);
  final Color accentPink = const Color(0xFF6EB1FF);
  final Color glassBorder = Colors.white.withOpacity(0.15);
  final Color cardBg = Colors.white.withOpacity(0.08);

  // Controller untuk efek swipe up (Vertical Scroll) ala Wibuku
  final PageController _pageController = PageController();
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();

    _indicatorAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _indicatorAnimation = Tween<double>(begin: 6.0, end: 18.0).animate(
      CurvedAnimation(parent: _indicatorAnimController, curve: Curves.easeInOut),
    );
  }

  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString("username");
    final savedPass = prefs.getString("password"); // Password lu aman tersimpan
    final savedKey = prefs.getString("key");

    if (savedUser == null || savedPass == null || savedKey == null) {
      setState(() => _isCheckingAuth = false);
      return;
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      final android = await deviceInfo.androidInfo;
      final androidId = android.id ?? "unknown_device";

      final uri = Uri.parse("${baseUrl}/myInfo?username=$savedUser&password=$savedPass&androidId=$androidId&key=$savedKey");
      final res = await http.get(uri);
      final data = jsonDecode(res.body);

      if (data['valid'] == true && data['expired'] == false) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SplashScreen(
              userId: data['userId'] ?? "000000",   // <--- INI WAJIB MASUK BOS
              level: data['level'] ?? "1",          // <--- INI JUGA WAJIB
              username: savedUser,
              password: savedPass,
              role: data['role'],
              sessionKey: data['key'],
              expiredDate: data['expiredDate'],
              listBug: (data['listBug'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList(),
              listDoos: (data['listDDoS'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList(),
              news: (data['news'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList(),
            ),
          ),
        );
      } else {
        setState(() => _isCheckingAuth = false);
      }
    } catch (e) {
      setState(() => _isCheckingAuth = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _indicatorAnimController.dispose(); // Matiin animasi pas pindah halaman
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $uri");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Cek loading Auto-Login
    if (_isCheckingAuth) {
      return Scaffold(
        backgroundColor: primaryDark,
        body: Center(child: CircularProgressIndicator(color: accentPink)),
      );
    }

    return Scaffold(
      backgroundColor: primaryDark,
      // 2. Efek Scroll (Swipe Up)
      // KITA PAKAI STACK BIAR BISA NUMPUK HEADER & FOOTER
      body: Stack(
        children: [
          // 1. KONTEN TENGAH (SCROLLABLE AREA)
          PageView(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() => _currentPage = page);
            },
            children: [
              // --- PAGE 1: WELCOME ---
              const Center(
                child: Text(
                  ".WELCOME.",
                  style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold, fontFamily: 'Orbitron', letterSpacing: 2),
                ),
              ),

              // --- PAGE 2: DESKRIPSI ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Disclaimer", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Orbitron')),
                    SizedBox(height: 20),
                    Text(
                      "Prikitiww Apps adalah platform komunitas digital yang dibangun untuk memberikan kebebasan dalam berinovasi. Kami menyediakan berbagai tools canggih, mulai dari sistem manajemen server hingga asisten AI pintar.\n\nDengan bergabung bersama kami, Anda menjadi bagian dari ekosistem yang terus berkembang, mengedepankan keamanan dan kenyamanan pengguna.",
                      style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
                    ),
                  ],
                ),
              ),

          // ================= PAGE 3: LANDING ASLI LU 100% =================
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF3D1B1B), 
                  primaryDark, 
                  const Color(0xFF000000)
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 320,
                      height: 400,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              "assets/images/login.png",
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "ERROR:\n${error.toString()}",
                                    style: const TextStyle(color: Colors.red, fontSize: 10),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 30,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [accentPink, Colors.white],
                                  ).createShader(bounds),
                                  child: const Text(
                                    "PRIKITIWW APPS",
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  "Please Log in or Buy Access to continue",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 4,
                                        color: Colors.black,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryPink, accentPink],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryPink.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          // Pastikan lu udah masukin: import 'login_page.dart'; di atas
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryPink.withOpacity(0.5),
                        ),
                      ),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => _openUrl("https://t.me/Virzofc"),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag,
                              color: accentPink,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Buy Access To Owner",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: accentPink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(
                          child: _buildContactButton(
                            icon: FontAwesomeIcons.telegram,
                            label: "Telegram Channel",
                            url: "https://t.me/AllinformationVirz",
                            color: const Color(0xFF0088cc),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                    const Text("© 2026 Vanguard of Your Rising Empire", style: TextStyle(color: Colors.white38, fontSize: 11)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ], // Penutup dari PageView
      ),

      // 2. FIXED HEADER (VOYRE LOGO) - NEMPEL DI ATAS
      Positioned(
        top: 0, left: 0, right: 0,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("PRIKITIWW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Orbitron')),
                  SizedBox(width: 5),
                  Icon(FontAwesomeIcons.vimeoV, color: Colors.amber, size: 16),
                ],
              ),
              const SizedBox(height: 5),
              const Text("App: 1.2.5 (56)", style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
      ),

      // 3. FIXED FOOTER (SWIPE ANIMATED) - TITIK MANTUL & HILANG DI HALAMAN LOGIN
      Positioned(
        bottom: 30, left: 0, right: 0,
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _currentPage == 2 ? 0.0 : 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22, height: 45,
                  decoration: BoxDecoration(border: Border.all(color: Colors.white54, width: 2), borderRadius: BorderRadius.circular(20)),
                  alignment: Alignment.topCenter,
                  child: AnimatedBuilder(
                    animation: _indicatorAnimation,
                    builder: (context, child) => Padding(
                      padding: EdgeInsets.only(top: _indicatorAnimation.value),
                      child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text("Swipe Up to continue", style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    ], // Penutup dari Stack
  ), // Penutup dari body Stack
); // Penutup dari Scaffold
}


  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required String url,
    required Color color,
  }) {
    return InkWell(
      onTap: () => _openUrl(url),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: cardBg,
          border: Border.all(color: glassBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}