import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePage extends StatefulWidget {
  const YoutubePage({super.key});

  @override
  State<YoutubePage> createState() => _YoutubePageState();
}

class _YoutubePageState extends State<YoutubePage> {
  final TextEditingController _searchController =
      TextEditingController();

  bool _loading = false;
  List<dynamic> _videos = [];

  Future<void> searchYoutube() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _loading = true;
      _videos.clear();
    });

    try {
      final response = await http.get(
        Uri.parse(
          "http://api.ikyyxd.my.id/search/youtube?apikey=kyzz&query=${Uri.encodeComponent(_searchController.text)}",
        ),
      );

      final data = jsonDecode(response.body);

      if (data["status"] == true) {
        setState(() {
          _videos = data["result"].take(2).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    setState(() {
      _loading = false;
    });
  }

  void openVideo(Map video) {
    final id =
        YoutubePlayer.convertUrlToId(video["link"]) ?? "";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => YoutubePlayerScreen(
          title: video["title"] ?? "",
          channel: video["channel"] ?? "",
          videoId: id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0b0b0b),

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "YOUTUBE PLAYER",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(15),

        child: Column(
          children: [
            TextField(
              controller: _searchController,
              style: const TextStyle(
                color: Colors.white,
              ),

              onSubmitted: (_) {
                searchYoutube();
              },

              decoration: InputDecoration(
                hintText: "Cari Video...",
                hintStyle: const TextStyle(
                  color: Colors.white54,
                ),

                filled: true,
                fillColor: Colors.grey.shade900,

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),

                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: searchYoutube,
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_loading)
              const CircularProgressIndicator(),

            Expanded(
              child: ListView.builder(
                itemCount: _videos.length,
                itemBuilder: (context, index) {
                  final item = _videos[index];

                  return Card(
                    color: Colors.grey.shade900,
                    margin: const EdgeInsets.only(
                      bottom: 15,
                    ),

                    child: InkWell(
                      onTap: () => openVideo(item),

                      child: Padding(
                        padding:
                            const EdgeInsets.all(10),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius
                                      .circular(12),

                              child: Image.network(
                                item["imageUrl"],
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            Text(
                              item["title"],
                              maxLines: 2,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight
                                        .bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              item["channel"],
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white70,
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              item["duration"],
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class YoutubePlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;
  final String channel;

  const YoutubePlayerScreen({
    super.key,
    required this.videoId,
    required this.title,
    required this.channel,
  });

  @override
  State<YoutubePlayerScreen> createState() =>
      _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState
    extends State<YoutubePlayerScreen> {
  late YoutubePlayerController controller;

  @override
  void initState() {
    super.initState();

    controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        forceHD: true,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
      ),

      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,

          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text("WATCH"),
          ),

          body: ListView(
            children: [
              player,

              Padding(
                padding:
                    const EdgeInsets.all(15),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Text(
                      widget.title,
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 18,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      widget.channel,
                      style:
                          const TextStyle(
                        color:
                            Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}