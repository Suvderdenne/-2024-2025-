import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class ChimpTestPage extends StatefulWidget {
  const ChimpTestPage({super.key});

  @override
  State<ChimpTestPage> createState() => _ChimpTestPageState();
}

class _ChimpTestPageState extends State<ChimpTestPage> with SingleTickerProviderStateMixin {
  List<int> _numbers = [];
  List<Offset> _positions = [];
  int _currentLevel = 1;
  int _score = 0;
  int _nextNumberToClick = 1;
  int _maxNumber = 0;
  bool _isGameOver = false;
  bool _hasClickedFirst = false;
  final math.Random _random = math.Random();
  late ConfettiController _confettiController;
  late AnimationController _gameOverController;
  late Animation<Offset> _gameOverAnimation;
  final AudioPlayer _gameOverSound = AudioPlayer();
  bool _hasAudio = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startNewRound();
    });
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
      _hasAudio = false;
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _gameOverController.dispose();
    _gameOverSound.dispose();
    super.dispose();
  }

  void _startNewRound() {
    // Start with 4 numbers in level 1, add more numbers in subsequent levels
    _maxNumber = 4 + (_currentLevel - 1);
    _numbers = List.generate(_maxNumber, (index) => index + 1);
    
    if (mounted) {
      _generateRandomPositions();
      setState(() {
        _nextNumberToClick = 1;
        _hasClickedFirst = false;
        _isGameOver = false;
      });
    }
  }

  void _generateRandomPositions() {
    if (!mounted) return;

    final size = MediaQuery.of(context).size;
    final screenWidth = size.width - 120; // More padding for edges
    final screenHeight = size.height - 250; // More padding for top and bottom
    _positions = [];

    for (int i = 0; i < _numbers.length; i++) {
      bool validPosition = false;
      Offset newPosition;

      while (!validPosition) {
        newPosition = Offset(
          20 + _random.nextDouble() * screenWidth,  // Add minimum edge padding
          100 + _random.nextDouble() * screenHeight, // Add minimum top padding
        );

        // Check if the new position overlaps with existing positions
        validPosition = true;
        for (var pos in _positions) {
          if ((pos - newPosition).distance < 120) { // Increased minimum distance between squares
            validPosition = false;
            break;
          }
        }

        if (validPosition) {
          _positions.add(newPosition);
        }
      }
    }
  }

  void _startNextLevel() {
    setState(() {
      _currentLevel++;
    });
    _startNewRound();
  }

  void _gameOver(bool won) async {
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
                              won ? 'Та бүх түвшинг дууслаа!' : 'Буруу дарлаа!',
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
                                  gameType: 'CHIMP_TEST',
                                  gameName: 'Chimp Test Level $_currentLevel',
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

  void _checkAnswer(int number) {
    if (number == _nextNumberToClick) {
      setState(() {
        if (_nextNumberToClick == 1) {
          _hasClickedFirst = true;
        }
        _nextNumberToClick++;
        if (_nextNumberToClick > _maxNumber) {
          _score += _currentLevel * 10;
          _gameOver(true);
        }
      });
    } else {
      _gameOver(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2196F3), // Bright blue background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Дарааллын санах ой - Level $_currentLevel',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
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
          color: Color(0xFF2196F3), // Solid bright blue background
        ),
        child: Stack(
          children: [
            for (int i = 0; i < _numbers.length; i++)
              if (_positions.length > i && (_currentLevel == 1 ? _numbers[i] >= _nextNumberToClick : (_numbers[i] >= _nextNumberToClick)))
                Positioned(
                  left: _positions[i].dx,
                  top: _positions[i].dy,
                  child: GestureDetector(
                    onTap: () => _checkAnswer(_numbers[i]),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          _numbers[i].toString(),
                          style: TextStyle(
                            color: _currentLevel == 1 
                                ? Colors.black87
                                : (!_hasClickedFirst
                                    ? Colors.black87
                                    : Colors.transparent),  // Completely hide the number
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
} 