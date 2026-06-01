import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  // --- TEMA WARNA BIRU (Diperbaiki agar bisa const) ---
  static const Color bgDark = Color(0xFF121212);
  static const Color primaryPurple = Color(0xFF2196F3);
  static const Color accentPurple = Color(0xFF6EB1FF);

  // Perbaikan: Menggunakan fromARGB(alpha, r, g, b) alih-alih withOpacity()
  // 0.05 * 255 ≈ 13
  // 0.1 * 255 ≈ 26
  static const Color cardGlass = Color.fromARGB(13, 255, 255, 255);
  static const Color borderGlass = Color.fromARGB(26, 255, 255, 255);

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: accentPurple),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Customer Service",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              bgDark,
              primaryPurple.withOpacity(0.1), // Ini aman karena ada di build()
              bgDark,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header Icon
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryPurple.withOpacity(0.2), // Aman di build()
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryPurple.withOpacity(
                          0.4,
                        ), // Aman di build()
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.support_agent_rounded,
                    size: 60,
                    color: accentPurple,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  "Need Help?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Contact us through our social media platforms below.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 14),
                ),
                SizedBox(height: 40),

                // Grid Buttons
                Column(
                  children: [
                    _buildContactButton(
                      label: "Telegram Developer",
                      icon: FontAwesomeIcons.telegram,
                      color: Colors.blue,
                      url: "https://t.me/Virzofc",
                    ),
                    SizedBox(height: 16),
                    _buildContactButton(
                      label: "Telegram Support",
                      icon: FontAwesomeIcons.telegram,
                      color: Colors.blue,
                      url: "https://t.me/hyrinestur",
                    ),
                    SizedBox(height: 16),
                    _buildContactButton(
                      label: "Telegram Channel",
                      icon: FontAwesomeIcons.telegram,
                      color: Colors.blue,
                      url: "https://t.me/AllinformationVirz",
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required String label,
    required IconData icon,
    required Color color,
    required String url,
  }) {
    return InkWell(
      onTap: () => _launchUrl(url),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: cardGlass,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderGlass),
          boxShadow: [
            BoxShadow(
              color: primaryPurple.withOpacity(0.1), // Aman di build()
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2), // Aman di build()
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(icon, color: color, size: 24),
                ),
                SizedBox(width: 20),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }
}