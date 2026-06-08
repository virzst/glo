import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'btrapps/.dart';
final baseUrl = Api.api;

class HomePage extends StatefulWidget {
  final String username;
  final String password;
  final String sessionKey;
  final List<Map<String, dynamic>> listBug;
  final String role;
  final String expiredDate;

  const HomePage({
    super.key,
    required this.username,
    required this.password,
    required this.sessionKey,
    required this.listBug,
    required this.role,
    required this.expiredDate,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final targetController = TextEditingController();
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  
  // Multi-select bug IDs
  Set<String> selectedBugIds = {};

  // Mode Target
  String _selectedBugMode = "number";

  // Channel list and selected channel
  List<Map<String, dynamic>> _channelList = [];
  Map<String, dynamic>? _selectedChannel;
  bool _isLoadingChannels = false;

  bool _isSending = false;
  String? _responseMessage;

  // Tema Warna Biru
  final Color primaryBg = const Color(0xFF121212);
  final Color cardBg = const Color(0xFF2A2A2D);
  final Color primaryPink = const Color(0xFF2196F3);
  final Color accentPink = const Color(0xFF6EB1FF);
  final Color deepPink = const Color(0xFF1976D2);
  final Color textWhite = Colors.white;
  final Color textGrey = Colors.grey.shade400;

  // Gradients
  final LinearGradient pinkGradient = const LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF6EB1FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Video Player Variables
  late VideoPlayerController _videoController;
  late ChewieController _chewieController;
  bool _isVideoInitialized = false;
@override
void initState() {
  super.initState();

  _fadeController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);

  fetchSender();

  _initializeVideoPlayer();
}

  void _initializeVideoPlayer() {
    _videoController = VideoPlayerController.asset('assets/videos/banner.mp4');

    _videoController.initialize().then((_) {
      setState(() {
        _videoController.setVolume(0.0);
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: true,
          looping: true,
          showControls: false,
          autoInitialize: true,
        );
        _isVideoInitialized = true;
      });
    }).catchError((error) {
      print("Video initialization error: $error");
      setState(() {
        _isVideoInitialized = false;
      });
    });
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    _pulseController?.dispose();
    targetController?.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  String? formatPhoneNumber(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.length < 8) return null;
    return cleaned;
  }

  bool isValidGroupLink(String input) {
    return input.contains('chat.whatsapp.com') && input.contains('https://');
  }

  Future<void> _fetchUserChannels() async {
    setState(() {
      _isLoadingChannels = true;
      _channelList = [];
      _selectedChannel = null;
    });

    try {
      final res = await http.get(Uri.parse("$baseUrl/mych?key=${widget.sessionKey}"));
      final data = jsonDecode(res.body);

      if (data["valid"] == true && data["sender"] == true && data["channel"] != null) {
        setState(() {
          _channelList = List<Map<String, dynamic>>.from(data["channel"]);
        });
      } else {
        _showAlert("❌ Gagal Memuat Channel", "Tidak dapat mengambil daftar channel.");
      }
    } catch (e) {
      _showAlert("❌ Error", "Terjadi kesalahan saat memuat channel.");
    } finally {
      setState(() {
        _isLoadingChannels = false;
      });
    }
  }

