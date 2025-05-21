import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> with TickerProviderStateMixin {
  List<dynamic> songs = [];
  int currentIndex = -1;
  bool isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Uint8List? currentAudio;
  Uint8List? currentImage;
  Duration totalDuration = Duration.zero;
  Duration currentPosition = Duration.zero;
  late AnimationController _bounceController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _colorController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    fetchSongs();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _colorController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: const Color(0xFFFF9E9E),
      end: const Color(0xFF9E9EFF),
    ).animate(_colorController);

    _audioPlayer.onDurationChanged.listen((d) {
      setState(() => totalDuration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      setState(() => currentPosition = p);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      _nextSong();
    });
  }

  Future<void> fetchSongs() async {
    final response = await http
        .get(Uri.parse('http://127.0.0.1:8000/animals/by-subject/7/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        songs = data;
      });
    }
  }

  Future<void> _loadSong(int index) async {
    if (songs.isEmpty || index < 0 || index >= songs.length) return;

    await _audioPlayer.stop();
    setState(() {
      currentIndex = index;
      isPlaying = false;
      currentAudio = null;
      currentImage = null;
    });

    final song = songs[index];

    // Decode audio
    final base64Audio = song['audio_base64'];
    if (base64Audio != null && base64Audio.isNotEmpty) {
      try {
        currentAudio = base64Decode(base64Audio);
        await _audioPlayer.play(BytesSource(currentAudio!));
        setState(() => isPlaying = true);
      } catch (e) {
        debugPrint('Audio decode error: $e');
      }
    }

    // Decode image
    final base64Image = song['image_base64'];
    if (base64Image != null && base64Image.isNotEmpty) {
      try {
        setState(() {
          currentImage = base64Decode(base64Image);
        });
      } catch (e) {
        debugPrint('Image decode error: $e');
      }
    }
  }

  void _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (currentAudio != null) {
        await _audioPlayer.resume();
      }
    }
    setState(() => isPlaying = !isPlaying);
  }

  void _nextSong() {
    if (currentIndex < songs.length - 1) {
      _loadSong(currentIndex + 1);
    }
  }

  void _prevSong() {
    if (currentIndex > 0) {
      _loadSong(currentIndex - 1);
    }
  }

  String formatDuration(Duration duration) {
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _bounceController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFD1DC).withOpacity(0.8),
                const Color(0xFFB5EAD7).withOpacity(0.9),
                const Color(0xFFC7CEEA).withOpacity(1.0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/music.json',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _bounceController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _bounceController.value * 5),
                      child: Text(
                        "Дуунууд ачаалж байна...",
                        style: const TextStyle(
                          fontSize: 24,
                          color: Color(0xFF9C27B0),
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFD1DC).withOpacity(0.8),
              const Color(0xFFB5EAD7).withOpacity(0.9),
              const Color(0xFFC7CEEA).withOpacity(1.0),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.7),
                      const Color(0xFFFFD1DC).withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.8),
                              const Color(0xFFFFD1DC).withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                    ),
                    const Spacer(),
                    AnimatedBuilder(
                      animation: _bounceController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _bounceController.value * 5),
                          child: const Text(
                            "🎵 Миний Хөгжим",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9C27B0),
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child:
                    currentIndex == -1 ? _buildSongList() : _buildSongDetail(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSongList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        Uint8List? thumbImage;
        if (song['image_base64'] != null && song['image_base64'].isNotEmpty) {
          try {
            thumbImage = base64Decode(song['image_base64']);
          } catch (_) {}
        }

        return GestureDetector(
          onTap: () => _loadSong(index),
          child: AnimatedBuilder(
            animation: _colorAnimation,
            builder: (context, child) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.9),
                        _colorAnimation.value!.withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: thumbImage != null
                        ? CircleAvatar(
                            backgroundImage: MemoryImage(thumbImage),
                            radius: 28,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          )
                        : CircleAvatar(
                            backgroundColor: const Color(0xFF9C27B0),
                            radius: 28,
                            child: const Icon(
                              Icons.music_note,
                              color: Colors.white,
                            ),
                          ),
                    title: Text(
                      song['animal_name'] ?? 'Дуу',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9C27B0),
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    subtitle: Text(
                      song['description'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.purple[800],
                      ),
                    ),
                    trailing: const Icon(
                      Icons.play_circle_outline,
                      color: Color(0xFF9C27B0),
                      size: 32,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSongDetail() {
    final song = songs[currentIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (currentImage != null)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.memory(
                  currentImage!,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.9),
                    const Color(0xFFB5EAD7).withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  "Зураг ачаалагдаагүй байна",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF9C27B0),
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _bounceController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _bounceController.value * 3),
                child: Text(
                  song['animal_name'] ?? '',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9C27B0),
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.9),
                  const Color(0xFFB5EAD7).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              song['description'] ?? 'Тайлбар байхгүй байна.',
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF9C27B0),
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF9C27B0),
              inactiveTrackColor: Colors.purple[100],
              thumbColor: const Color(0xFF9C27B0),
              overlayColor: const Color(0xFF9C27B0).withOpacity(0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: currentPosition.inSeconds
                  .toDouble()
                  .clamp(0, totalDuration.inSeconds.toDouble()),
              max: totalDuration.inSeconds.toDouble() > 0
                  ? totalDuration.inSeconds.toDouble()
                  : 1,
              onChanged: (value) {
                _audioPlayer.seek(Duration(seconds: value.toInt()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDuration(currentPosition),
                  style: const TextStyle(
                    color: Color(0xFF9C27B0),
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                Text(
                  formatDuration(totalDuration),
                  style: const TextStyle(
                    color: Color(0xFF9C27B0),
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTapDown: (_) => _scaleController.forward(),
                onTapUp: (_) {
                  _scaleController.reverse();
                  _prevSong();
                },
                onTapCancel: () => _scaleController.reverse(),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1, end: 0.9)
                      .animate(_scaleController),
                  child: IconButton(
                    icon: const Icon(Icons.skip_previous_rounded),
                    onPressed: _prevSong,
                    iconSize: 48,
                    color: const Color(0xFF9C27B0),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTapDown: (_) => _scaleController.forward(),
                onTapUp: (_) {
                  _scaleController.reverse();
                  _togglePlayPause();
                },
                onTapCancel: () => _scaleController.reverse(),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1, end: 0.9)
                      .animate(_scaleController),
                  child: AnimatedBuilder(
                    animation: _rotateController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: isPlaying
                            ? _rotateController.value * 2 * 3.14159
                            : 0,
                        child: IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause_circle : Icons.play_circle,
                            color: const Color(0xFF9C27B0),
                          ),
                          onPressed: _togglePlayPause,
                          iconSize: 72,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTapDown: (_) => _scaleController.forward(),
                onTapUp: (_) {
                  _scaleController.reverse();
                  _nextSong();
                },
                onTapCancel: () => _scaleController.reverse(),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1, end: 0.9)
                      .animate(_scaleController),
                  child: IconButton(
                    icon: const Icon(Icons.skip_next_rounded),
                    onPressed: _nextSong,
                    iconSize: 48,
                    color: const Color(0xFF9C27B0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
