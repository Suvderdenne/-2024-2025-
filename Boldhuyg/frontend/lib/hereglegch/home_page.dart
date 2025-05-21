import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'subject_selection_page.dart';
import 'garden_page.dart';
import 'package:frontend/hereglegch/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late Future<List<dynamic>> futureSchools;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    futureSchools = fetchSchools();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio('audio/sainuu.mp3');
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<List<dynamic>> fetchSchools() async {
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:8000/api/schools/'));
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      throw Exception('Failed to load schools');
    } catch (e) {
      throw Exception('Error fetching schools: $e');
    }
  }

  Future<void> _playAudio(String path) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(path));
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  Future<void> _playBase64Audio(String base64) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(BytesSource(base64Decode(base64)));
    } catch (e) {
      debugPrint('Error playing base64 audio: $e');
    }
  }

  Widget _buildSchoolGrid(List<dynamic> schools) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: schools.length,
      itemBuilder: (context, index) {
        final school = schools[index];
        final isKindergarten =
            (school['name'] as String?)?.contains("Цэцэрлэг") ?? false;
        final icon = school['icon_base64'] as String?;

        return _SchoolCard(
          isKindergarten: isKindergarten,
          icon: icon,
          name: school['name'] ?? 'Сургууль / Цэцэрлэг',
          audio: school['audio_base64'] as String?,
          onTap: () => _handleSchoolTap(isKindergarten, school['audio_base64']),
        );
      },
    );
  }

  Future<void> _handleSchoolTap(bool isKindergarten, String? audio) async {
    if (audio != null) {
      await _playBase64Audio(audio);
    } else {
      await _playAudio(
          isKindergarten ? 'audio/tsetserleg.mp3' : 'audio/surguuli.mp3');
    }

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            isKindergarten ? GardenPage() : SubjectSelectionPage(token: token),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[800],
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.home, size: 28, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Нүүр хуудас',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.05,
              vertical: height * 0.02,
            ),
            child: Column(
              children: [
                _buildHeaderImage(),
                SizedBox(height: height * 0.03),
                _buildWelcomeText(),
                SizedBox(height: height * 0.04),
                _buildSchoolList(),
                SizedBox(height: height * 0.04),
                _buildFooterText(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.asset(
          'assets/ami.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Text(
      'Сайн уу хүүхдүүдээ!',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple[800],
        shadows: [
          Shadow(
            color: Colors.white.withOpacity(0.5),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolList() {
    return FutureBuilder<List<dynamic>>(
      future: futureSchools,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Алдаа: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Сургууль олдсонгүй'));
        }
        return _buildSchoolGrid(snapshot.data!);
      },
    );
  }

  Widget _buildFooterText() {
    return Text(
      'Таны хөгжилд бид тусалъя! 🌱',
      style: TextStyle(
        fontSize: 16,
        color: Colors.deepPurple[400],
      ),
    );
  }
}

class _SchoolCard extends StatelessWidget {
  final bool isKindergarten;
  final String? icon;
  final String name;
  final String? audio;
  final VoidCallback onTap;

  const _SchoolCard({
    required this.isKindergarten,
    this.icon,
    required this.name,
    this.audio,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isKindergarten ? Colors.pinkAccent : Colors.deepPurpleAccent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            const SizedBox(height: 16),
            _buildName(),
            const SizedBox(height: 12),
            _buildSelectButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: icon != null && icon!.isNotEmpty
            ? Image.memory(base64Decode(icon!), fit: BoxFit.contain)
            : Image.asset(
                isKindergarten ? 'assets/kind.jpg' : 'assets/school.png',
                fit: BoxFit.contain,
              ),
      ),
    );
  }

  Widget _buildName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        name,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Сонгох',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isKindergarten ? Colors.pinkAccent : Colors.deepPurpleAccent,
        ),
      ),
    );
  }
}