  void _showChannelSelectionPopup() {
    if (_channelList.isEmpty) {
      _fetchUserChannels();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: primaryPink.withOpacity(0.5), width: 1),
              ),
              title: Row(
                children: [
                  Icon(Icons.campaign, color: accentPink, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    "PILIH CHANNEL",
                    style: TextStyle(
                      color: textWhite,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Orbitron',
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: _isLoadingChannels
                    ? Center(
                        child: CircularProgressIndicator(
                          color: accentPink,
                        ),
                      )
                    : _channelList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.info_outline, color: textGrey, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  "Tidak ada channel yang ditemukan",
                                  style: TextStyle(color: textGrey),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _fetchUserChannels();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accentPink,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("Refresh"),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _channelList.length,
                            itemBuilder: (context, index) {
                              final channel = _channelList[index];
                              final isSelected = _selectedChannel?['id'] == channel['id'];
                              
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected ? primaryPink.withOpacity(0.2) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? accentPink : primaryPink.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: isSelected ? accentPink : textGrey,
                                  ),
                                  title: Text(
                                    channel['title'] ?? 'Unknown Channel',
                                    style: TextStyle(
                                      color: textWhite,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontFamily: 'ShareTechMono',
                                    ),
                                  ),
                                  subtitle: Text(
                                    'ID: ${channel['id']}',
                                    style: TextStyle(color: textGrey, fontSize: 12),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedChannel = channel;
                                    });
                                  },
                                ),
                              );
                            },
                          ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "CANCEL",
                    style: TextStyle(color: textGrey, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _selectedChannel == null ? null : () {
                    setState(() {
                      targetController.text = _selectedChannel!['title'] ?? '';
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBugSelectionPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: primaryPink.withOpacity(0.5), width: 1),
              ),
              title: Row(
                children: [
                  Icon(Icons.bug_report, color: accentPink, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    "PILIH BUG",
                    style: TextStyle(
                      color: textWhite,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Orbitron',
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.listBug.length,
                  itemBuilder: (context, index) {
                    final bug = widget.listBug[index];
                    final bugId = bug['bug_id'];
                    final isSelected = selectedBugIds.contains(bugId);
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryPink.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? accentPink : primaryPink.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isSelected ? accentPink : textGrey,
                        ),
                        title: Text(
                          bug['bug_name'],
                          style: TextStyle(
                            color: textWhite,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontFamily: 'ShareTechMono',
                          ),
                        ),
                        subtitle: bug['description'] != null ? Text(
                          bug['description'],
                          style: TextStyle(color: textGrey, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ) : null,
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedBugIds.remove(bugId);
                            } else {
                              selectedBugIds.add(bugId);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedBugIds.clear();
                    });
                  },
                  child: Text(
                    "RESET",
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "CANCEL",
                    style: TextStyle(color: textGrey, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: selectedBugIds.isEmpty ? null : () {
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _sendBug() async {
    final rawInput = targetController.text.trim();
    final key = widget.sessionKey;
    final senderConnected = selectedSender == "private"
    ? await fetchSender()
    : await fetchSenderGlobal();

if (!senderConnected) {
  _showAlert(
    "Sender Offline",
    selectedSender == "private"
        ? "Private sender tidak terhubung."
        : "Global sender tidak terhubung.",
  );
  return;
}

    if (_selectedBugMode == "number") {
      final target = formatPhoneNumber(rawInput);
      if (target == null || key.isEmpty) {
        _showAlert("❌ Invalid Number", "Gunakan nomor internasional (misal: +62, 1, 44), bukan 08xxx.");
        return;
      }
      
      if (selectedBugIds.isEmpty) {
        _showAlert("❌ No Bug Selected", "Pilih minimal 1 bug untuk dikirim.");
        return;
      }
    } else if (_selectedBugMode == "group") {
      if (!isValidGroupLink(rawInput)) {
        _showAlert("❌ Invalid Link", "Masukkan link group WA yang valid (contoh: https://chat.whatsapp.com/...).");
        return;
      }
      
      if (selectedBugIds.isEmpty) {
        _showAlert("❌ No Bug Selected", "Pilih minimal 1 bug untuk dikirim.");
        return;
      }
    } else if (_selectedBugMode == "channel") {
      if (_selectedChannel == null) {
        _showAlert("❌ No Channel Selected", "Pilih channel tujuan terlebih dahulu.");
        return;
      }
      // Untuk channel, tidak perlu selectedBugIds
    }

    setState(() {
      _isSending = true;
      _responseMessage = null;
    });

    try {
      late http.Response res;
      late Map<String, dynamic> data;

      if (_selectedBugMode == "channel") {
        // Channel raid
        res = await http.get(Uri.parse(
            "$baseUrl/raidch?key=$key&id=${_selectedChannel!['id']}"));
        data = jsonDecode(res.body);

        if (data["cooldown"] == true) {
          setState(() => _responseMessage = "⏳ Cooldown: Tunggu beberapa saat.");
        } else if (data["valid"] == false) {
          setState(() => _responseMessage = "❌ Key Invalid: Silakan login ulang.");
        } else if (data["sender"] == false) {
          setState(() => _responseMessage = "❌ Sender Anda Kosong.");
        } else if (data["sended"] == false) {
          setState(() => _responseMessage = "⚠️ Gagal: Server sedang maintenance.");
        } else {
          setState(() => _responseMessage = "✅ Berhasil mengirim bug ke channel!");
          targetController.clear();
          _selectedChannel = null;
        }
      } else {
        // Number or Group raid
        final bugsParam = selectedBugIds.join(',');
        final apiType = _selectedBugMode == "number" ? "sendBug" : "raidGrouP";
        res = await http.get(Uri.parse(
            "$baseUrl/$apiType?key=$key&target=$rawInput&bug=$bugsParam"));
        data = jsonDecode(res.body);

        if (data["cooldown"] == true) {
          setState(() => _responseMessage = "⏳ Cooldown: Tunggu beberapa saat.");
        } else if (data["valid"] == false) {
          setState(() => _responseMessage = "❌ Key Invalid: Silakan login ulang.");
        } else if (data["sender"] == false) {
          setState(() => _responseMessage = "❌ Sender Anda Kosong.");
        } else if (data["sended"] == false) {
          setState(() => _responseMessage = "⚠️ Gagal: Server sedang maintenance.");
        } else {
          setState(() => _responseMessage = "✅ Berhasil mengirim bug!");
          targetController.clear();
          selectedBugIds.clear();
        }
      }
    } catch (_) {
      setState(() => _responseMessage = "❌ Error: Terjadi kesalahan. Coba lagi.");
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _showAlert(String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: primaryPink.withOpacity(0.5)),
        ),
        title: Text(title,
            style: const TextStyle(
              color: Color(0xFF6EB1FF),
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.bold,
            )),
        content: Text(msg,
            style: const TextStyle(
                color: Colors.grey,
                fontFamily: 'ShareTechMono'
            )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK",
                style: TextStyle(
                  color: Color(0xFF2196F3),
                  fontWeight: FontWeight.bold,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryPink.withOpacity(0.3),
          width: 1,
        ),
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
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: pinkGradient,
              boxShadow: [
                BoxShadow(
                  color: accentPink.withOpacity(0.6),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage('assets/images/logo.png'),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryPink.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryPink.withOpacity(0.3)),
                  ),
                  child: Text(
                    "Role: ${widget.role.toUpperCase()} • Exp: ${widget.expiredDate}",
                    style: TextStyle(
                      color: accentPink,
                      fontFamily: 'ShareTechMono',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (!_isVideoInitialized) {
      return Container(
        width: double.infinity,
        height: 200,
        margin: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: accentPink,
            strokeWidth: 3,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryPink.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: accentPink.withOpacity(0.3), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: _videoController.value.aspectRatio,
          child: Stack(
            children: [
              Chewie(controller: _chewieController),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      primaryPink.withOpacity(0.2),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedBugMode = "number";
                targetController.clear();
                _selectedChannel = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: BoxDecoration(
                color: _selectedBugMode == "number"
                    ? accentPink.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedBugMode == "number" ? accentPink : primaryPink.withOpacity(0.3),
                  width: _selectedBugMode == "number" ? 2 : 1,
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown, // Ini kuncinya biar gak overflow
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_android_rounded,
                      color: _selectedBugMode == "number" ? accentPink : textGrey,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "BUG NOMOR",
                      style: TextStyle(
                        color: _selectedBugMode == "number" ? accentPink : textGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        fontFamily: 'Orbitron',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8), // Jarak antar tombol dikurangi biar muat
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedBugMode = "group";
                targetController.clear();
                _selectedChannel = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: BoxDecoration(
                color: _selectedBugMode == "group"
                    ? accentPink.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedBugMode == "group" ? accentPink : primaryPink.withOpacity(0.3),
                  width: _selectedBugMode == "group" ? 2 : 1,
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.group_add,
                      color: _selectedBugMode == "group" ? accentPink : textGrey,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "BUG GROUP",
                      style: TextStyle(
                        color: _selectedBugMode == "group" ? accentPink : textGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        fontFamily: 'Orbitron',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedBugMode = "channel";
                targetController.clear();
                selectedBugIds.clear();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: BoxDecoration(
                color: _selectedBugMode == "channel"
                    ? accentPink.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedBugMode == "channel" ? accentPink : primaryPink.withOpacity(0.3),
                  width: _selectedBugMode == "channel" ? 2 : 1,
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.campaign,
                      color: _selectedBugMode == "channel" ? accentPink : textGrey,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "BUG CHANNEL",
                      style: TextStyle(
                        color: _selectedBugMode == "channel" ? accentPink : textGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        fontFamily: 'Orbitron',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildInputPanel() {
   return Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [

    _buildSenderSelector(),
    Container(
  margin: const EdgeInsets.only(top: 10),
  width: double.infinity,
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: cardBg,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    senderList.isNotEmpty
        ? senderList.first["sessionName"].toString()
        : "No Sender Connected",
    textAlign: TextAlign.center,
    style: TextStyle(
      color: senderList.isNotEmpty
          ? Colors.greenAccent
          : Colors.redAccent,
      fontWeight: FontWeight.bold,
    ),
  ),
),

    const SizedBox(height: 20),

    Container(
      margin: const EdgeInsets.only(top: 10),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        senderList.isNotEmpty
            ? senderList.first["sessionName"].toString()
            : "No Sender Connected",
        textAlign: TextAlign.center,
      ),
    ),

    const SizedBox(height: 20),
    
    
    Widget _buildSenderSelector() {
  return Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: primaryPink.withOpacity(0.4),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              setState(() {
                selectedSender = "private";
              });

              final connected = await fetchSender();

              if (!connected) {
                _showAlert(
                  "Sender Offline",
                  "Private sender tidak terhubung.",
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: selectedSender == "private"
                    ? accentPink
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "PRIVATE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Expanded(
          child: GestureDetector(
            onTap: () async {
              setState(() {
                selectedSender = "global";
              });

              final connected = await fetchSenderGlobal();

              if (!connected) {
                _showAlert(
                  "Sender Offline",
                  "Global sender tidak terhubung.",
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: selectedSender == "global"
                    ? Colors.amber
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.public, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "GLOBAL",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
    _buildModeSelector(),
    
     return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildModeSelector(),
        const SizedBox(height: 30),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Text(
            _selectedBugMode == "number" ? "NOMOR TARGET" : 
            _selectedBugMode == "group" ? "LINK GROUP WA" : "PILIH CHANNEL",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              fontFamily: 'Orbitron',
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        if (_selectedBugMode == "channel")
          GestureDetector(
            onTap: _showChannelSelectionPopup,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryPink.withOpacity(0.3), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _selectedChannel == null
                        ? Text(
                            "Klik untuk memilih channel",
                            style: TextStyle(color: textGrey, fontSize: 14),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedChannel!['title'] ?? 'Unknown Channel',
                                style: TextStyle(
                                  color: textWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "ID: ${_selectedChannel!['id']}",
                                style: TextStyle(
                                  color: textGrey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                  Icon(Icons.arrow_drop_down, color: accentPink, size: 28),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: targetController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              cursorColor: accentPink,
              keyboardType: _selectedBugMode == "number" ? TextInputType.phone : TextInputType.url,
              decoration: InputDecoration(
                hintText: _selectedBugMode == "number"
                    ? "Contoh: +62xxxxxxxxxx"
                    : "Contoh: https://chat.whatsapp.com/...",
                hintStyle: TextStyle(color: textGrey.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: primaryPink.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF6EB1FF), width: 2),
                ),
                prefixIcon: Icon(
                  _selectedBugMode == "number" ? Icons.phone_android_rounded : Icons.link,
                  color: accentPink,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              ),
            ),
          ),

        if (_selectedBugMode != "channel") ...[
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "PILIH BUG",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    fontFamily: 'Orbitron',
                    letterSpacing: 1.5,
                  ),
                ),
                if (selectedBugIds.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentPink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${selectedBugIds.length} dipilih",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _showBugSelectionPopup,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryPink.withOpacity(0.3), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: selectedBugIds.isEmpty
                        ? Text(
                            "Klik untuk memilih bug",
                            style: TextStyle(color: textGrey, fontSize: 14),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: selectedBugIds.map((bugId) {
                              final bug = widget.listBug.firstWhere(
                                (b) => b['bug_id'] == bugId,
                                orElse: () => {'bug_name': 'Unknown'},
                              );
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryPink.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: accentPink.withOpacity(0.5)),
                                ),
                                child: Text(
                                  bug['bug_name'],
                                  style: TextStyle(color: accentPink, fontSize: 12),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  Icon(Icons.arrow_drop_down, color: accentPink, size: 28),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSendButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          height: 65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: pinkGradient,
            boxShadow: [
              BoxShadow(
                color: accentPink.withOpacity(0.4),
                blurRadius: _pulseController.value * 25,
                spreadRadius: _pulseController.value * 2,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isSending ? null : _sendBug,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
            ),
            child: _isSending
                ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 22),
                SizedBox(width: 12),
                Text(
                  "SEND BUG ATTACK",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 2,
                    fontFamily: 'Orbitron',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponseMessage() {
    if (_responseMessage == null) return const SizedBox.shrink();

    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData icon;

    if (_responseMessage!.startsWith('✅')) {
      bgColor = Colors.green.withOpacity(0.15);
      borderColor = Colors.greenAccent;
      textColor = Colors.greenAccent;
      icon = Icons.check_circle_outline_rounded;
    } else if (_responseMessage!.startsWith('❌')) {
      bgColor = Colors.red.withOpacity(0.15);
      borderColor = Colors.redAccent;
      textColor = Colors.redAccent;
      icon = Icons.error_outline_rounded;
    } else {
      bgColor = primaryPink.withOpacity(0.15);
      borderColor = accentPink;
      textColor = accentPink;
      icon = Icons.info_outline_rounded;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _responseMessage!,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'ShareTechMono',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeaderPanel(),
              const SizedBox(height: 20),
              _buildVideoPlayer(),
              const SizedBox(height: 20),
              _buildInputPanel(),
              const SizedBox(height: 40),
              _buildSendButton(),
              _buildResponseMessage(),
            ],
          ),
        ),
      ),
    );
  }
}