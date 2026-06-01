import 'dart:collection';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'manage_server.dart';
import 'wifi_internal.dart';
import 'wifi_external.dart';
import 'ddos_panel.dart';
import 'nik_check.dart';
import 'tiktok_page.dart';
import 'instagram_page.dart';
import 'phone_lookup.dart';
import 'qr_gen.dart';
import 'domain_page.dart';
import 'spam_ngl.dart';
import 'telegram.dart';
import 'spyware.dart';
import 'spotify_player_page.dart';
import 'anime_home.dart';
import 'chatbot_page.dart';

class ToolsPage extends StatelessWidget {
  final String username;
  final String sessionKey;
  final String userRole;
  final List<Map<String, dynamic>> listDoos;

  const ToolsPage({
    super.key,
    required this.username,
    required this.sessionKey,
    required this.userRole,
    required this.listDoos,
  });

  // Warna Tema Biru
  final Color primaryDark = const Color(0xFF121212);
  final Color primaryPink = const Color(0xFF2196F3);
  final Color accentPink = const Color(0xFF6EB1FF);
  final Color lightPink = const Color(0xFFBBDEFB);
  final Color primaryWhite = Colors.white;
  final Color accentGrey = Colors.grey;
  final Color cardDark = const Color(0xFF2A2A2D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryPink.withOpacity(0.3),
                    accentPink.withOpacity(0.2),
                    primaryPink.withOpacity(0.3),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                border: Border.all(color: primaryPink.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: primaryPink.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.build_circle_outlined,
                        color: primaryWhite,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "TOOLS DASHBOARD",
                        style: TextStyle(
                          color: primaryWhite,
                          fontSize: 20,
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: primaryPink.withOpacity(0.8),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Advanced Security & OSINT Tools",
                    style: TextStyle(
                      color: lightPink,
                      fontSize: 14,
                      fontFamily: 'ShareTechMono',
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildToolCard(
                      icon: Icons.flash_on,
                      title: "DDoS Tools",
                      subtitle: "Attack & Server",
                      color: primaryWhite,
                      gradient: [
                        primaryPink.withOpacity(0.3),
                        accentPink.withOpacity(0.2),
                      ],
                      onTap: () => _showDDoSTools(context),
                    ),
                    _buildToolCard(
                      icon: Icons.wifi,
                      title: "Network",
                      subtitle: "WiFi & Spam",
                      color: primaryWhite,
                      gradient: [
                        primaryPink.withOpacity(0.3),
                        accentPink.withOpacity(0.2),
                      ],
                      onTap: () => _showNetworkTools(context),
                    ),
                    _buildToolCard(
                      icon: Icons.search,
                      title: "OSINT",
                      subtitle: "Investigation",
                      color: primaryWhite,
                      gradient: [
                        primaryPink.withOpacity(0.3),
                        accentPink.withOpacity(0.2),
                      ],
                      onTap: () => _showOSINTTools(context),
                    ),
                    _buildToolCard(
                      icon: Icons.download,
                      title: "Downloader",
                      subtitle: "Social Media",
                      color: primaryWhite,
                      gradient: [
                        primaryPink.withOpacity(0.3),
                        accentPink.withOpacity(0.2),
                      ],
                      onTap: () => _showDownloaderTools(context),
                    ),
                    _buildToolCard(
                      icon: Icons.build,
                      title: "Utilities",
                      subtitle: "Extra Tools",
                      color: primaryWhite,
                      gradient: [
                        primaryPink.withOpacity(0.3),
                        accentPink.withOpacity(0.2),
                      ],
                      onTap: () => _showUtilityTools(context),
                    ),
                    _buildToolCard(
                      icon: Icons.play_circle_fill,
                      title: "Streaming",
                      subtitle: "Nonton & Hiburan",
                      color: primaryWhite,
                      gradient: [
                        primaryPink.withOpacity(0.3),
                        accentPink.withOpacity(0.2),
                      ],
                      onTap: () => _showStreamingTools(context),
                    ),
                    _buildToolCard(
                      icon: Icons.smart_toy,
                      title: "AI Assistant",
                      subtitle: "Tanya AI Pintar",
                      color: primaryWhite,
                      gradient: [
                        primaryPink.withOpacity(0.3),
                        accentPink.withOpacity(0.2),
                      ],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AiChatPage(),
                          ),
                        );
                      },
                    ),
                 ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, double scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryPink.withOpacity(0.4), width: 1),
            boxShadow: [
              BoxShadow(
                color: primaryPink.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryPink, accentPink],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: lightPink.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: primaryPink.withOpacity(0.3),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: primaryWhite, size: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: primaryWhite,
                    fontSize: 13,
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: lightPink,
                    fontSize: 12,
                    fontFamily: 'ShareTechMono',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDDoSTools(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border.all(color: primaryPink.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: primaryPink.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPink, accentPink],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.flash_on, color: primaryWhite),
                  const SizedBox(width: 12),
                  Text(
                    "DDoS Tools",
                    style: TextStyle(
                      color: primaryWhite,
                      fontSize: 20,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildToolOption(
                      icon: Icons.flash_on,
                      label: "Attack Panel",
                      color: lightPink,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AttackPanel(
                              sessionKey: sessionKey,
                              listDoos: listDoos,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.dns,
                      label: "Manage Server",
                      color: lightPink,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ManageServerPage(keyToken: sessionKey),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNetworkTools(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border.all(color: primaryPink.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: primaryPink.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPink, accentPink],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.wifi, color: primaryWhite),
                  const SizedBox(width: 12),
                  Text(
                    "Network Tools",
                    style: TextStyle(
                      color: primaryWhite,
                      fontSize: 20,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildToolOption(
                        icon: Icons.security,
                        label: "Spyware",
                        color: lightPink,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              SpywarePage(
                                 sessionKey: sessionKey,
                                 userRole: userRole,
                                 username: username,
                              ),
                            ),
                          );
                        },
                      ),
                      _buildToolOption(
                        icon: Icons.telegram,
                        label: "TG Spam",
                        color: lightPink,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TelegramSpamPage(sessionKey: sessionKey),
                            ),
                          );
                        },
                      ),
                      _buildToolOption(
                        icon: Icons.newspaper_outlined,
                        label: "Spam NGL",
                        color: lightPink,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => NglPage()),
                          );
                        },
                      ),
                      _buildToolOption(
                        icon: Icons.wifi_off,
                        label: "WiFi Killer (Internal)",
                        color: lightPink,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => WifiKillerPage()),
                          );
                        },
                      ),
                      _buildToolOption(
                        icon: Icons.router,
                        label: "WiFi Killer (External)",
                        color: lightPink,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  WifiInternalPage(sessionKey: sessionKey),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOSINTTools(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border.all(color: primaryPink.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: primaryPink.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPink, accentPink],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: primaryWhite),
                  const SizedBox(width: 12),
                  Text(
                    "OSINT Tools",
                    style: TextStyle(
                      color: primaryWhite,
                      fontSize: 20,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildToolOption(
                      icon: Icons.badge,
                      label: "NIK Detail",
                      color: lightPink,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NikCheckerPage(),
                          ),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.domain,
                      label: "Domain OSINT",
                      color: lightPink,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DomainOsintPage(),
                          ),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.person_search,
                      label: "Phone Lookup",
                      color: lightPink,
                       onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PhoneLookupPage(),
                          ),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.email,
                      label: "Email OSINT",
                      color: lightPink,
                      onTap: () => _showComingSoon(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDownloaderTools(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border.all(color: primaryPink.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: primaryPink.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPink, accentPink],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.download, color: primaryWhite),
                  const SizedBox(width: 12),
                  Text(
                    "Media Downloader",
                    style: TextStyle(
                      color: primaryWhite,
                      fontSize: 20,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildToolOption(
                      icon: Icons.video_library,
                      label: "TikTok Downloader",
                      color: lightPink,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TiktokDownloaderPage(),
                          ),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.music_note,
                      label: "Spotify Player",
                      color: lightPink,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SpotifyPlayerPage(),
                          ),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.camera_alt,
                      label: "Instagram Downloader",
                      color: lightPink,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const InstagramDownloaderPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUtilityTools(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border.all(color: primaryPink.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: primaryPink.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPink, accentPink],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.build, color: primaryWhite),
                  const SizedBox(width: 12),
                  Text(
                    "Utility Tools",
                    style: TextStyle(
                      color: primaryWhite,
                      fontSize: 20,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildToolOption(
                      icon: Icons.qr_code,
                      label: "QR Generator",
                      color: lightPink,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QrGeneratorPage(),
                          ),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.security,
                      label: "IP Scanner",
                      color: lightPink,
                      onTap: () => _showComingSoon(context),
                    ),
                    _buildToolOption(
                      icon: Icons.network_check,
                      label: "Port Scanner",
                      color: lightPink,
                      onTap: () => _showComingSoon(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showStreamingTools(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border.all(color: primaryPink.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: primaryPink.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPink, accentPink],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.play_circle_fill, color: primaryWhite),
                  const SizedBox(width: 12),
                  Text(
                    "Streaming & Hiburan",
                    style: TextStyle(
                      color: primaryWhite,
                      fontSize: 20,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildToolOption(
                      icon: Icons.movie_filter,
                      label: "Anime Stream",
                      color: lightPink,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomeAnimePage(),
                          ),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.video_library,
                      label: "Donghua Stream",
                      color: lightPink,
                      onTap: () => _showComingSoon(context), // Bakal nampilin pop-up coming soon
                    ),
                    _buildToolOption(
                      icon: Icons.theaters,
                      label: "Drama China (Drachin)",
                      color: lightPink,
                      onTap: () => _showComingSoon(context), // Bakal nampilin pop-up coming soon
                    ),
                    _buildToolOption(
                      icon: Icons.live_tv,
                      label: "Movies & Series",
                      color: lightPink,
                      onTap: () => _showComingSoon(context), // Bakal nampilin pop-up coming soon
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickAccess(BuildContext context) {
    _showComingSoon(context);
  }

  Widget _buildToolOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: cardDark,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: primaryPink.withOpacity(0.3)),
      ),
      elevation: 4,
      shadowColor: primaryPink.withOpacity(0.2),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryPink.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: primaryPink.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: primaryWhite,
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: primaryPink.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_forward_ios, color: color, size: 14),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.hourglass_top, color: primaryWhite),
            SizedBox(width: 8),
            Text(
              'Feature Coming Soon!',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontWeight: FontWeight.bold,
                color: primaryWhite,
              ),
            ),
          ],
        ),
        backgroundColor: primaryPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 2),
      ),
    );
  }
}