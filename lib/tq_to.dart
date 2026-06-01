import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'btrapps/.dart';

final baseUrl = Api.api;

class TqPage extends StatefulWidget {
  const TqPage({super.key});

  @override
  State<TqPage> createState() => TqPageState();
}

class TqPageState extends State<TqPage> {
  final Color bgDark = const Color(0xFF121212);
  final Color primaryPink = const Color(0xFF2196F3);
  final Color accentPink = const Color(0xFF6EB1FF);
  final Color primaryWhite = Colors.white;
  final Color textGrey = Colors.grey.shade400;
  final Color cardGlass = Colors.white.withValues(alpha: 0.05);
  final Color borderGlass = Colors.white.withValues(alpha: 0.1);
  
  List<dynamic> _tqList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTqData();
  }

  Future<void> _fetchTqData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tq'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == true && data['result'] != null) {
          setState(() {
            _tqList = data['result'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Failed to load data';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error';
        _isLoading = false;
      });
    }
  }

  Future<void> _launchTelegram(String contact) async {
    String telegramUrl = contact;
    if (!contact.startsWith('http')) {
      telegramUrl = 'https://$contact';
    }
    final Uri url = Uri.parse(telegramUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch $contact'),
          backgroundColor: primaryPink,
        ),
      );
    }
  }

  Widget _buildGradientCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    BorderRadiusGeometry borderRadius = const BorderRadius.all(Radius.circular(16)),
    double borderWidth = 1,
    List<BoxShadow>? shadows,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cardGlass,
        borderRadius: borderRadius,
        border: Border.all(
          color: borderGlass,
          width: borderWidth,
        ),
        boxShadow: shadows ?? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: borderGlass,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cardGlass,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: primaryWhite,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SPECIAL THANKS TO',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: primaryWhite,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_tqList.length} contributors',
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _fetchTqData,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cardGlass,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: primaryWhite,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTqCard(Map<String, dynamic> item, int index) {
    return Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: index == _tqList.length - 1 ? 16 : 12,
      ),
      child: _buildGradientCard(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryPink,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryPink.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  item['ppUrl'] ?? '',
                  fit: BoxFit.cover,
                  width: 70,
                  height: 70,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: cardGlass,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: primaryPink,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: cardGlass,
                      child: Icon(
                        Icons.person,
                        color: textGrey,
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name']?.toString().replaceAll(RegExp(r'<[^>]*>'), '') ?? 'Unknown',
                    style: TextStyle(
                      color: primaryWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryPink.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: primaryPink.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      item['status'] ?? 'Member',
                      style: TextStyle(
                        color: accentPink,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _launchTelegram(item['contac'] ?? ''),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryPink,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryPink.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    FontAwesomeIcons.telegram,
                    color: primaryWhite,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: primaryPink,
              backgroundColor: cardGlass,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading contributors...',
            style: TextStyle(
              color: primaryWhite.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cardGlass,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: primaryPink,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Data',
            style: TextStyle(
              color: primaryWhite.withValues(alpha: 0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Something went wrong',
            style: TextStyle(
              color: textGrey,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _fetchTqData,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: primaryPink,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: primaryPink.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: primaryWhite,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Try Again',
                      style: TextStyle(
                        color: primaryWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cardGlass,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              color: primaryPink,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Contributors Found',
            style: TextStyle(
              color: primaryWhite.withValues(alpha: 0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The list is empty',
            style: TextStyle(
              color: textGrey,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _tqList.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.only(top: 16),
                              itemCount: _tqList.length,
                              itemBuilder: (context, index) {
                                return _buildTqCard(_tqList[index], index);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}