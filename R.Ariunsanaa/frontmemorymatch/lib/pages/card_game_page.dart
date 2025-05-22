import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class CardGamePage extends StatefulWidget {
  const CardGamePage({super.key});

  @override
  State<CardGamePage> createState() => _CardGamePageState();
}

class _CardGamePageState extends State<CardGamePage> with SingleTickerProviderStateMixin {
  List<bool> _flippedCards = [];
  List<bool> _matchedCards = [];
  List<String> _cardImages = [];
  int? _firstFlippedIndex;
  bool _canFlip = true;
  int _score = 0;
  Timer? _timer;
  int _timeLeft = 60;
  bool _isGameOver = false;
  int _currentLevel = 1;
  late ConfettiController _confettiController;
  bool _isTimeUp = false;
  late AnimationController _gameOverController;
  late Animation<Offset> _gameOverAnimation;
  final AudioPlayer _gameOverSound = AudioPlayer();
  bool _hasAudio = false;
  Timer? _autoSaveTimer;
  int? _currentPlayerId;

  final List<String> _possibleImages = [
    'images/tamga.png',
    'images/geltamga.jpg',
    'images/kcard.jpg',
    'images/Qcard.jpg',
    'images/jcard.jpg',
    'images/10card.png',
    'images/9card.jpg',
  ];

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
    _loadPlayerAndProgress();
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

  Future<void> _loadPlayerAndProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final playerId = prefs.getInt('playerId');
    final playerName = prefs.getString('playerName');

