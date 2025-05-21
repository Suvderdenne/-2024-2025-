import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class MathAnimalPage extends StatefulWidget {
  final int subjectId;
  const MathAnimalPage({super.key, required this.subjectId});

  @override
  State<MathAnimalPage> createState() => _MathAnimalPageState();
}

class _MathAnimalPageState extends State<MathAnimalPage>
    with TickerProviderStateMixin {
  List animals = [];
  bool isLoading = true;
  late AnimationController _bounceController;
  late AnimationController _scaleController;
  late AnimationController _colorController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    fetchAnimals();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _colorController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    _colorAnimation = ColorTween(
      begin: const Color(0xFFFF9E9E),
      end: const Color(0xFF9E9EFF),
    ).animate(_colorController);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _scaleController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> fetchAnimals() async {
    final url = Uri.parse(
        'http://127.0.0.1:8000/animals/by-subject/${widget.subjectId}/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        animals = jsonDecode(utf8.decode(response.bodyBytes));
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Амьтад ачааллахад алдаа гарлаа',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            backgroundColor: Colors.red[400],
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    AnimatedBuilder(
                      animation: _bounceController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _bounceController.value * 4),
                          child: const Icon(
                            Icons.calculate,
                            size: 32,
                            color: Color(0xFF9C27B0),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '🔢 Тоо',
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
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _bounceController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset:
                                      Offset(0, _bounceController.value * 10),
                                  child: const Icon(
                                    Icons.calculate,
                                    size: 64,
                                    color: Color(0xFF9C27B0),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Амьтдыг ачааллаж байна...',
                              style: const TextStyle(
                                fontSize: 20,
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
                      )
                    : animals.isEmpty
                        ? Center(
                            child: Text(
                              "Амьтад олдсонгүй",
                              style: const TextStyle(
                                fontSize: 20,
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
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: animals.length,
                            itemBuilder: (context, index) {
                              final animal = animals[index];
                              final Uint8List? imageBytes =
                                  animal['image_base64'] != null
                                      ? base64Decode(animal['image_base64'])
                                      : null;
                              final Uint8List? audioBytes =
                                  animal['audio_base64'] != null
                                      ? base64Decode(animal['audio_base64'])
                                      : null;
                              final Uint8List? videoBytes =
                                  animal['video_base64'] != null
                                      ? base64Decode(animal['video_base64'])
                                      : null;

                              return TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0.95, end: 1.0),
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutBack,
                                builder: (context, scale, child) {
                                  return Transform.scale(
                                      scale: scale, child: child);
                                },
                                child: AnimatedBuilder(
                                  animation: _colorAnimation,
                                  builder: (context, child) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.9),
                                            _colorAnimation.value!
                                                .withOpacity(0.2),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.purple.withOpacity(0.2),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // Animal Name with Animation
                                              GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => AlertDialog(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      elevation: 0,
                                                      content:
                                                          TweenAnimationBuilder(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    300),
                                                        tween: Tween<double>(
                                                            begin: 0.5,
                                                            end: 1.0),
                                                        builder: (context,
                                                            scale, child) {
                                                          return Transform
                                                              .scale(
                                                                  scale: scale,
                                                                  child: child);
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(24),
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                Colors.white
                                                                    .withOpacity(
                                                                        0.9),
                                                                const Color(
                                                                        0xFFB5EAD7)
                                                                    .withOpacity(
                                                                        0.9),
                                                              ],
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        24),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .purple
                                                                    .withOpacity(
                                                                        0.2),
                                                                blurRadius: 10,
                                                                offset:
                                                                    const Offset(
                                                                        0, 4),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Text(
                                                            animal[
                                                                'animal_name'],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 32,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Color(
                                                                  0xFF9C27B0),
                                                              shadows: [
                                                                Shadow(
                                                                  color: Colors
                                                                      .black26,
                                                                  offset:
                                                                      Offset(
                                                                          0, 2),
                                                                  blurRadius: 4,
                                                                ),
                                                              ],
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  animal['animal_name'],
                                                  style: const TextStyle(
                                                    fontSize: 24,
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
                                              ),
                                              const SizedBox(height: 16),

                                              // Image with Animation
                                              if (imageBytes != null)
                                                GestureDetector(
                                                  onTap: () {
                                                    if (audioBytes != null) {
                                                      final player =
                                                          AudioPlayer();
                                                      player.play(BytesSource(
                                                          audioBytes));
                                                    }
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) => Dialog(
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        child:
                                                            TweenAnimationBuilder(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      300),
                                                          tween: Tween<double>(
                                                              begin: 0.5,
                                                              end: 1.0),
                                                          builder: (context,
                                                              scale, child) {
                                                            return Transform
                                                                .scale(
                                                                    scale:
                                                                        scale,
                                                                    child:
                                                                        child);
                                                          },
                                                          child: Hero(
                                                            tag:
                                                                'animalImage$index',
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          24),
                                                              child: Image.memory(
                                                                  imageBytes),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Hero(
                                                    tag: 'animalImage$index',
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.1),
                                                            blurRadius: 8,
                                                            spreadRadius: 2,
                                                            offset:
                                                                const Offset(
                                                                    0, 4),
                                                          ),
                                                        ],
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        child: LayoutBuilder(
                                                          builder: (context,
                                                              constraints) {
                                                            return Image.memory(
                                                              imageBytes,
                                                              fit: BoxFit
                                                                  .contain,
                                                              width: constraints
                                                                  .maxWidth,
                                                              height: constraints
                                                                      .maxWidth *
                                                                  0.75,
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(height: 16),

                                              // Audio Button with Animation
                                              if (audioBytes != null)
                                                GestureDetector(
                                                  onTapDown: (_) =>
                                                      _scaleController
                                                          .forward(),
                                                  onTapUp: (_) {
                                                    _scaleController.reverse();
                                                    final player =
                                                        AudioPlayer();
                                                    player.play(BytesSource(
                                                        audioBytes));
                                                  },
                                                  onTapCancel: () =>
                                                      _scaleController
                                                          .reverse(),
                                                  child: ScaleTransition(
                                                    scale: Tween<double>(
                                                            begin: 1, end: 0.95)
                                                        .animate(
                                                            _scaleController),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 24,
                                                        vertical: 12,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            const Color(
                                                                0xFF9C27B0),
                                                            const Color(
                                                                    0xFF9C27B0)
                                                                .withOpacity(
                                                                    0.8),
                                                          ],
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.purple
                                                                .withOpacity(
                                                                    0.3),
                                                            blurRadius: 8,
                                                            spreadRadius: 2,
                                                            offset:
                                                                const Offset(
                                                                    0, 4),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          AnimatedBuilder(
                                                            animation:
                                                                _bounceController,
                                                            builder: (context,
                                                                child) {
                                                              return Transform
                                                                  .translate(
                                                                offset: Offset(
                                                                    0,
                                                                    _bounceController
                                                                            .value *
                                                                        4),
                                                                child:
                                                                    const Icon(
                                                                  Icons
                                                                      .music_note,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 28,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          const Text(
                                                            "Сонсох",
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              shadows: [
                                                                Shadow(
                                                                  color: Colors
                                                                      .black26,
                                                                  offset:
                                                                      Offset(
                                                                          0, 1),
                                                                  blurRadius: 2,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(height: 16),

                                              // Video with Animation
                                              if (videoBytes != null)
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        blurRadius: 8,
                                                        spreadRadius: 2,
                                                        offset:
                                                            const Offset(0, 4),
                                                      ),
                                                    ],
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: SizedBox(
                                                      height: 200,
                                                      child: VideoWidget(
                                                          videoBytes:
                                                              videoBytes),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoWidget extends StatefulWidget {
  final Uint8List videoBytes;
  const VideoWidget({super.key, required this.videoBytes});

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    final tempDir = await getTemporaryDirectory();
    final file = File(
        '${tempDir.path}/temp_video_${DateTime.now().millisecondsSinceEpoch}.mp4');
    await file.writeAsBytes(widget.videoBytes);

    _controller = VideoPlayerController.file(file)
      ..initialize().then((_) {
        setState(() {
          isInitialized = true;
        });
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isInitialized
        ? Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF9C27B0).withOpacity(0.8),
                        const Color(0xFF9C27B0).withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          )
        : Center(
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(const Color(0xFF9C27B0)),
            ),
          );
  }
}
