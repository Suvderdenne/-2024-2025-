import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

// ------------------ Model ------------------
class ColorItem {
  final String name;
  final String description;
  final Uint8List imageBytes;
  final Uint8List? audioBytes;

  ColorItem({
    required this.name,
    required this.description,
    required this.imageBytes,
    this.audioBytes,
  });

  factory ColorItem.fromJson(Map<String, dynamic> json) {
    return ColorItem(
      name: json['animal_name'] ?? '',
      description: json['description'] ?? '',
      imageBytes: base64Decode(json['image_base64'] ?? ''),
      audioBytes: json['audio_base64'] != null
          ? base64Decode(json['audio_base64'])
          : null,
    );
  }
}

// ------------------ Main Page ------------------
class ColorsPage extends StatefulWidget {
  final int subjectId;
  const ColorsPage({super.key, required this.subjectId});

  @override
  State<ColorsPage> createState() => _ColorsPageState();
}

class _ColorsPageState extends State<ColorsPage> with TickerProviderStateMixin {
  late Future<List<ColorItem>> _colorsFuture;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPracticeMode = false;
  late AnimationController _bounceController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _colorController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _colorsFuture = fetchColors();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 500),
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
    _audioPlayer.dispose();
    _bounceController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<List<ColorItem>> fetchColors() async {
    final url = Uri.parse(
        'http://127.0.0.1:8000/animals/by-subject/${widget.subjectId}/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((item) => ColorItem.fromJson(item)).toList();
    } else {
      throw Exception('Өнгөний өгөгдөл авч чадсангүй');
    }
  }

  void playAudio(Uint8List audioBytes) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(BytesSource(audioBytes));
  }

  void _toggleMode() {
    setState(() {
      _isPracticeMode = !_isPracticeMode;
    });
    _rotateController.forward(from: 0.0);
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
                    const SizedBox(width: 12),
                    AnimatedBuilder(
                      animation: _bounceController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _bounceController.value * 4),
                          child: const Icon(
                            Icons.palette,
                            size: 32,
                            color: Color(0xFF9C27B0),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '🎨 Өнгө сурах',
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
                    const Spacer(),
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0)
                          .animate(_rotateController),
                      child: IconButton(
                        icon: Icon(
                          _isPracticeMode
                              ? Icons.school
                              : Icons.question_answer,
                          color: const Color(0xFF9C27B0),
                          size: 28,
                        ),
                        tooltip:
                            _isPracticeMode ? 'Сурах горим' : 'Бататгах горим',
                        onPressed: _toggleMode,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<ColorItem>>(
                  future: _colorsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
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
                                    Icons.palette,
                                    size: 64,
                                    color: Color(0xFF9C27B0),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Өнгөнүүдийг ачааллаж байна...',
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
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Алдаа гарлаа: ${snapshot.error}',
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
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'Өнгө олдсонгүй.',
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
                      );
                    }

                    final colors = snapshot.data!;
                    return PageView.builder(
                      itemCount: colors.length,
                      itemBuilder: (context, index) {
                        final colorItem = colors[index];
                        return _isPracticeMode
                            ? PracticeCard(
                                colorItem: colorItem,
                                playAudio: playAudio,
                                bounceController: _bounceController,
                                scaleController: _scaleController,
                                colorAnimation: _colorAnimation,
                              )
                            : ColorLearningCard(
                                colorItem: colorItem,
                                playAudio: playAudio,
                                bounceController: _bounceController,
                                scaleController: _scaleController,
                                colorAnimation: _colorAnimation,
                              );
                      },
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

// ------------------ Learning Card ------------------
class ColorLearningCard extends StatelessWidget {
  final ColorItem colorItem;
  final Function(Uint8List) playAudio;
  final AnimationController bounceController;
  final AnimationController scaleController;
  final Animation<Color?> colorAnimation;

  const ColorLearningCard({
    super.key,
    required this.colorItem,
    required this.playAudio,
    required this.bounceController,
    required this.scaleController,
    required this.colorAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 300),
        tween: Tween<double>(begin: 0.8, end: 1.0),
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: AnimatedBuilder(
          animation: colorAnimation,
          builder: (context, child) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 10,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.9),
                      colorAnimation.value!.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'colorImage${colorItem.name}',
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: TweenAnimationBuilder(
                                duration: const Duration(milliseconds: 300),
                                tween: Tween<double>(begin: 0.5, end: 1.0),
                                builder: (context, scale, child) {
                                  return Transform.scale(
                                      scale: scale, child: child);
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.memory(colorItem.imageBytes),
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.memory(
                              colorItem.imageBytes,
                              height: 220,
                              width: 220,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      colorItem.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 36,
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
                    const SizedBox(height: 10),
                    if (colorItem.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          colorItem.description,
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
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 20),
                    if (colorItem.audioBytes != null)
                      GestureDetector(
                        onTapDown: (_) => scaleController.forward(),
                        onTapUp: (_) {
                          scaleController.reverse();
                          playAudio(colorItem.audioBytes!);
                        },
                        onTapCancel: () => scaleController.reverse(),
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 1, end: 0.95)
                              .animate(scaleController),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF9C27B0),
                                  const Color(0xFF9C27B0).withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedBuilder(
                                  animation: bounceController,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset:
                                          Offset(0, bounceController.value * 4),
                                      child: const Icon(
                                        Icons.music_note,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Дуу сонсох',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ------------------ Practice Card ------------------
class PracticeCard extends StatelessWidget {
  final ColorItem colorItem;
  final Function(Uint8List) playAudio;
  final AnimationController bounceController;
  final AnimationController scaleController;
  final Animation<Color?> colorAnimation;

  const PracticeCard({
    super.key,
    required this.colorItem,
    required this.playAudio,
    required this.bounceController,
    required this.scaleController,
    required this.colorAnimation,
  });

  @override
  Widget build(BuildContext context) {
    List<String> options = ['Улаан', 'Шар', 'Ногоон', colorItem.name];
    options.shuffle();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 300),
        tween: Tween<double>(begin: 0.8, end: 1.0),
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: AnimatedBuilder(
          animation: colorAnimation,
          builder: (context, child) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 10,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.9),
                      colorAnimation.value!.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: bounceController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, bounceController.value * 4),
                          child: const Text(
                            '🤔 Энэ ямар өнгө вэ?',
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
                    const SizedBox(height: 20),
                    Hero(
                      tag: 'colorImage${colorItem.name}',
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.memory(
                            colorItem.imageBytes,
                            height: 180,
                            width: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: options.map((option) {
                        return GestureDetector(
                          onTapDown: (_) => scaleController.forward(),
                          onTapUp: (_) {
                            scaleController.reverse();
                            final isCorrect = option == colorItem.name;

                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                backgroundColor: Colors.transparent,
                                child: TweenAnimationBuilder(
                                  duration: const Duration(milliseconds: 300),
                                  tween: Tween<double>(begin: 0.5, end: 1.0),
                                  builder: (context, scale, child) {
                                    return Transform.scale(
                                        scale: scale, child: child);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.9),
                                          const Color(0xFFB5EAD7)
                                              .withOpacity(0.9),
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
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isCorrect
                                              ? Icons.check_circle
                                              : Icons.error,
                                          size: 64,
                                          color: isCorrect
                                              ? const Color(0xFF4CAF50)
                                              : const Color(0xFFF44336),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          isCorrect
                                              ? '🎉 Зөв байна!'
                                              : '😅 Дахиад оролдоорой!',
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: isCorrect
                                                ? const Color(0xFF4CAF50)
                                                : const Color(0xFFF44336),
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black26,
                                                offset: const Offset(0, 1),
                                                blurRadius: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isCorrect
                                                ? const Color(0xFF4CAF50)
                                                : const Color(0xFFF44336),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                          ),
                                          child: const Text(
                                            'OK',
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
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
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );

                            if (isCorrect && colorItem.audioBytes != null) {
                              playAudio(colorItem.audioBytes!);
                            }
                          },
                          onTapCancel: () => scaleController.reverse(),
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 1, end: 0.95)
                                .animate(scaleController),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF9C27B0),
                                    const Color(0xFF9C27B0).withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.purple.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                option,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
