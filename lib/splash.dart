import 'dart:ui'; // Tetap dipertahankan, meskipun filter blur dihapus
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dashboard_page.dart';

class SplashScreen extends StatefulWidget {
  final String userId;
  final String level;
  final String username;
  final String password;
  final String role;
  final String expiredDate;
  final String sessionKey;
  final List<Map<String, dynamic>> listBug;
  final List<Map<String, dynamic>> listDoos;
  final List<dynamic> news;

  const SplashScreen({
    super.key,
    required this.userId,       // <--- INI YG BIKIN ERROR, KETINGGALAN DIMASUKIN
    required this.level,        // <--- INI JUGA KETINGGALAN
    required this.username,
    required this.password,
    required this.role,
    required this.expiredDate,
    required this.sessionKey,
    required this.listBug,
    required this.listDoos,
    required this.news,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _fadeController;
  bool _fadeOutStarted = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset("assets/videos/splash.mp4")
      ..initialize().then((_) {
        setState(() {});
        _videoController.setLooping(false);
        _videoController.play();

        _fadeController = AnimationController(
          vsync: this,
          duration: const Duration(seconds: 1),
        );

        _videoController.addListener(() {
          final position = _videoController.value.position;
          final duration = _videoController.value.duration;

          if (duration != null &&
              position >= duration - const Duration(seconds: 1) &&
              !_fadeOutStarted) {
            _fadeOutStarted = true;
            _fadeController.forward();
          }

          if (position >= duration) {
            _navigateToDashboard();
          }
        });
      });
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DashboardPage(
          userId: widget.userId,       // <--- INI DITAMBAHIN
          level: widget.level,         // <--- INI DITAMBAHIN
          username: widget.username,
          password: widget.password,
          role: widget.role,
          expiredDate: widget.expiredDate,
          sessionKey: widget.sessionKey,
          listBug: widget.listBug,
          listDoos: widget.listDoos,
          news: widget.news,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // --- VIDEO BACKGROUND FULL SCREEN ---
          if (_videoController.value.isInitialized)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // --- TEKS "FIXCH" ---
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "PTIKITIWW APPS",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 3,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF2196F3).withOpacity(0.9),
                      blurRadius: 15,
                      offset: const Offset(2, 2),
                    ),
                    Shadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 15,
                      offset: const Offset(-2, -2),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- TOMBOL SKIP INTRO (BARU) ---
          Positioned(
            top: 40, // Jarak dari atas
            right: 20, // Jarak dari kanan
            child: GestureDetector(
              onTap: () {
                // Pause video agar suara berhenti
                _videoController.pause();
                // Langsung navigasi ke dashboard
                _navigateToDashboard();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5), // Background semi-transparan
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 1), // Border putih
                ),
                child: const Text(
                  "SKIP INTRO",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),

          // --- FADE OUT OVERLAY ---
          if (_fadeOutStarted)
            FadeTransition(
              opacity: _fadeController.drive(Tween(begin: 1.0, end: 0.0)),
              child: Container(color: Colors.black),
            ),
        ],
      ),
    );
  }
}