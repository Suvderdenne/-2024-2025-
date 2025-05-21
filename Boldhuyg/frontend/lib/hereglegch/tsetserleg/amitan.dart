import 'package:flutter/material.dart';
import 'animal_detail_page.dart';
import '../../services/animal_service.dart';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

class AnimalPage extends StatefulWidget {
  const AnimalPage({super.key});

  @override
  State<AnimalPage> createState() => _AnimalPageState();
}

class _AnimalPageState extends State<AnimalPage> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _scaleController;
  final AnimalService _animalService = AnimalService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Map<String, List<Map<String, dynamic>>> animalData = {};
  bool isLoading = true;
  String? error;
  String? currentlyPlayingType;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _loadAnimalData();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() => currentlyPlayingType = null);
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _scaleController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playTypeAudio(String typeName, String? audioBase64) async {
    if (audioBase64 == null) {
      print('No audio data available for type: $typeName');
      return;
    }

    try {
      if (currentlyPlayingType == typeName) {
        print('Stopping current audio playback');
        await _audioPlayer.stop();
        setState(() => currentlyPlayingType = null);
      } else {
        if (currentlyPlayingType != null) {
          print('Stopping previous audio playback');
          await _audioPlayer.stop();
        }

        print('Playing audio for type: $typeName');

        try {
          // Create a data URI for the audio
          final audioUri = 'data:audio/mpeg;base64,$audioBase64';
          print('Playing audio from URI');

          // Play the audio
          await _audioPlayer.play(
            UrlSource(audioUri),
            volume: 1.0,
          );
          print('Playback started for type: $typeName');

          setState(() => currentlyPlayingType = typeName);
        } catch (e) {
          print('Error during audio playback setup: $e');
          setState(() => currentlyPlayingType = null);
        }
      }
    } catch (e) {
      print('Error playing audio: $e');
      setState(() => currentlyPlayingType = null);
    }
  }

  Future<void> _loadAnimalData() async {
    try {
      final types = await _animalService.getAnimalTypes();
      final Map<String, List<Map<String, dynamic>>> newData = {};

      for (var type in types) {
        print('Processing type: ${type['name']}');
        final animals = type['animals'] as List<dynamic>;
        newData[type['name']] = animals.map((animal) {
          final hasAudio = animal['audio_base64'] != null;
          print('Animal ${animal['animal_name']} has audio: $hasAudio');

          return {
            'name': '${animal['animal_name']}',
            'image': animal['image_base64'] != null
                ? 'data:image/jpeg;base64,${animal['image_base64']}'
                : 'assets/animals/placeholder.jpg',
            'description': animal['description'],
            'audio': animal['audio_base64'],
            'video': animal['video_base64'],
          };
        }).toList();
      }

      setState(() {
        animalData = newData;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading animal data: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(width * 0.03),
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
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: width * 0.06,
                          color: const Color(0xFF9C27B0),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _bounceController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _bounceController.value * 4),
                              child: Text(
                                '🐾 Амьтан 🐾',
                                style: TextStyle(
                                  fontSize: width * 0.06,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF9C27B0),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: width * 0.1),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : error != null
                        ? Center(child: Text('Error: $error'))
                        : ListView(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.04,
                              vertical: height * 0.02,
                            ),
                            children: animalData.entries.map((entry) {
                              String type = entry.key;
                              List<Map<String, dynamic>> animals = entry.value;

                              return Padding(
                                padding: EdgeInsets.only(bottom: height * 0.03),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width * 0.04,
                                        vertical: height * 0.01,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.8),
                                            const Color(0xFFFFD1DC)
                                                .withOpacity(0.8),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.purple.withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          if (entry.value.isNotEmpty &&
                                              entry.value[0]['audio'] != null) {
                                            _playTypeAudio(
                                                type, entry.value[0]['audio']);
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "✨ $type ✨",
                                              style: TextStyle(
                                                fontSize: width * 0.055,
                                                color: const Color(0xFF9C27B0),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (entry.value.isNotEmpty &&
                                                entry.value[0]['audio'] != null)
                                              Icon(
                                                currentlyPlayingType == type
                                                    ? Icons.pause_circle_filled
                                                    : Icons.play_circle_filled,
                                                color: const Color(0xFF9C27B0),
                                                size: 32,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: height * 0.02),
                                    SizedBox(
                                      height: height * 0.25,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: animals.length,
                                        itemBuilder: (context, index) {
                                          final animal = animals[index];
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      AnimalDetailPage(
                                                    type: type,
                                                    animals: animals
                                                        .map((animal) => {
                                                              'name': animal[
                                                                  'name'],
                                                              'image': animal[
                                                                  'image'],
                                                              'description': animal[
                                                                  'description'],
                                                              'audio': animal[
                                                                  'audio'],
                                                              'video': animal[
                                                                  'video'],
                                                            })
                                                        .toList(),
                                                  ),
                                                ),
                                              );
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 400),
                                              curve: Curves.easeInOut,
                                              width: width * 0.35,
                                              margin: EdgeInsets.only(
                                                  right: width * 0.03),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.white
                                                        .withOpacity(0.9),
                                                    const Color(0xFFB5EAD7)
                                                        .withOpacity(0.9),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.purple
                                                        .withOpacity(0.2),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height: height * 0.18,
                                                    width: width * 0.35,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
                                                          blurRadius: 5,
                                                          offset: const Offset(
                                                              0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      child: animal['image']
                                                              .startsWith(
                                                                  'data:image')
                                                          ? Image.memory(
                                                              base64Decode(animal[
                                                                      'image']
                                                                  .split(
                                                                      ',')[1]),
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Image.asset(
                                                              animal['image'],
                                                              fit: BoxFit.cover,
                                                            ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: height * 0.01),
                                                  Text(
                                                    animal['name'],
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: width * 0.045,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                          0xFF9C27B0),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
