import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:confetti/confetti.dart';

class SequenceMemoryPage extends StatefulWidget {
  const SequenceMemoryPage({super.key});

  @override
  State<SequenceMemoryPage> createState() => _SequenceMemoryPageState();
}

class _SequenceMemoryPageState extends State<SequenceMemoryPage> with SingleTickerProviderStateMixin {
  final List<String> _images = [
    'images/duck.png',
    'images/ufo.png',
    'images/orange.png',
    'images/brain.png',
    'images/giraffe.png',
    'images/sonic.png'
  ];
  
  late List<String> _currentRoundImages;
  late AnimationController _gameOverController;
  late Animation<Offset> _gameOverAnimation;
  late ConfettiController _confettiController;
  final AudioPlayer _gameOverSound = AudioPlayer();
  bool _hasAudio = false;
  
  bool _showingImages = true;
  bool _showingNumbers = false;
  bool _choosingAnswer = false;
  int _correctPosition = -1;
  int _selectedAnswer = -1;
  int _score = 0;
  int _currentLevel = 1;
  Timer? _timer;
  int _timeLeft = 30;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _gameOverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _gameOverAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _gameOverController,
      curve: Curves.easeOut,
    ));
    _checkAudioAvailability();
    _startNewRound();
  }

  Future<void> _checkAudioAvailability() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      _hasAudio = manifestMap.containsKey('assets/sounds/game_over.mp3');
    } catch (e) {
      debugPrint('Error checking audio availability: $e');
      _hasAudio = false;
    }
  }

  Future<void> _playGameOverSound() async {
    if (!_hasAudio) return;

    try {
      if (kIsWeb) {
        final bytes = await rootBundle.load('assets/sounds/game_over.mp3');
        final buffer = bytes.buffer;
        final audioBytes = buffer.asUint8List();
        await _gameOverSound.play(BytesSource(audioBytes));
      } else {
        await _gameOverSound.play(AssetSource('sounds/game_over.mp3'));
      }
    } catch (e) {
      debugPrint('Failed to play game over sound: $e');
      // If we fail to play, mark audio as unavailable
      _hasAudio = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _gameOverController.dispose();
    _confettiController.dispose();
    _gameOverSound.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _gameOver(false);
        }
      });
    });
  }

  void _startNewRound() {
    _timer?.cancel();
    
    List<String> allImages = [
      'images/duck.png',
      'images/ufo.png',
      'images/orange.png',
      'images/brain.png',
      'images/giraffe.png',
      'images/sonic.png'
    ];
    
    allImages.shuffle();
    _correctPosition = math.Random().nextInt(6);
    _currentRoundImages = List.filled(6, '');
    String targetImage = allImages[0];
    _currentRoundImages[_correctPosition] = targetImage;
    
    int otherImageIndex = 1;
    for (int i = 0; i < 6; i++) {
      if (i != _correctPosition) {
        if (otherImageIndex >= allImages.length) {
          otherImageIndex = (otherImageIndex % allImages.length) + 1;
        }
        _currentRoundImages[i] = allImages[otherImageIndex];
        otherImageIndex++;
      }
    }

    setState(() {
      _showingImages = true;
      _showingNumbers = false;
      _choosingAnswer = false;
      _selectedAnswer = -1;
      _timeLeft = 60;
      _isGameOver = false;
    });

    _startTimer();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showingImages = false;
          _choosingAnswer = true;
        });
      }
    });
  }

  void _startNextLevel() {
    setState(() {
      _currentLevel++;
      _timeLeft = math.max(30 - (_currentLevel - 1) * 5, 15); // Decrease time with each level
    });
    _startNewRound();
  }

  void _gameOver(bool won) async {
    _timer?.cancel();
    _isGameOver = true;
    if (!mounted) return;

    if (won) {
      _confettiController.play();
    } else {
      _gameOverController.forward();
      _playGameOverSound();
    }

    final prefs = await SharedPreferences.getInstance();
    final playerId = prefs.getInt('playerId');
    final playerName = prefs.getString('playerName');

    if (won && _currentLevel < 5) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Stack(
          children: [
            AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              contentPadding: EdgeInsets.zero,
              content: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.yellow.withOpacity(0.2),
                      Colors.orange.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.yellow.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Баяр хүргэе!',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.yellow.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Level $_currentLevel дууслаа!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Нийт оноо: $_score',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Level ${_currentLevel + 1}-т орж байна',
                            style: const TextStyle(
                              color: Colors.yellow,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _startNextLevel();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.yellow.withOpacity(0.2),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.yellow.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Дараагийн түвшин',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: math.pi / 2,
                maxBlastForce: 5,
                minBlastForce: 2,
                emissionFrequency: 0.05,
                numberOfParticles: 50,
                gravity: 0.1,
                shouldLoop: false,
                colors: const [
                  Colors.yellow,
                  Colors.orange,
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Stack(
          children: [
            SlideTransition(
              position: _gameOverAnimation,
              child: AlertDialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                contentPadding: EdgeInsets.zero,
                content: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withOpacity(0.95),
                        Colors.red.withOpacity(0.2),
                        Colors.black.withOpacity(0.95),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        won ? 'Баяр хүргэе!' : 'GAME OVER!',
                        style: TextStyle(
                          color: won ? Colors.yellow : Colors.red,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: won ? Colors.yellow.withOpacity(0.5) : Colors.red.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 0),
                            ),
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 5,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.red.withOpacity(0.1),
                              Colors.black.withOpacity(0.4),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              won ? 'Та бүх түвшинг дууслаа!' : 'Цаг дууслаа!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Нийт оноо: $_score',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (playerName == null)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'Тоглогчийн нэр бүртгэгдээгүй байна.',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () async {
                              try {
                                final apiService = ApiService();
                                await apiService.createGame(
                                  playerId ?? 0,
                                  _score,
                                  gameType: 'SEQUENCE_GAME',
                                  gameName: 'Sequence Game Level $_currentLevel',
                                );
                                
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Оноо амжилттай хадгалагдлаа!'),
                                      backgroundColor: Colors.yellow,
                                    ),
                                  );
                                  Navigator.pop(context);
                                  setState(() {
                                    _currentLevel = 1;
                                    _score = 0;
                                  });
                                  _startNewRound();
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Оноо хадгалахад алдаа гарлаа: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue.withOpacity(0.8),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: const Text(
                              'Оноо хадгалах',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () {
                              _gameOverController.reverse().then((_) {
                                Navigator.pop(context);
                                setState(() {
                                  _currentLevel = 1;
                                  _score = 0;
                                });
                                _startNewRound();
                              });
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red.withOpacity(0.2),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: Colors.red.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: const Text(
                              'Дахин тоглох',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (won)
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: math.pi / 2,
                  maxBlastForce: 5,
                  minBlastForce: 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 50,
                  gravity: 0.1,
                  shouldLoop: false,
                  colors: const [
                    Colors.yellow,
                    Colors.orange,
                  ],
                ),
              ),
          ],
        ),
      );
    }
  }

  void _checkAnswer(int selected) {
    setState(() {
      _selectedAnswer = selected;
    });

    if (selected == _correctPosition) {
      setState(() {
        _score += _currentLevel * 10; // Increase points based on level
      });
      _gameOver(true);
    } else {
      _gameOver(false);
    }
  }

  String _formatTime(int seconds) {
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      padding: const EdgeInsets.all(20),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            _currentRoundImages[index],
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }

  Widget _buildAnswerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      padding: const EdgeInsets.all(20),
      itemCount: 6,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _checkAnswer(index),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Байрлалын ангууч - Level $_currentLevel',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _startNewRound,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f172a),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        'Оноо: $_score',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _timeLeft <= 10 
                            ? Colors.red.withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _timeLeft <= 10
                              ? Colors.red.withOpacity(0.5)
                              : Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        'Хугацаа: ${_formatTime(_timeLeft)}',
                        style: TextStyle(
                          color: _timeLeft <= 10 ? Colors.red : Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _showingImages
                      ? 'Зургуудыг цээжлээрэй!'
                      : '${_currentRoundImages[_correctPosition].split('/').last.split('.').first} хаана байсан?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: _showingImages
                    ? _buildImageGrid()
                    : _buildAnswerGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
