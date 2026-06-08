import 'dart:convert';
import 'music_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class SpotifyPlayerPage extends StatefulWidget {
  const SpotifyPlayerPage({super.key});

  @override
  State<SpotifyPlayerPage> createState() =>
      _SpotifyPlayerPageState();
}

class _SpotifyPlayerPageState
    extends State<SpotifyPlayerPage> {

  final player = MusicService.player;
  final TextEditingController controller =
      TextEditingController();

  bool loading = false;

  String title = "";
  String artist = "";
  String duration = "";
  String thumbnail = "";

  Future<void> searchSong() async {
    if (controller.text.isEmpty) return;

    setState(() => loading = true);

    try {
      final search = await http.get(
        Uri.parse(
          "https://api.ikyyxd.my.id/search/spotifyplay?query=${Uri.encodeComponent(controller.text)}",
        ),
      );

      final searchData =
          jsonDecode(search.body);

      final spotifyUrl =
          searchData["result"]["url"];

      final download = await http.get(
        Uri.parse(
          "https://api.ikyyxd.my.id/download/spotifydl?url=${Uri.encodeComponent(spotifyUrl)}",
        ),
      );

      final data =
          jsonDecode(download.body);

      final song = data["result"];

      setState(() {
        title = song["title"] ?? "";
        artist = song["artist"] ?? "";
        duration = song["duration"] ?? "";
        thumbnail =
            song["thumbnail"] ?? "";
      });

      await player.stop();

      await player.setUrl(
        song["download"],
      );

      await player.play();

    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }

    setState(() => loading = false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    const bg = Color(0xFF0D0000);
    const card = Color(0xFF180000);

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        centerTitle: true,

        title: const Text(
          "SPOTIFY PLAYER",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.all(20),

          child: Column(
            children: [

              Container(
                padding:
                    const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: card,
                  borderRadius:
                      BorderRadius.circular(
                          20),
                  border: Border.all(
                    color: Colors.red,
                  ),
                ),

                child: Column(
                  children: [

                    TextField(
                      controller:
                          controller,
                      style:
                          const TextStyle(
                        color:
                            Colors.amber,
                      ),
                      decoration:
                          InputDecoration(
                        prefixIcon:
                            const Icon(
                          Icons.music_note,
                          color:
                              Colors.amber,
                        ),
                        hintText:
                            "Masukkan Judul Lagu",
                        hintStyle:
                            const TextStyle(
                          color:
                              Colors.amber,
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 20),

                    SizedBox(
                      width:
                          double.infinity,
                      height: 55,
                      child:
                          ElevatedButton(
                        onPressed:
                            searchSong,
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              Colors.red,
                        ),
                        child:
                            const Text(
                          "PLAY MUSIC",
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                  height: 40),

              if (loading)
                const CircularProgressIndicator(),

              if (thumbnail.isEmpty &&
                  !loading)
                Column(
                  children: const [

                    Icon(
                      Icons.music_note,
                      color:
                          Colors.red,
                      size: 90,
                    ),

                    SizedBox(
                        height: 15),

                    Text(
                      "Spotify Player",
                      style:
                          TextStyle(
                        color:
                            Colors.white,
                        fontSize: 24,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    SizedBox(
                        height: 8),

                    Text(
                      "Masukkan judul lagu untuk memutar musik",
                      textAlign:
                          TextAlign
                              .center,
                      style:
                          TextStyle(
                        color:
                            Colors.white70,
                      ),
                    ),
                  ],
                ),

              if (thumbnail.isNotEmpty)
                Column(
                  children: [

                    ClipRRect(
                      borderRadius:
                          BorderRadius
                              .circular(
                                  20),
                      child:
                          Image.network(
                        thumbnail,
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(
                        height: 20),

                    Text(
                      title,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 22,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    const SizedBox(
                        height: 5),

                    Text(
                      artist,
                      style:
                          const TextStyle(
                        color:
                            Colors.white70,
                      ),
                    ),

                    const SizedBox(
                        height: 5),

                    Text(
                      duration,
                      style:
                          const TextStyle(
                        color:
                            Colors.white54,
                      ),
                    ),

                    const SizedBox(
                        height: 20),

                    StreamBuilder<
                        PlayerState>(
                      stream: player
                          .playerStateStream,
                      builder:
                          (_, snap) {

                        final playing =
                            snap.data
                                    ?.playing ??
                                false;

                        return IconButton(
                          iconSize: 70,
                          color:
                              Colors.white,
                          icon: Icon(
                            playing
                                ? Icons
                                    .pause_circle
                                : Icons
                                    .play_circle,
                          ),
                          onPressed:
                              () async {
                            if (playing) {
                              await player
                                  .pause();
                            } else {
                              await player
                                  .play();
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}