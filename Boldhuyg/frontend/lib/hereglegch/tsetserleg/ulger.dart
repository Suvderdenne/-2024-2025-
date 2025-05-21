import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

class FairyTalePage extends StatefulWidget {
  final int subjectId; // Үлгэр хичээлийн ID
  const FairyTalePage({super.key, required this.subjectId});

  @override
  State<FairyTalePage> createState() => _FairyTalePageState();
}

class _FairyTalePageState extends State<FairyTalePage>
    with TickerProviderStateMixin {
  List<dynamic> tales = [];
  bool isLoading = true;
  VideoPlayerController? videoController;
  late AnimationController _bounceController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    fetchTales();
    _bounceController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _scaleController.dispose();
    videoController?.dispose();
    super.dispose();
  }

  Future<void> fetchTales() async {
    final url = Uri.parse('http://127.0.0.1:8000/animals/by-subject/8/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
      print('API Response: $decodedResponse');

      // Log image data for debugging
      for (var tale in decodedResponse) {
        print('Tale ${tale['animal_name']}:');
        print('Image base64 length: ${tale['image_base64']?.length ?? 0}');
        print(
            'Image base64 preview: ${tale['image_base64']?.substring(0, 50) ?? 'null'}...');
      }

      setState(() {
        tales = decodedResponse;
        isLoading = false;
      });
    } else {
      print('Error fetching tales: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> saveBase64VideoToFile(String base64String) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/video.mp4';
    final videoBytes = base64Decode(base64String);
    final file = File(filePath);
    await file.writeAsBytes(videoBytes);
    return filePath;
  }

  Future<void> playBase64Video(String base64String) async {
    final videoPath = await saveBase64VideoToFile(base64String);
    videoController = VideoPlayerController.file(File(videoPath))
      ..initialize().then((_) {
        setState(() {});
        videoController!.play();
      });
  }

  Widget buildTaleCard(dynamic tale) {
    Uint8List imageBytes;
    try {
      final imageBase64 = tale['image_base64'] ?? '';
      if (imageBase64.isEmpty) {
        throw Exception('Empty image data');
      }
      imageBytes = base64Decode(imageBase64);
      if (imageBytes.isEmpty) {
        throw Exception('Decoded image data is empty');
      }
    } catch (e) {
      print('Error loading image: $e');
      // Use a placeholder image when the image data is invalid
      imageBytes = Uint8List(0);
    }

    final audioBytes = tale['audio_base64'] != null
        ? base64Decode(tale['audio_base64'])
        : Uint8List(0);
    final videoBytes = tale['video_base64'] != null
        ? base64Decode(tale['video_base64'])
        : Uint8List(0);
    final audioPlayer = AudioPlayer();

    if (videoBytes.isNotEmpty) {
      playBase64Video(tale['video_base64']!);
    }

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0.8, end: 1.0),
      builder: (context, double scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade100,
              Colors.blue.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (imageBytes.isNotEmpty)
                    Image.memory(
                      imageBytes,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey.shade300,
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey.shade600,
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0),
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    child: Text(
                      tale['animal_name'] ?? 'Үлгэр',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'ComicSans',
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tale['description'] ?? 'Тайлбар байхгүй',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.purple.shade900,
                        height: 1.5,
                        fontFamily: 'ComicSans',
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (audioBytes.isNotEmpty)
                    GestureDetector(
                      onTapDown: (_) => _scaleController.forward(),
                      onTapUp: (_) {
                        _scaleController.reverse();
                        audioPlayer.play(BytesSource(audioBytes));
                      },
                      onTapCancel: () => _scaleController.reverse(),
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 1, end: 0.95)
                            .animate(_scaleController),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade300,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedBuilder(
                                animation: _bounceController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset:
                                        Offset(0, _bounceController.value * 4),
                                    child: Icon(
                                      Icons.music_note,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  );
                                },
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Үлгэр сонсох',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'ComicSans',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 16),
                  if (videoController != null &&
                      videoController!.value.isInitialized)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: videoController!.value.aspectRatio,
                              child: VideoPlayer(videoController!),
                            ),
                            Container(
                              color: Colors.purple.shade100,
                              child: IconButton(
                                icon: Icon(
                                  videoController!.value.isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                  size: 40,
                                  color: Colors.purple.shade900,
                                ),
                                onPressed: () {
                                  setState(() {
                                    videoController!.value.isPlaying
                                        ? videoController!.pause()
                                        : videoController!.play();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
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
      appBar: AppBar(
        title: Row(
          children: [
            AnimatedBuilder(
              animation: _bounceController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bounceController.value * 4),
                  child: Icon(Icons.auto_stories, size: 32),
                );
              },
            ),
            SizedBox(width: 8),
            Text(
              'Үлгэрүүд',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'ComicSans',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.purple.shade400,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade100,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _bounceController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _bounceController.value * 10),
                          child: Icon(
                            Icons.auto_stories,
                            size: 64,
                            color: Colors.purple.shade400,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Үлгэрүүдийг ачааллаж байна...',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.purple.shade700,
                        fontFamily: 'ComicSans',
                      ),
                    ),
                  ],
                ),
              )
            : tales.isEmpty
                ? Center(
                    child: Text(
                      'Үлгэр олдсонгүй',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.purple.shade700,
                        fontFamily: 'ComicSans',
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    itemCount: tales.length,
                    itemBuilder: (context, index) =>
                        buildTaleCard(tales[index]),
                  ),
      ),
    );
  }
}
