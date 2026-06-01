import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'btrapps/.dart';
final baseUrl = Api.api;
final AudioPlayer _audioPlayer = AudioPlayer();

class InfoPage extends StatefulWidget {
  final String sessionKey;

  const InfoPage({super.key, required this.sessionKey});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  Map<String, dynamic>? serverInfo;
  bool isLoading = true;

  bool isApiOnline = false;
  int apiPingMs = 0;
  Color apiStatusColor = Colors.grey;
  String apiStatusText = "Checking...";
  Timer? _pingTimer;

  // TEMA WARNA BIRU
  final Color bgDark = const Color(0xFF121212);
  final Color primaryPink = const Color(0xFF2196F3);
  final Color accentPink = const Color(0xFF6EB1FF);
  final Color primaryWhite = Colors.white;
  final Color textGrey = Colors.grey.shade400;
  final Color cardGlass = Colors.white.withOpacity(0.05);
  final Color borderGlass = Colors.white.withOpacity(0.1);

  @override
  void initState() async {
    super.initState();
    _fetchServerInfo();
    _startApiPingLoop();
    await _audioPlayer.resume();
  }

  @override
  void dispose() {
    _pingTimer?.cancel();
    _audioPlayer?.pause();
    super.dispose();
  }

  Future<void> _fetchServerInfo() async {
    try {
      final res = await http.get(
        Uri.parse('${baseUrl}/getServerInfo?key=${widget.sessionKey}'),
      );
      if (res.statusCode == 200) {
        setState(() {
          serverInfo = jsonDecode(res.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _startApiPingLoop() {
    _checkApiPing();
    _pingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkApiPing();
    });
  }

  Future<void> _checkApiPing() async {
    final start = DateTime.now();
    try {
      final res = await http.get(
        Uri.parse('${baseUrl}/ping?key=${widget.sessionKey}'),
      ).timeout(const Duration(seconds: 3));

      final end = DateTime.now();
      final duration = end.difference(start).inMilliseconds;

      if (res.statusCode == 200) {
        setState(() {
          isApiOnline = true;
          apiPingMs = duration;
          if (duration < 200) {
            apiStatusColor = Colors.greenAccent;
          } else if (duration < 500) {
            apiStatusColor = Colors.amber;
          } else {
            apiStatusColor = Colors.orangeAccent;
          }
          apiStatusText = "Online (${duration}ms)";
        });
      } else {
        throw Exception("Failed");
      }
    } catch (e) {
      setState(() {
        isApiOnline = false;
        apiPingMs = 0;
        apiStatusColor = Colors.redAccent;
        apiStatusText = "Offline";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: bgDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text("Info", style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF2196F3)),
        ),
      );
    }

    final List<Map<String, String>> rulesList = [
      {
        "title": "Larangan Barter Akun",
        "desc": "Akun tidak boleh ditukar dengan barang, jasa, atau akun lain dalam bentuk apa pun."
      },
      {
        "title": "Larangan Membagikan Akun",
        "desc": "Setiap akun bersifat pribadi dan hanya boleh digunakan oleh pemilik akun yang terdaftar."
      },
      {
        "title": "Larangan Menjual Akun",
        "desc": "Member TIDAK diperbolehkan menjual akun. Penjualan akun hanya boleh dilakukan oleh role yang diizinkan secara resmi."
      },
      {
        "title": "Larangan Jual Durasi Ilegal",
        "desc": "Dilarang menjual akses harian, mingguan, trial, atau sejenisnya di luar ketentuan yang telah ditetapkan."
      },
      {
        "title": "Larangan Banting Harga",
        "desc": "Dilarang merusak atau menurunkan harga yang telah ditentukan (banting harga) di bawah ketentuan FIXCH."
      },
    ];

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "PERATURAN & INFO",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompactApiStatus(),
            const SizedBox(height: 20),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryPink.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.gavel, color: Color(0xFF6EB1FF), size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  "PERATURAN PENGGUNA",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Orbitron',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            ...rulesList.asMap().entries.map((entry) {
              int index = entry.key + 1;
              Map<String, String> rule = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardGlass,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderGlass),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: accentPink.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: accentPink.withOpacity(0.4)),
                            ),
                            child: Text(
                              "Rule $index",
                              style: TextStyle(
                                color: accentPink,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Orbitron',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rule['title']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rule['desc']!,
                        style: TextStyle(
                          color: textGrey,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withOpacity(0.1),
                    Colors.red.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                      const SizedBox(width: 10),
                      const Text(
                        "SANKSI",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Orbitron',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Jika pengguna terbukti melanggar salah satu peraturan di atas:",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Akun akan DIHAPUS secara permanen 🚫",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Tanpa pengembalian akun, saldo, atau kompensasi apa pun ‼️",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: Column(
                children: [
                  Icon(Icons.shield_moon_rounded, color: accentPink, size: 30),
                  const SizedBox(height: 12),
                  Text(
                    "Peraturan ini dibuat untuk menjaga keamanan, kenyamanan, dan kestabilan ekosistem FIXCH App. Dengan menggunakan aplikasi ini, pengguna dianggap telah menyetujui seluruh peraturan di atas.",
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 4,
                    width: 100,
                    decoration: BoxDecoration(
                      color: accentPink,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactApiStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardGlass,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderGlass),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: apiStatusColor,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: apiStatusColor.withOpacity(0.5), blurRadius: 5)],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "System Status: ${apiStatusText.toUpperCase()}",
            style: TextStyle(
              color: textGrey,
              fontSize: 13,
              fontFamily: 'ShareTechMono',
            ),
          ),
        ],
      ),
    );
  }
}