import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game.dart'; // Ensure this file contains the Game model
import '../services/api_service.dart'; // API service to fetch game scores

class ScoreboardPage extends StatefulWidget {
  const ScoreboardPage({super.key});

  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  List<Game> gameScores = [];
  bool isLoading = true;
  final ApiService _apiService = ApiService();
  String sortBy = 'score'; // 'score' or 'name'

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    setState(() => isLoading = true);
    try {
      List<Game> scores = await _apiService.getGames();
      
      // Sort scores based on selected criteria
      scores.sort((a, b) {
        if (sortBy == 'name') {
          return a.playerName.compareTo(b.playerName);
        } else {
          return b.score.compareTo(a.score); // High score first
        }
      });

      setState(() {
        gameScores = scores;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading scores: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Онооны самбар',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            color: const Color(0xFF1D1E33),
            onSelected: (String value) {
              setState(() {
                sortBy = value;
                _loadScores();
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'score',
                child: Row(
                  children: [
                    Icon(Icons.emoji_events,
                         color: sortBy == 'score' ? const Color(0xFF2196F3) : Colors.white,
                         size: 20),
                    const SizedBox(width: 8),
                    Text('Өндөр оноогоор',
                        style: TextStyle(
                          color: sortBy == 'score' ? const Color(0xFF2196F3) : Colors.white,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'name',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha,
                         color: sortBy == 'name' ? const Color(0xFF2196F3) : Colors.white,
                         size: 20),
                    const SizedBox(width: 8),
                    Text('Нэрээр эрэмбэлэх',
                        style: TextStyle(
                          color: sortBy == 'name' ? const Color(0xFF2196F3) : Colors.white,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0E21),
              Color(0xFF1D1E33),
              Color(0xFF2D2E42),
            ],
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2196F3),
                ),
              )
            : gameScores.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 64,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Оноо олдсонгүй',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: gameScores.length,
                    itemBuilder: (context, index) {
                      final game = gameScores[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF1D1E33).withOpacity(0.8),
                              const Color(0xFF2D2E42).withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFF2196F3).withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2196F3).withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: const Color(0xFF2196F3).withOpacity(0.2),
                                          child: Text(
                                            game.playerName[0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Color(0xFF2196F3),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            game.playerName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF4CAF50).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      'Оноо: ${game.score}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.style,
                                    color: Color(0xFF2196F3),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    game.gameType ?? "Memory Match",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
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
