import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ebook_app/constants/colors.dart';
import 'package:ebook_app/models/book.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ebook_app/pages/favorite/history_service.dart';

import 'package:just_audio/just_audio.dart' as ja;
import 'package:audioplayers/audioplayers.dart' as ap;

class BookCover extends StatefulWidget {
  final Book book;
  const BookCover(this.book, {Key? key}) : super(key: key);

  @override
  State<BookCover> createState() => _BookCoverState();
}

class _BookCoverState extends State<BookCover> {
  ja.AudioPlayer? justAudioPlayer;
  ap.AudioPlayer? audioPlayersWeb;

  bool isPlaying = false;
  int currentIndex = 0;
  late List<String> altImageUrls;
  Timer? _timer;
  bool isAudioPlaying = false;
  int imageChangeInterval = 25;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();

    altImageUrls =
        widget.book.altImgUrls.isNotEmpty ? widget.book.altImgUrls : [];

    if (altImageUrls.isNotEmpty) {
      _timer = Timer.periodic(Duration(seconds: imageChangeInterval), (timer) {
        if (mounted && isAudioPlaying) {
          setState(() {
            currentIndex = (currentIndex + 1) % altImageUrls.length;
          });
        }
      });
    }

    if (kIsWeb) {
      audioPlayersWeb = ap.AudioPlayer();
      audioPlayersWeb!.setSourceUrl(widget.book.audioUrl);

      audioPlayersWeb!.onDurationChanged.listen((duration) {
        setState(() => _totalDuration = duration);
      });

      audioPlayersWeb!.onPositionChanged.listen((position) {
        setState(() => _currentPosition = position);
      });

      audioPlayersWeb!.onPlayerComplete.listen((event) async {
        setState(() {
          isPlaying = false;
          isAudioPlaying = false;
        });

        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getInt('userid');
        final bookId = int.tryParse(widget.book.id);
        if (userId != null && bookId != null) {
          await HistoryService.saveReadingHistory(userId, bookId);
          print("Web дээр түүх хадгаллаа");
        }
      });
    } else {
      justAudioPlayer = ja.AudioPlayer();
      _initJustAudio();

      justAudioPlayer!.positionStream.listen((position) {
        setState(() => _currentPosition = position);
      });

      justAudioPlayer!.durationStream.listen((duration) {
        if (duration != null) {
          setState(() => _totalDuration = duration);
        }
      });

      justAudioPlayer!.playerStateStream.listen((playerState) async {
        if (playerState.processingState == ja.ProcessingState.completed) {
          setState(() {
            isPlaying = false;
            isAudioPlaying = false;
          });

          final prefs = await SharedPreferences.getInstance();
          final userId = prefs.getInt('userid');
          final bookId = int.tryParse(widget.book.id);
          if (userId != null && bookId != null) {
            await HistoryService.saveReadingHistory(userId, bookId);
            print("Mobile/Desktop түүх хадгаллаа");
          }
        }
      });
    }
  }

  Future<void> _initJustAudio() async {
    try {
      await justAudioPlayer!.setUrl(widget.book.audioUrl);
    } catch (e) {
      print("Аудио ачааллахад алдаа: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    justAudioPlayer?.dispose();
    audioPlayersWeb?.dispose();
    super.dispose();
  }

  void _toggleAudio() async {
    if (isPlaying) {
      if (kIsWeb) {
        await audioPlayersWeb?.pause();
      } else {
        await justAudioPlayer?.pause();
      }
      setState(() => isAudioPlaying = false);
    } else {
      if (kIsWeb) {
        await audioPlayersWeb?.resume();
      } else {
        await justAudioPlayer?.play();
      }
      setState(() => isAudioPlaying = true);
    }
    setState(() => isPlaying = !isPlaying);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 20,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
              child:
                  altImageUrls.isNotEmpty
                      ? Image.network(
                        altImageUrls[currentIndex],
                        fit: BoxFit.cover,
                      )
                      : const Center(child: Text("Зураг байхгүй")),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: _toggleAudio,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: kFont,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isPlaying ? 'Зогсоох' : 'Сонсох',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _formatDuration(_currentPosition),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Slider(
                        min: 0,
                        max:
                            _totalDuration.inSeconds.toDouble() > 0
                                ? _totalDuration.inSeconds.toDouble()
                                : 1,
                        value:
                            _currentPosition.inSeconds
                                .clamp(
                                  0,
                                  _totalDuration.inSeconds > 0
                                      ? _totalDuration.inSeconds
                                      : 1,
                                )
                                .toDouble(),
                        onChanged: (value) async {
                          final seekPos = Duration(seconds: value.toInt());
                          if (kIsWeb) {
                            await audioPlayersWeb?.seek(seekPos);
                          } else {
                            await justAudioPlayer?.seek(seekPos);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDuration(_totalDuration),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
