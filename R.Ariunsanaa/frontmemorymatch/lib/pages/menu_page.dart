import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'username.dart';
import 'package:frontmemorymatch/pages/scoreboardPage.dart';


class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String? currentPlayerName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayerData();
  }

  Future<void> _loadPlayerData() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('playerName');
      
      setState(() {
        currentPlayerName = savedName;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading player data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _promptForName() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage(
        initialName: currentPlayerName,
      )),
    );

    if (result == true) {
      _loadPlayerData();
    }
  }

  Future<void> _clearPlayerName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('playerName');
    setState(() {
      currentPlayerName = null;
    });
  }

  Widget _buildPlayerSection() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2196F3),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1D1E33).withOpacity(0.8),
            const Color(0xFF2D2E42).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Тоглогч: ${currentPlayerName ?? "Нэргүй Байна"}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              if (currentPlayerName != null)
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF2196F3)),
                  onPressed: _promptForName,
                ),
            ],
          ),
          if (currentPlayerName == null)
            TextButton(
              onPressed: _promptForName,
              child: const Text(
                'Нэр оруулах',
                style: TextStyle(
                  color: Color(0xFF2196F3),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          if (currentPlayerName != null)
            TextButton(
              onPressed: _clearPlayerName,
              child: const Text(
                'Нэр арилгах',
                style: TextStyle(
                  color: Color(0xFFFF5252),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Буцах',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPlayerSection(),
                const SizedBox(height: 30),
                _buildMenuButton(
                  'Онооны самбар',
                  Icons.leaderboard,
                  const Color(0xFF4CAF50),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScoreboardPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildMenuButton(
                  'Шинэ нэр оруулах',
                  Icons.person_add,
                  const Color(0xFF2196F3),
                  _promptForName,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
