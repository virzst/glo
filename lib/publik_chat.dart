import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'btrapps/.dart';
final baseUrl = Api.api;

class ChatMessage {
  final String id;
  final String userId;
  final String username;
  final String role;
  final String? message;
  final String? imageUrl;
  final String? voiceUrl;
  final String? videoUrl;
  final String timestamp;
  final String avatarUrl;
  final bool isDeleted;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.username,
    required this.role,
    this.message,
    this.imageUrl,
    this.voiceUrl,
    this.videoUrl,
    required this.timestamp,
    required this.avatarUrl,
    required this.isDeleted,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? 'Member',
      message: json['message'],
      imageUrl: json['imageUrl'],
      voiceUrl: json['voiceUrl'],
      videoUrl: json['videoUrl'],
      timestamp: json['timestamp'] ?? '',
      avatarUrl: json['avatarUrl'] ?? 'assets/images/logoo.png',
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}

class CommunityPage extends StatefulWidget {
  final String username;
  final String role;

  const CommunityPage({super.key, required this.username, required this.role});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final FocusNode _focusNode = FocusNode();
  
  final Color bgDark = const Color(0xFF121212);
  final Color primaryPink = const Color(0xFF2196F3);
  final Color accentPink = const Color(0xFF6EB1FF);
  final Color primaryWhite = Colors.white;
  final Color textGrey = Colors.grey.shade400;
  final Color cardGlass = Colors.white.withOpacity(0.05);
  final Color borderGlass = Colors.white.withOpacity(0.1);
  
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  Timer? _refreshTimer;
  bool _showScrollButton = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _startAutoRefresh();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final isAtBottom = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100;
      setState(() {
        _showScrollButton = !isAtBottom;
      });
    }
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _loadMessages();
    });
  }

  Future<void> _loadMessages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/messages'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _messages = data.map((msg) => ChatMessage.fromJson(msg)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading messages: $e');
      if (_messages.isEmpty) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final messageData = {
        'userId': widget.username,
        'username': widget.username,
        'role': widget.role,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/chat/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(messageData),
      );

      if (response.statusCode == 200) {
        _messageController.clear();
        _loadMessages();
        _focusNode.unfocus();
      }
    } catch (e) {
      print('Error sending message: $e');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _sendImage() async {
    try {
      final XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
      if (imageFile == null) return;

      setState(() {
        _isSending = true;
      });

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/chat/upload-image'),
      );
      
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));
      request.fields['userId'] = widget.username;
      request.fields['username'] = widget.username;
      request.fields['role'] = widget.role;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        _loadMessages();
      }
    } catch (e) {
      print('Error sending image: $e');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _sendVideo() async {
    try {
      final XFile? videoFile = await _picker.pickVideo(source: ImageSource.gallery);
      if (videoFile == null) return;

      setState(() {
        _isSending = true;
      });

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/chat/upload-video'),
      );
      
      request.files.add(await http.MultipartFile.fromPath(
        'video',
        videoFile.path,
      ));
      request.fields['userId'] = widget.username;
      request.fields['username'] = widget.username;
      request.fields['role'] = widget.role;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        _loadMessages();
      }
    } catch (e) {
      print('Error sending video: $e');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _saveToGallery(String url, bool isVideo) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.${isVideo ? 'mp4' : 'jpg'}');
        await file.writeAsBytes(response.bodyBytes);
        
        if (isVideo) {
          await GallerySaver.saveVideo(file.path);
        } else {
          await GallerySaver.saveImage(file.path);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${isVideo ? 'Video' : 'Foto'} berhasil disimpan'),
              backgroundColor: primaryPink,
            ),
          );
        }
      }
    } catch (e) {
      print('Error saving file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan file'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToBottom({bool smooth = true}) {
    if (_scrollController.hasClients) {
      if (smooth) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }
  }

  String _formatTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      return timestamp;
    }
  }

  Widget _buildRoleBadge(String role) {
    Color color;
    switch (role.toLowerCase()) {
      case 'owner':
        color = const Color(0xFFFFD700);
      case 'admin':
        color = primaryPink;
      case 'reseller':
        color = const Color(0xFF25D366);
      default:
        color = textGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildGradientCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    BorderRadiusGeometry borderRadius = const BorderRadius.all(Radius.circular(16)),
    double borderWidth = 1,
    List<BoxShadow>? shadows,
    Color borderColor = const Color(0xFF2D2D2D),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cardGlass,
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: shadows ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.userId == widget.username;
    final isDeleted = message.isDeleted;

    if (isDeleted) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: _buildGradientCard(
          padding: const EdgeInsets.all(12),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderColor: borderGlass,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: borderGlass,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline, color: Colors.grey, size: 14),
              ),
              const SizedBox(width: 10),
              Text(
                'This message was deleted',
                style: TextStyle(
                  color: textGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isSameSender = _messages.indexOf(message) > 0 && 
                         _messages[_messages.indexOf(message) - 1].userId == message.userId;

    return Container(
      margin: EdgeInsets.only(
        top: isSameSender ? 2 : 8,
        bottom: 4,
        left: isMe ? 60 : 12,
        right: isMe ? 12 : 60,
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe && !isSameSender)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryWhite,
                      border: Border.all(color: borderGlass, width: 1.5),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        message.avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: borderGlass,
                            ),
                            child: const Icon(Icons.person, color: Colors.white, size: 14),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            message.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildRoleBadge(message.role),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color: textGrey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          MouseRegion(
            cursor: SystemMouseCursors.basic,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                ),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (message.imageUrl != null)
                      Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: Stack(
                                        children: [
                                          InteractiveViewer(
                                            child: Image.network(
                                              message.imageUrl!,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: IconButton(
                                              icon: Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.black54,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.download, color: Colors.white, size: 20),
                                              ),
                                              onPressed: () => _saveToGallery(message.imageUrl!, false),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Image.network(
                                      message.imageUrl!,
                                      width: 240,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          width: 240,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            color: cardGlass,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: primaryPink,
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                      loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 240,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            color: cardGlass,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: Icon(Icons.broken_image_rounded, color: primaryPink, size: 32),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.download, color: Colors.white, size: 16),
                              ),
                              onPressed: () => _saveToGallery(message.imageUrl!, false),
                            ),
                          ),
                        ],
                      ),
                    if (message.videoUrl != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    height: MediaQuery.of(context).size.height * 0.7,
                                    child: VideoPlayerWidget(
                                      videoUrl: message.videoUrl!,
                                      onSave: () => _saveToGallery(message.videoUrl!, true),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 240,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: cardGlass,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.play_circle_filled,
                                      color: primaryPink,
                                      size: 48,
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'VIDEO',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: IconButton(
                                        icon: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.download, color: Colors.white, size: 16),
                                        ),
                                        onPressed: () => _saveToGallery(message.videoUrl!, true),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? primaryPink.withOpacity(0.9) : cardGlass,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (message.message != null && message.message!.isNotEmpty)
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.5,
                              ),
                              child: SelectableText(
                                message.message!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTime(message.timestamp),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white.withOpacity(0.6),
                                  size: 12,
                                ),
                              ],
                            ],
                          ),
                        ],
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: borderGlass,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: primaryPink, width: 1.5),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logoo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryPink,
                      ),
                      child: const Icon(Icons.group_rounded, color: Colors.white, size: 18),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GLOBAL CHAT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_messages.map((m) => m.userId).toSet().length} online',
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _loadMessages,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cardGlass,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      margin: const EdgeInsets.all(12),
      child: _buildGradientCard(
        padding: const EdgeInsets.all(12),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _isSending ? null : _sendImage,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cardGlass,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.image_rounded,
                    color: _isSending ? textGrey : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _isSending ? null : _sendVideo,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cardGlass,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.video_library_rounded,
                    color: _isSending ? textGrey : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: cardGlass,
                  border: Border.all(color: borderGlass, width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(color: textGrey, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        maxLines: 2,
                        minLines: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _isSending
                          ? Container(
                              padding: const EdgeInsets.all(6),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: primaryPink,
                                ),
                              ),
                            )
                          : MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: _sendMessage,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: primaryPink,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
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
              Icons.chat_bubble_outline_rounded,
              color: primaryPink,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation!',
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
            'Loading messages...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: accentPink),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Publik Chat",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Stack(
                children: [
                  _isLoading
                      ? _buildLoadingState()
                      : _messages.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(top: 12, bottom: 80),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                return _buildMessageBubble(_messages[index]);
                              },
                            ),
                  if (_showScrollButton)
                    Positioned(
                      right: 16,
                      bottom: 80,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => _scrollToBottom(),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryPink,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_downward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final VoidCallback? onSave;

  const VideoPlayerWidget({super.key, required this.videoUrl, this.onSave});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
      await _videoPlayerController.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF2196F3),
          handleColor: const Color(0xFF6EB1FF),
          backgroundColor: Colors.grey.shade300,
          bufferedColor: Colors.grey.shade500,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF2196F3)),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Error: $errorMessage',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load video: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF2196F3)),
        ),
      );
    }

    if (_error != null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _initializePlayer();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        if (_chewieController != null)
          Chewie(controller: _chewieController!),
        if (widget.onSave != null)
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.download, color: Colors.white, size: 24),
              ),
              onPressed: widget.onSave,
            ),
          ),
      ],
    );
  }
}