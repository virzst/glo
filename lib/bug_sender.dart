import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'btrapps/.dart';
final baseUrl = Api.api;

class BugSenderPage extends StatefulWidget {
  final String sessionKey;
  final String username;
  final String role;

  const BugSenderPage({
    super.key,
    required this.sessionKey,
    required this.username,
    required this.role,
  });

  @override
  State<BugSenderPage> createState() => _BugSenderPageState();
}

class _BugSenderPageState extends State<BugSenderPage> {
  List<dynamic> senderList = [];
  List<dynamic> globalSenderList = [];
  bool isLoading = false;
  bool isRefreshing = false;
  String? errorMessage;

  // --- TEMA WARNA UNGU ---
  final Color bgDark = const Color(0xFF1A0500);
  final Color primaryPurple = const Color(0xFFD50000);
  final Color accentPurple = const Color(0xFFFFD600);
  final Color lightPurple = const Color(0xFFFFAB00);
  final Color primaryWhite = Colors.white;
  final Color cardGlass = Colors.white.withOpacity(0.05);
  final Color borderGlass = Colors.white.withOpacity(0.1);
  
  @override
  void initState() {
  super.initState();
   _fetchSenders();
   _fetchSendersGlobal();
}

  Future<void> _fetchSenders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse("${baseUrl}/mySender?key=${widget.sessionKey}"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["valid"] == true) {
          setState(() {
            senderList = data["connections"] ?? [];
          });
        } else {
          setState(() {
            errorMessage = data["message"] ?? "Failed to fetch senders";
          });
        }
      } else {
        setState(() {
          errorMessage = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Connection failed: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
        isRefreshing = false;
      });
    }
  }
  
  Future<void> _fetchSendersGlobal() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse("${baseUrl}/mySenderGlobal?key=${widget.sessionKey}"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["valid"] == true) {
          setState(() {
            senderList = data["connections"] ?? [];
          });
        } else {
          setState(() {
            errorMessage = data["message"] ?? "Failed to fetch senders";
          });
        }
      } else {
        setState(() {
          errorMessage = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Connection failed: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
        isRefreshing = false;
      });
    }
  }
  
  Future<void> _refreshSenders() async { 
  setState(() => isRefreshing = true);
  
  await _fetchSenders();
  await _fetchSendersGlobal();
  
  setState(() => isRefreshing = false); 
  
  _showSnackBar("List refreshed!", isError: false); 
}

  

  void _showAddSenderDialog() {
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.add_circle, color: accentPurple),
            const SizedBox(width: 12),
            Text("Add New Sender",
                style: TextStyle(color: primaryWhite, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: primaryWhite),
              decoration: InputDecoration(
                labelText: "Phone Number",
                labelStyle: TextStyle(color: accentPurple),
                hintText: "62xxx",
                hintStyle: TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.phone, color: accentPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accentPurple),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCEL", style: TextStyle(color: Colors.white54)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primaryPurple, accentPurple]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final number = phoneController.text.trim();

                if (number.isEmpty) {
                  _showSnackBar("Please enter phone number", isError: true);
                  return;
                }

                Navigator.pop(context);
                await _addSender(number);
              },
              child: Text("ADD SENDER", style: TextStyle(color: primaryWhite)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addSender(String number) async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse("${baseUrl}/getPairing?key=${widget.sessionKey}&number=$number"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["valid"] == true) {
          _showPairingCodeDialog(number, data['pairingCode']);
          _showSnackBar("Pairing code generated successfully!", isError: false);
        } else {
          _showSnackBar(data['message'] ?? "Failed to generate pairing code", isError: true);
        }
      } else {
        _showSnackBar("Server error: ${response.statusCode}", isError: true);
      }
    } catch (e) {
      _showSnackBar("Connection failed: $e", isError: true);
    } finally {
      setState(() => isLoading = false);
      _fetchSenders();
    }
  }

  void _showPairingCodeDialog(String number, String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: bgDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryPurple.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.qr_code_2, color: accentPurple, size: 40),
            ),
            const SizedBox(height: 15),
            Text("Pairing Required",
                style: TextStyle(color: primaryWhite, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardGlass,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentPurple.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Number: $number", style: TextStyle(color: primaryWhite)),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentPurple, width: 2),
                  boxShadow: [
                    BoxShadow(color: accentPurple.withOpacity(0.4), blurRadius: 15, spreadRadius: 1)
                  ],
                ),
                child: Text(
                  code,
                  style: TextStyle(
                    color: accentPurple,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    fontFamily: 'Courier',
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryPurple),
                ),
                child: OutlinedButton.icon(
                  icon: Icon(Icons.copy, color: accentPurple),
                  label: Text(
                      "COPY CODE",
                      style: TextStyle(color: accentPurple, fontWeight: FontWeight.bold)
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Code copied to clipboard!", style: TextStyle(color: Colors.white)),
                        backgroundColor: accentPurple,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CLOSE", style: TextStyle(color: primaryWhite)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primaryPurple, accentPurple]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                _fetchSenders();
              },
              child: Text("REFRESH LIST", style: TextStyle(color: primaryWhite)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSender(String senderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
            const SizedBox(width: 12),
            Text("Confirm Delete", style: TextStyle(color: primaryWhite)),
          ],
        ),
        content: Text(
          "Are you sure you want to delete this sender? This action cannot be undone.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("CANCEL", style: TextStyle(color: primaryWhite)),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("DELETE", style: TextStyle(color: Colors.redAccent)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => isLoading = true);

      try {
        final response = await http.delete(
          Uri.parse("${baseUrl}/deleteSender?key=${widget.sessionKey}&id=$senderId"),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data["valid"] == true) {
            _showSnackBar("Sender deleted successfully!", isError: false);
            _fetchSenders();
          } else {
            _showSnackBar(data["message"] ?? "Failed to delete sender", isError: true);
          }
        } else {
          _showSnackBar("Server error: ${response.statusCode}", isError: true);
        }
      } catch (e) {
        _showSnackBar("Connection failed: $e", isError: true);
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: isError ? Colors.redAccent : primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSenderCard(Map<String, dynamic> sender, int index) {
    final name = sender['sessionName'] ?? 'WhatsApp Sender';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardGlass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGlass),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryPurple.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.phone_android, color: accentPurple),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: primaryWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // ID DIHAPUS DI SINI
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
                  ),
                  child: Text(
                    "CONNECTED",
                    style: TextStyle(
                      color: Colors.purpleAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.refresh, size: 16, color: primaryWhite),
                    label: Text("REFRESH"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryWhite,
                      backgroundColor: Colors.white.withOpacity(0.05),
                      side: BorderSide(color: borderGlass),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _refreshSenders(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                    label: Text("DELETE"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.1),
                      foregroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _deleteSender(sender['sessionName']),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: primaryPurple.withOpacity(0.3)),
              ),
              child: Icon(Icons.phone_iphone, color: accentPurple, size: 80),
            ),
            const SizedBox(height: 24),
            Text(
              "No Senders Found",
              style: TextStyle(color: primaryWhite, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Add your first WhatsApp sender to get started",
              style: TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primaryPurple, accentPurple]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: primaryPurple.withOpacity(0.4), blurRadius: 15)
                ],
              ),
              child: ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text("ADD FIRST SENDER"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _showAddSenderDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 80),
            const SizedBox(height: 24),
            Text(
              "Failed to Load",
              style: TextStyle(color: primaryWhite, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? "Unknown error occurred",
              style: TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primaryPurple, accentPurple]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton.icon(
                icon: Icon(Icons.refresh),
                label: Text("TRY AGAIN"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _fetchSenders,
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
      backgroundColor: bgDark,
      appBar: AppBar(
        title: Text(
          "Manage Bug Sender",
          style: TextStyle(
            color: primaryWhite,
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: primaryPurple.withOpacity(0.8), blurRadius: 10)
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: accentPurple),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: accentPurple),
            onPressed: isLoading ? null : _refreshSenders,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              bgDark,
              primaryPurple.withOpacity(0.1),
              bgDark,
            ],
          ),
        ),
        child: isLoading && senderList.isEmpty
            ? Center(child: CircularProgressIndicator(color: accentPurple))
            : errorMessage != null && senderList.isEmpty
            ? _buildErrorState()
            : senderList.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
          color: accentPurple,
          backgroundColor: cardGlass,
          onRefresh: _refreshSenders,
          child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: senderList.length,
            itemBuilder: (context, index) => _buildSenderCard(
              Map<String, dynamic>.from(senderList[index]),
              index,
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [primaryPurple, accentPurple]),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: primaryPurple.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAddSenderDialog,
          backgroundColor: Colors.transparent,
          child: Icon(Icons.add, color: primaryWhite),
        ),
      ),
    );
  }
}