    if (playerId != null) {
      setState(() {
        _currentPlayerId = playerId;
      });
      await _loadGameProgress();
    } else {
      _initializeGame();
    }
  }

  Future<void> _loadGameProgress() async {
    if (_currentPlayerId == null) return;

    try {
      final apiService = ApiService();
      final progress = await apiService.getGameProgress(_currentPlayerId!, 'CARD_GAME');
      
      if (progress != null && mounted) {
        setState(() {
          _currentLevel = progress['current_level'] ?? 1;
          _score = progress['score'] ?? 0;
          _cardImages = List<String>.from(progress['card_images'] ?? []);
          _flippedCards = List<bool>.from(progress['flipped_cards'] ?? []);
          _matchedCards = List<bool>.from(progress['matched_cards'] ?? []);
          
          if (_cardImages.isEmpty) {
            _initializeGame();
          } else {
            _timeLeft = 60;
            _startTimer();
            _startAutoSave();
          }
        });
      } else {
        _initializeGame();
      }
    } catch (e) {
      print('Error loading game progress: $e');
      _initializeGame();
    }
  }

  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _saveGameProgress();
    });
  }

  Future<void> _saveGameProgress() async {
    if (_currentPlayerId == null) return;

    try {
      final apiService = ApiService();
      await apiService.saveGameProgress(
        _currentPlayerId!,
        'CARD_GAME',
        currentLevel: _currentLevel,
        score: _score,
        cardImages: _cardImages,
        flippedCards: _flippedCards,
        matchedCards: _matchedCards,
      );
    } catch (e) {
      print('Error saving game progress: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _autoSaveTimer?.cancel();
    _confettiController.dispose();
    _gameOverController.dispose();
    _gameOverSound.dispose();
    _saveGameProgress();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
          if (_timeLeft <= 10) {
            _isTimeUp = true;
          }
        } else {
          _gameOver(false);
        }
      });
    });
  }

  void _gameOver(bool won) {
    _timer?.cancel();
    _isGameOver = true;
    if (!mounted) return;

    if (won) {
      _confettiController.play();
    } else {
      _gameOverController.forward();
      _playGameOverSound();
    }

    Future.delayed(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      
      // Get the current player's ID
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () async {
                              try {
                                final apiService = ApiService();
                                await apiService.createGame(
                                  playerId ?? 0, 
                                  _score,
                                  gameType: 'CARD_GAME',
                                  gameName: 'Card Game Level $_currentLevel',
                                );
                                
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Оноо амжилттай хадгалагдлаа!'),
                                      backgroundColor: Colors.yellow,
                                    ),
                                  );
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
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              if (_currentLevel == 1) {
                                _startLevel2();
                              } else if (_currentLevel == 2) {
                                _startLevel3();
                              } else if (_currentLevel == 3) {
                                _startLevel4();
                              } else if (_currentLevel == 4) {
                                _startLevel5();
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.yellow.withOpacity(0.2),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: Colors.yellow.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: const Text(
                              'Дараагийн түвшин',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
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
                          'GAME OVER!',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.red.withOpacity(0.5),
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
                                'Цаг дууслаа!',
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: TextButton(
                                  onPressed: () async {
                                    try {
                                      final apiService = ApiService();
                                      await apiService.createGame(
                                        playerId ?? 0, 
                                        _score,
                                        gameType: 'CARD_GAME',
                                        gameName: 'Card Game Level $_currentLevel',
                                      );
                                      
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Оноо амжилттай хадгалагдлаа!'),
                                            backgroundColor: Colors.yellow,
                                          ),
                                        );
                                        Navigator.pop(context);
                                        _initializeGame();
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
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: TextButton(
                                  onPressed: () {
                                    _gameOverController.reverse().then((_) {
                                      Navigator.pop(context);
                                      _initializeGame();
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.red.withOpacity(0.2),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
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
    });
  }

  void _startLevel2() {
    setState(() {
      _currentLevel = 2;
      _flippedCards = List.generate(8, (_) => false);
      _matchedCards = List.generate(8, (_) => false);
      _firstFlippedIndex = null;
      _canFlip = true;
      _timeLeft = 60;
      _isGameOver = false;

      _cardImages = List.generate(8, (index) {
        if (index < 2) return 'images/tamga.png';
        if (index < 4) return 'images/geltamga.jpg';
        if (index < 6) return 'images/kcard.jpg';
        return 'images/Qcard.jpg';
      });

      _cardImages.shuffle();
    });
    _startTimer();
  }

  void _startLevel3() {
    setState(() {
      _currentLevel = 3;
      _flippedCards = List.generate(10, (_) => false);
      _matchedCards = List.generate(10, (_) => false);
      _firstFlippedIndex = null;
      _canFlip = true;
      _timeLeft = 90;
      _isGameOver = false;

      _cardImages = List.generate(10, (index) {
        if (index < 2) return 'images/tamga.png';
        if (index < 4) return 'images/geltamga.jpg';
        if (index < 6) return 'images/kcard.jpg';
        if (index < 8) return 'images/Qcard.jpg';
        return 'images/jcard.jpg';
      });

      _cardImages.shuffle();
    });
    _startTimer();
  }

  void _startLevel4() {
    setState(() {
      _currentLevel = 4;
      _flippedCards = List.generate(12, (_) => false);
      _matchedCards = List.generate(12, (_) => false);
      _firstFlippedIndex = null;
      _canFlip = true;
      _timeLeft = 120;
      _isGameOver = false;

      _cardImages = List.generate(12, (index) {
        if (index < 2) return 'images/tamga.png';
        if (index < 4) return 'images/geltamga.jpg';
        if (index < 6) return 'images/kcard.jpg';
        if (index < 8) return 'images/Qcard.jpg';
        if (index < 10) return 'images/jcard.jpg';
        return 'images/10card.png';
      });

      _cardImages.shuffle();
    });
    _startTimer();
  }

  void _startLevel5() {
    setState(() {
      _currentLevel = 5;
      _flippedCards = List.generate(14, (_) => false);
      _matchedCards = List.generate(14, (_) => false);
      _firstFlippedIndex = null;
      _canFlip = true;
      _timeLeft = 150;
      _isGameOver = false;

      _cardImages = List.generate(14, (index) {
        if (index < 2) return 'images/tamga.png';
        if (index < 4) return 'images/geltamga.jpg';
        if (index < 6) return 'images/kcard.jpg';
        if (index < 8) return 'images/Qcard.jpg';
        if (index < 10) return 'images/jcard.jpg';
        if (index < 12) return 'images/10card.png';
        return 'images/9card.jpg';
      });

      _cardImages.shuffle();
    });
    _startTimer();
  }

  void _initializeGame() {
    _timer?.cancel();
    setState(() {
      _currentLevel = 1;
      _flippedCards = List.generate(6, (_) => false);
      _matchedCards = List.generate(6, (_) => false);
      _firstFlippedIndex = null;
      _canFlip = true;
      _score = 0;
      _timeLeft = 60;
      _isGameOver = false;
      _isTimeUp = false;

      _cardImages = List.generate(6, (index) {
        if (index < 2) return 'images/tamga.png';
        if (index < 4) return 'images/geltamga.jpg';
        return 'images/kcard.jpg';
      });

      _cardImages.shuffle();
    });
    _startTimer();
  }

  int _calculatePoints(String firstCard, String secondCard) {
    if (firstCard == secondCard) {
      if (firstCard == 'images/geltamga.jpg') {
        return 1;
      } else if (firstCard == 'images/tamga.png') {
        return 1;
      } else if (firstCard == 'images/kcard.jpg') {
        return 1;
      } else if (firstCard == 'images/Qcard.jpg') {
        return 2;
      } else if (firstCard == 'images/jcard.jpg') {
        return 3;
      } else if (firstCard == 'images/10card.png') {
        return 4;
      } else if (firstCard == 'images/9card.jpg') {
        return 5;
      }
    }
    return 0;
  }

  bool _isMatch(String firstCard, String secondCard) {
    return firstCard == secondCard;
  }

  String _formatTime(int seconds) {
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  void _handleCardTap(int index) {
    if (_isGameOver || !_canFlip || _flippedCards[index] || _matchedCards[index]) return;

    setState(() {
      _flippedCards[index] = true;
      if (_firstFlippedIndex == null) {
        _firstFlippedIndex = index;
      } else {
        _canFlip = false;
        if (_isMatch(_cardImages[_firstFlippedIndex!], _cardImages[index])) {
          _matchedCards[_firstFlippedIndex!] = true;
          _matchedCards[index] = true;
          _score += _calculatePoints(_cardImages[_firstFlippedIndex!], _cardImages[index]);
          _firstFlippedIndex = null;
          _canFlip = true;
          
          if (_matchedCards.every((matched) => matched)) {
            _gameOver(true);
          }
          _saveGameProgress();
        } else {
          Future.delayed(const Duration(milliseconds: 800), () {
            setState(() {
              _flippedCards[_firstFlippedIndex!] = false;
              _flippedCards[index] = false;
              _firstFlippedIndex = null;
              _canFlip = true;
            });
          });
        }
      }
    });
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
          'Хөзрийн тоглоом - Level $_currentLevel',
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
            onPressed: _initializeGame,
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
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
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: _isTimeUp ? 0.5 : 1.0,
                      child: Container(
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
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _currentLevel == 5 ? MediaQuery.of(context).size.width * 0.05 : MediaQuery.of(context).size.width * 0.1,
                      vertical: 20,
                    ),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _currentLevel == 5 ? 4 : (_currentLevel >= 3 ? 4 : 3),
                        crossAxisSpacing: _currentLevel == 5 ? 8 : 10,
                        mainAxisSpacing: _currentLevel == 5 ? 8 : 10,
                        childAspectRatio: _currentLevel == 5 ? 0.8 : (_currentLevel >= 3 ? 0.7 : 0.65),
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _cardImages.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _handleCardTap(index),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return RotationYTransition(turns: animation, child: child);
                            },
                            child: _flippedCards[index]
                                ? Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
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
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        _cardImages[index],
                                        key: ValueKey(_cardImages[index] + index.toString()),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
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
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        'images/cart_back.png',
                                        key: ValueKey('back_$index'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RotationYTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> turns;

  const RotationYTransition({super.key, required this.child, required this.turns});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: turns,
      child: child,
      builder: (context, child) {
        final angle = turns.value * math.pi;
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          alignment: Alignment.center,
          child: child,
        );
      },
    );
  }
}
