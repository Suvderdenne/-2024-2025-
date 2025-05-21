//book_audio_player.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart' as ja;
import 'package:audioplayers/audioplayers.dart' as ap;

class BookAudioPlayer extends StatefulWidget {
  final String audioUrl;
  const BookAudioPlayer({required this.audioUrl, super.key});

  @override
  State<BookAudioPlayer> createState() => _BookAudioPlayerState();
}

class _BookAudioPlayerState extends State<BookAudioPlayer> {
  ja.AudioPlayer? justAudioPlayer;
  ap.AudioPlayer? audioPlayersWeb;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      audioPlayersWeb = ap.AudioPlayer();
      audioPlayersWeb!.setSourceUrl(widget.audioUrl);
    } else {
      justAudioPlayer = ja.AudioPlayer();
      justAudioPlayer!.setUrl(widget.audioUrl);
    }
  }

  @override
  void dispose() {
    justAudioPlayer?.dispose();
    audioPlayersWeb?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Text("Үлгэр сонсох", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow, size: 30),
              onPressed: () {
                if (kIsWeb) {
                  audioPlayersWeb?.resume();
                } else {
                  justAudioPlayer?.play();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.pause, size: 30),
              onPressed: () {
                if (kIsWeb) {
                  audioPlayersWeb?.pause();
                } else {
                  justAudioPlayer?.pause();
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
