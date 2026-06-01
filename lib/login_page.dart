import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'splash.dart';
import 'btrapps/.dart';
final baseUrl = Api.api;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final userController = TextEditingController();
  final passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool _obscurePassword = true;
  String? androidId;

  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  final Color bgDark = const Color(0xFF121212);
  final Color bgSecondary = const Color(0xFF2A2A2D);
  final Color primaryPink = const Color(0xFF2196F3);
  final Color accentPink = const Color(0xFF6EB1FF);
  final Color whiteText = Colors.white;
  final Color grayText = Colors.white70;


  @override
  void initState() {
    super.initState();
    _initAnim();
    initLogin();
  }

  void _initAnim() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )
      ..forward();
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  Future<void> initLogin() async {
    androidId = await getAndroidId();

    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString("username");
    final savedPass = prefs.getString("password");
    final savedKey = prefs.getString("key");

    if (savedUser != null && savedPass != null && savedKey != null) {
      final uri = Uri.parse(
          "$baseUrl/myInfo?username=$savedUser&password=$savedPass&androidId=$androidId&key=$savedKey");

      try {
        final res = await http.get(uri);
        final data = jsonDecode(res.body);
        if (data['valid'] == true) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SplashScreen(
                  username: savedUser,
                  password: savedPass,
                  role: data['role'],
                  userId: data['userId'] ?? "000000",
                  level: data['level'] ?? "1",
                  sessionKey: data['key'],
                  expiredDate: data['expiredDate'],
                  listBug: (data['listBug'] as List? ?? [])
                      .map((e) => Map<String, dynamic>.from(e as Map))
                      .toList(),
                  listDoos: (data['listDDoS'] as List? ?? [])
                      .map((e) => Map<String, dynamic>.from(e as Map))
                      .toList(),
                  news: (data['news'] as List? ?? [])
                      .map((e) => Map<String, dynamic>.from(e as Map))
                      .toList(),
                ),
              ),
            );
          }
        }
      } catch (_) {
      }
    }
  }

  Future<String> getAndroidId() async {
    final deviceInfo = DeviceInfoPlugin();
    final android = await deviceInfo.androidInfo;
    return android.id ?? "unknown_device";
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    final username = userController.text.trim();
    final password = passController.text.trim();

    setState(() => isLoading = true);

    try {
      final validate = await http.post(
        Uri.parse("$baseUrl/validate"),
        body: {
          "username": username,
          "password": password,
          "androidId": androidId ?? "unknown_device",
        },
      );

      final validData = jsonDecode(validate.body);
      if (validData['expired'] == true) {
        _showPopup(
          title: "⏳ Access Expired",
          message: "Masa akses Anda telah habis.\nSilakan perpanjang akses.",
          color: Colors.orange,
          showContact: true,
        );
      }
      else if (validData['valid'] != true) {
        final String errorMsg = (validData['message'] ?? "").toLowerCase();
        if (errorMsg.contains("perangkat") ||
            errorMsg.contains("device") ||
            errorMsg.contains("another")) {
          _showPopup(
            title: "⚠️ Sesi Aktif",
            message: "Akun ini sedang login di perangkat lain.\nSilakan logout terlebih dahulu di perangkat lama.",
            color: Colors.orangeAccent,
          );
        } else {
          _showPopup(
            title: "❌ Login Gagal",
            message: "Username atau password salah.",
            color: Colors.redAccent,
          );
        }
      }
      else {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("username", username);
        prefs.setString("password", password);
        prefs.setString("key", validData['key']);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SplashScreen(
                username: username,
                password: password,
                role: validData['role'],
                userId: validData['userId'] ?? "000000",
                level: validData['level'] ?? "1",
                sessionKey: validData['key'],
                expiredDate: validData['expiredDate'],
                listBug: (validData['listBug'] as List? ?? [])
                    .map((e) => Map<String, dynamic>.from(e as Map))
                    .toList(),
                listDoos: (validData['listDDoS'] as List? ?? [])
                    .map((e) => Map<String, dynamic>.from(e as Map))
                    .toList(),
                news: (validData['news'] as List? ?? [])
                    .map((e) => Map<String, dynamic>.from(e as Map))
                    .toList(),
              ),
            ),
          );
        }
      }
    } catch (e) {
      _showPopup(
        title: "⚠️ Connection Error",
        message: "Gagal terhubung ke server.\nPeriksa koneksi internet Anda.",
        color: Colors.red,
      );
    }

    setState(() => isLoading = false);
  }

  void _showPopup({
    required String title,
    required String message,
    Color color = Colors.redAccent,
    bool showContact = false,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF12002C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
        actions: [
          if (showContact)
            TextButton(
              onPressed: () async {
                await launchUrl(Uri.parse("https://t.me/Virzofc"),
                    mode: LaunchMode.externalApplication);
              },
              child: const Text(
                "Contact Admin",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    userController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF3D1B1B),
              bgDark,
              const Color(0xFF000000),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: "logo",
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: accentPink, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: accentPink.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(23),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: whiteText,
                        fontFamily: 'Orbitron',
                        shadows: [
                          Shadow(
                            color: accentPink.withOpacity(0.5),
                            blurRadius: 15,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Sign in to continue",
                      style: TextStyle(
                        color: grayText,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 40),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildInput(userController, "Username", Icons.person_outline),
                          const SizedBox(height: 20),
                          _buildInput(passController, "Password", Icons.lock_outline, true),
                          const SizedBox(height: 30),
                          _buildButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, IconData icon, [bool isPassword = false]) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: bgSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: accentPink),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.white54,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildButton() {
    final double fullButtonWidth = MediaQuery.of(context).size.width - 48;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isLoading ? 60 : fullButtonWidth,
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryPink,
            accentPink,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentPink.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : login,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Text(
              "Sign In",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}