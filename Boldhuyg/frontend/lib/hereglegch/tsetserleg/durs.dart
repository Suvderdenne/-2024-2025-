import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

class ShapesPage extends StatefulWidget {
  const ShapesPage({super.key});

  @override
  State<ShapesPage> createState() => _ShapesPageState();
}

class _ShapesPageState extends State<ShapesPage> with TickerProviderStateMixin {
  List<dynamic> shapes = [];
  final AudioPlayer audioPlayer = AudioPlayer();
  late TabController _tabController;
  late AnimationController _bounceController;
  late AnimationController _rotateController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _bounceController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _rotateController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    fetchShapes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    audioPlayer.dispose();
    _bounceController.dispose();
    _rotateController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> fetchShapes() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/animals/by-subject/5/'),
    );

    if (response.statusCode == 200) {
      setState(() {
        shapes = json.decode(utf8.decode(response.bodyBytes));
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Дүрсүүдийг ачаалахад алдаа гарлаа',
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

  Future<void> _playAudio(String base64Audio) async {
    final bytes = base64Decode(base64Audio);
    await audioPlayer.stop();
    await audioPlayer.play(BytesSource(bytes));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        "👏 Мундаг байна!",
        style: TextStyle(fontSize: 22, color: Colors.white),
      ),
      backgroundColor: Colors.green[400],
      duration: Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.all(16),
    ));
  }

  void showZoomedImageDialog(Uint8List imageBytes, String shapeName) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: TweenAnimationBuilder(
            duration: Duration(milliseconds: 300),
            tween: Tween<double>(begin: 0.5, end: 1.0),
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  shapeName,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.purple[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      )
                    ],
                  ),
                  padding: EdgeInsets.all(20),
                  child: Hero(
                    tag: 'shape_$shapeName',
                    child: AnimatedScale(
                      scale: 1.2,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeOutBack,
                      child: Image.memory(
                        imageBytes,
                        height: 200,
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLearnTab() {
    return shapes.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _rotateController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateController.value * 2 * pi,
                      child: Icon(
                        Icons.category,
                        size: 64,
                        color: Colors.purple[300],
                      ),
                    );
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Дүрсүүдийг ачааллаж байна...',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.purple[700],
                  ),
                ),
              ],
            ),
          )
        : GridView.builder(
            padding: EdgeInsets.all(16),
            itemCount: shapes.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final shape = shapes[index];
              final imageBytes = shape['image_base64'] != null
                  ? base64Decode(shape['image_base64'])
                  : null;

              return TweenAnimationBuilder(
                duration: Duration(milliseconds: 300),
                tween: Tween<double>(begin: 0.8, end: 1.0),
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: GestureDetector(
                  onTapDown: (_) => _scaleController.forward(),
                  onTapUp: (_) {
                    _scaleController.reverse();
                    if (imageBytes != null) {
                      showZoomedImageDialog(
                          imageBytes, shape['animal_name'] ?? '');
                    }
                    if (shape['audio_base64'] != null) {
                      _playAudio(shape['audio_base64']);
                    }
                  },
                  onTapCancel: () => _scaleController.reverse(),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 1, end: 0.95)
                        .animate(_scaleController),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber[100]!,
                            Colors.orange[50]!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.pinkAccent, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: Offset(4, 6),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Hero(
                            tag: 'shape_${shape['animal_name']}',
                            child: imageBytes != null
                                ? Image.memory(
                                    imageBytes,
                                    height: 90,
                                    width: 90,
                                    fit: BoxFit.contain,
                                  )
                                : Icon(Icons.image_not_supported,
                                    size: 60, color: Colors.grey),
                          ),
                          SizedBox(height: 10),
                          Flexible(
                            child: Text(
                              shape['animal_name'] ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          AnimatedBuilder(
                            animation: _bounceController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _bounceController.value * 4),
                                child: Icon(
                                  Icons.volume_up_rounded,
                                  size: 30,
                                  color: Colors.orange[400],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildPracticeTab() {
    if (shapes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _rotateController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateController.value * 2 * pi,
                  child: Icon(
                    Icons.category,
                    size: 64,
                    color: Colors.purple[300],
                  ),
                );
              },
            ),
            SizedBox(height: 16),
            Text(
              'Дүрсүүдийг ачааллаж байна...',
              style: TextStyle(
                fontSize: 20,
                color: Colors.purple[700],
              ),
            ),
          ],
        ),
      );
    }

    final random = Random();
    final correctShape = shapes[random.nextInt(shapes.length)];

    final options = [...shapes]..shuffle();
    final shownOptions = options.take(3).toList();
    if (!shownOptions.contains(correctShape)) {
      shownOptions[random.nextInt(3)] = correctShape;
    }

    final imageBytes = correctShape['image_base64'] != null
        ? base64Decode(correctShape['image_base64'])
        : null;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.purple[100]!,
            Colors.blue[50]!,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _bounceController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _bounceController.value * 4),
                child: Text(
                  "🧠 Энэ ямар дүрс вэ?",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 30),
          if (imageBytes != null)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              child: Image.memory(
                imageBytes,
                height: 160,
                width: 160,
                fit: BoxFit.contain,
              ),
            ),
          SizedBox(height: 40),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: shownOptions.map((shape) {
              return GestureDetector(
                onTapDown: (_) => _scaleController.forward(),
                onTapUp: (_) {
                  _scaleController.reverse();
                  if (shape['id'] == correctShape['id']) {
                    _playAudio(shape['audio_base64']);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        "😅 Дахиад оролдоорой!",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      backgroundColor: Colors.redAccent,
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: EdgeInsets.all(16),
                    ));
                  }
                },
                onTapCancel: () => _scaleController.reverse(),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1, end: 0.95)
                      .animate(_scaleController),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.pink[400]!, Colors.pinkAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text(
                      shape['animal_name'] ?? '',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ["Сурах", "Бататгах"];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink[100]!,
              Colors.blue[50]!,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pinkAccent, Colors.pink[400]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.8),
                                    Colors.pink[100]!
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.pink.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.pink[700],
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          AnimatedBuilder(
                            animation: _bounceController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _bounceController.value * 4),
                                child: Icon(
                                  Icons.category,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Дүрсүүд",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      labelStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      tabs: tabs.map((tab) => Tab(text: tab)).toList(),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLearnTab(),
                  _buildPracticeTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
