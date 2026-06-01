import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'nik_check.dart';
import 'admin_page.dart';
import 'owner_page.dart';
import 'home_page.dart';
import 'seller_page.dart';
import 'change_password_page.dart';
import 'tools_gateway.dart';
import 'login_page.dart';
import 'bug_sender.dart';
import 'contact_page.dart';
import 'profile_page.dart';
import 'riwayat_page.dart';
import 'info_page.dart';
import 'publik_chat.dart';
import 'tq_to.dart';
import 'anime_home.dart';
import 'btrapps/.dart';
final baseUrl = Api.api;

class DashboardPage extends StatefulWidget {
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

  const DashboardPage({
    super.key,
    required this.userId,       // <--- INI DITAMBAHIN
    required this.level,        // <--- INI DITAMBAHIN
    required this.username,
    required this.password,
    required this.role,
    required this.expiredDate,
    required this.listBug,
    required this.listDoos,
    required this.sessionKey,
    required this.news,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late String sessionKey;
  late String username;
  late String password;
  late String role;
  late String expiredDate;
  late List<Map<String, dynamic>> listBug;
  late List<Map<String, dynamic>> listDoos;
  late List<dynamic> newsList;
  String androidId = "unknown";
  File? _profileImage;
  VideoPlayerController? _menuVideoController;
  int _bottomNavIndex = 0;
  late Widget _selectedPage;
  int onlineUsers = 0;
  int activeConnections = 0;
  final Color bgDark = const Color(0xFF121212);
  final Color primaryPink = const Color(0xFF1E1E1E);
  final Color accentPink = const Color(0xFF333333);
  final Color lightPink = const Color(0xFF555555);
  final Color primaryWhite = Colors.white;
  final Color accentGrey = Colors.grey.shade400;
  final Color cardGlass = Colors.white.withOpacity(0.05);
  final Color borderGlass = Colors.white.withOpacity(0.1);
  PageController _pageController = PageController();
  int _currentNewsIndex = 0;
  final Color cardDark = const Color(0xFF2A2A2D);
  final Color cardDarker = const Color(0xFF1A1A1C);
  final Color goldColor = const Color(0xFF333333);
  final Color primaryDark = const Color(0xFF000000);
  bool _isAudioInitialized = false;
  
@override
  void initState() {
    super.initState();
    sessionKey = widget.sessionKey;
    username = widget.username;
    password = widget.password;
    role = widget.role;
    expiredDate = widget.expiredDate;
    listBug = widget.listBug;
    listDoos = widget.listDoos;
    newsList = widget.news;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    _selectedPage = _buildNewsPage();
    _pageController = PageController();
    _loadProfileImage();
    _initMenuVideo();

    _fetchDashboardStats();
  }
  
  Future<void> _fetchDashboardStats() async {
    try {
      final response = await http.get(Uri.parse('${Api.api}/api/dashboard-stats'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            onlineUsers = data['onlineUsers'] ?? 0;
            activeConnections = data['activeConnections'] ?? 0;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetch stats: $e");
    }
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_$username');
    if (imagePath != null && imagePath.isNotEmpty) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }
  
  void _initMenuVideo() {
    _menuVideoController = VideoPlayerController.asset('assets/videos/banner.mp4')
      ..initialize().then((_) {
        setState(() {});
        _menuVideoController?.setLooping(true);
        _menuVideoController?.setVolume(0.0);
        _menuVideoController?.play();
      });
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $uri");
    }
  }

  void _handleInvalidSession(String message) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: bgDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text("⚠️ Session Expired", style: TextStyle(color: accentPink, fontWeight: FontWeight.bold)),
        content: Text(message, style: TextStyle(color: accentGrey)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
              );
            },
            child: Text("OK", style: TextStyle(color: primaryPink, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
      if (index == 0) {
        _selectedPage = _buildNewsPage();
      } else if (index == 1) {
        _selectedPage = HomePage(
          username: username,
          password: password,
          listBug: listBug,
          role: role,
          expiredDate: expiredDate,
          sessionKey: sessionKey,
        );
      } else if (index == 2) {
        _selectedPage = InfoPage(
          sessionKey: sessionKey);
      } else if (index == 3) {
        _selectedPage = ToolsPage(
            username: username, sessionKey: sessionKey, userRole: role, listDoos: listDoos);
      }
    });
  }

  void _onSidebarTabSelected(int index) {
    setState(() {
      if (index == 1) {
        _selectedPage = SellerPage(keyToken: sessionKey);
      } else if (index == 2) {
        _selectedPage = AdminPage(sessionKey: sessionKey);
      } else if (index == 3) {
        _selectedPage = OwnerPage(sessionKey: sessionKey, username: username);
      }
    });
    Navigator.pop(context);
  }

  Widget _buildNewsPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardGlass,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderGlass, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: primaryPink.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildCompactInfoItem(
                      icon: Icons.people,
                      label: "Online",
                      value: "$onlineUsers",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCompactInfoItem(
                      icon: Icons.link,
                      label: "Connections",
                      value: "$activeConnections",
                    ),
                  ),
                ],
              ),
            ),
          ),          
          _buildNewsList(),
          const SizedBox(height: 24),
          _buildNewsCarousel(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: cardGlass,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderGlass, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: primaryPink.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      icon: const Icon(FontAwesomeIcons.telegram, color: Colors.white, size: 22),
                      label: const Text(
                        "Channel Information",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Orbitron',
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
                        _openUrl("https://t.me/AllinformationVirz");
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: cardGlass,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderGlass, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: primaryPink.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.favorite, color: Colors.white, size: 20),
                      label: const Text(
                        "Tq To Team",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Orbitron',
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TqPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
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
                    child: ElevatedButton.icon(
                      icon: const Icon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 20),
                      label: const Text(
                        "Manage Sender",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Orbitron',
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BugSenderPage(
                              sessionKey: sessionKey,
                              username: username,
                              role: role,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
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
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat, color: Colors.white, size: 20),
                      label: const Text(
                        "Publik Chat",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Orbitron',
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommunityPage(
                              username: username,
                              role: role,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNewsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [cardDark, cardDarker],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _VideoPlayerAsset(),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryDark.withOpacity(0.8),
                      Colors.transparent,
                      goldColor.withOpacity(0.1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: Text(
                  "PRIKITIWW APPS",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCarousel() {
    if (newsList.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black.withOpacity(0.3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "No news available",
            style: TextStyle(
              color: Colors.white54,
              fontFamily: "ShareTechMono",
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            itemCount: newsList.length,
            onPageChanged: (index) {
              setState(() {
                _currentNewsIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final item = newsList[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (item['image'] != null && item['image'].toString().isNotEmpty)
                        NewsMedia(url: item['image']),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] ?? 'No Title',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: "Orbitron",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['desc'] ?? '',
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontFamily: "ShareTechMono"),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (newsList.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              newsList.length,
                  (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                height: 8,
                width: _currentNewsIndex == index ? 24 : 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: _currentNewsIndex == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAccessButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: cardGlass,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentPink.withOpacity(0.4)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: accentPink, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case "owner":
        return accentPink;
      case "vip":
        return primaryPink;
      case "reseller":
        return Colors.lightGreenAccent;
      case "premium":
        return Colors.orangeAccent;
      default:
        return lightPink;
    }
  }

  Widget _buildCompactInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderGlass),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryPink.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentPink, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: accentGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'ShareTechMono',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDrawer() {
    return Drawer(
      backgroundColor: bgDark,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 250,
            color: Colors.black,
            child: Stack(
              children: [
                if (_menuVideoController != null && _menuVideoController!.value.isInitialized)
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _menuVideoController!.value.size.width,
                        height: _menuVideoController!.value.size.height,
                        child: VideoPlayer(_menuVideoController!),
                      ),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: accentPink, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: primaryPink.withOpacity(0.6),
                                blurRadius: 15,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: ClipOval(
                            child: _profileImage != null
                                ? Image.file(
                              _profileImage!,
                              fit: BoxFit.cover,
                            )
                                : Icon(
                              FontAwesomeIcons.userAstronaut,
                              size: 50,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Orbitron',
                          ),
                        ),
                        Text(
                          role.toUpperCase(),
                          style: TextStyle(
                            color: accentPink,
                            fontSize: 14,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              color: bgDark,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  if (role == "reseller")
                    _buildDrawerMenuItem(
                      icon: Icons.storefront,
                      label: "Seller Page",
                      onTap: () => _onSidebarTabSelected(1),
                    ),

                  if (role == "admin")
                    _buildDrawerMenuItem(
                      icon: Icons.admin_panel_settings,
                      label: "Admin Page",
                      onTap: () => _onSidebarTabSelected(2),
                    ),

                  if (role == "owner")
                    _buildDrawerMenuItem(
                      icon: Icons.workspace_premium,
                      label: "Owner Page",
                      onTap: () => _onSidebarTabSelected(3),
                    ),

                  _buildDrawerMenuItem(
                    icon: Icons.history_rounded,
                    label: "Riwayat Aktivitas",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RiwayatPage(
                            sessionKey: sessionKey,
                            role: role,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  _buildDrawerMenuItem(
                 icon: Icons.movie_filter,
                 label: "Nonton Anime",
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

                  const SizedBox(height: 20),

                  _buildDrawerMenuItem(
                    icon: Icons.logout,
                    label: "Log Out",
                    isLogout: true,
                    onTap: () async {
                      Navigator.pop(context);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      if (!mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                            (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isLogout
            ? Colors.red.withOpacity(0.2)
            : cardGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLogout ? Colors.red.withOpacity(0.5) : borderGlass,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.redAccent : accentPink,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isLogout ? Colors.redAccent : primaryWhite,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white38,
          size: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: Row(
          children: const [
            SizedBox(width: 16),
            Icon(FontAwesomeIcons.key, color: Colors.amber, size: 16),
            SizedBox(width: 8),
            Text("0", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'ShareTechMono')),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(username: username, password: password, role: role, expiredDate: expiredDate, sessionKey: sessionKey)));
            },
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(username, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text("#${widget.userId}", style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'ShareTechMono')),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Row(
                            children: [
                              const Icon(Icons.military_tech, color: Colors.grey, size: 10),
                              const SizedBox(width: 2),
                              Text("Lvl. ${widget.level}", style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 1.5)),
                  child: ClipOval(
                    child: _profileImage != null
                        ? Image.file(_profileImage!, fit: BoxFit.cover)
                        : const Icon(FontAwesomeIcons.userAstronaut, color: Colors.amber, size: 22),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26),
                onPressed: () { },
              ),
              Positioned(
                top: 10, right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Text("8", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildCustomDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF3D1B1B),
              bgDark,
              bgDark,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(opacity: _animation, child: _selectedPage),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          currentIndex: _bottomNavIndex,
          onTap: _onBottomNavTapped,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.home, color: Colors.black),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: const Icon(FontAwesomeIcons.whatsapp),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: const Icon(FontAwesomeIcons.whatsapp, color: Colors.black),
              ),
              label: "WhatsApp",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.notifications_none),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.notifications_none, color: Colors.black),
              ),
              label: "Info",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.build_circle_outlined),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.build_circle_outlined, color: Colors.black),
              ),
              label: "Tools",
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _menuVideoController?.dispose();
    _pageController?.dispose();
    super.dispose();
  }
}

class _VideoPlayerAsset extends StatefulWidget {
  const _VideoPlayerAsset();

  @override
  __VideoPlayerAssetState createState() => __VideoPlayerAssetState();
}

class __VideoPlayerAssetState extends State<_VideoPlayerAsset> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/banner.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0.0);
        _controller.play();
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.value.isInitialized) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      );
    } else {
      return Container(
        color: const Color(0xFF1A1A1A),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFFE91E63)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class NewsMedia extends StatefulWidget {
  final String url;
  const NewsMedia({super.key, required this.url});

  @override
  State<NewsMedia> createState() => _NewsMediaState();
}

class _NewsMediaState extends State<NewsMedia> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (_isVideo(widget.url)) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) {
          setState(() {});
          _controller?.setLooping(true);
          _controller?.setVolume(0.0);
          _controller?.play();
        });
    }
  }

  bool _isVideo(String url) {
    return url.endsWith(".mp4") ||
        url.endsWith(".webm") ||
        url.endsWith(".mov") ||
        url.endsWith(".mkv");
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isVideo(widget.url)) {
      if (_controller != null && _controller!.value.isInitialized) {
        return AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF80AB),
          ),
        );
      }
    } else {
      return Image.network(
        widget.url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade800,
          child: const Icon(Icons.error, color: Color(0xFFFF80AB)),
        ),
      );
    }
  }
}