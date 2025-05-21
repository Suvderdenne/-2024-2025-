import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:e_learn/tools/word.dart';

class WordDetailScreen extends StatefulWidget {
  final int wordId;
  final String token;

  const WordDetailScreen({super.key, required this.wordId, required this.token});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  late Future<Word> _wordFuture;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _wordFuture = fetchWordDetail(widget.wordId, widget.token);
  }

  Future<Word> fetchWordDetail(int id, String token) async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/words/$id/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return Word.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load word detail');
    }
  }

  Future<void> playBase64Audio(String base64String) async {
    try {
      Uint8List audioBytes = base64Decode(base64String);
      await _audioPlayer.play(BytesSource(audioBytes));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio error: could not play')),
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Detail', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF8BC34A),
      ),
      backgroundColor: Colors.white, // Set background color to white
      body: FutureBuilder<Word>(
        future: _wordFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF8BC34A))); // Use the specified color
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red))); // Keep error text red
          }

          final word = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        word.english,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF8BC34A)), // Use the specified color
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Color(0xFF8BC34A)), // Use the specified color
                      onPressed: () {
                        if (word.audioBase64 != null) {
                          playBase64Audio(word.audioBase64!);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No audio available')),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  word.mongolian,
                  style: const TextStyle(fontSize: 20, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                if (word.imageBase64 != null)
                  Center(
                    child: Container( // Added container for rounded corners
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12), // Rounded corners for image
                        boxShadow: [ // Add a shadow for better visual appearance
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12), // Ensure the image also has rounded corners
                        child: Image.memory(
                          base64Decode(word.imageBase64!),
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  )
                else
                  const Center(
                    child: Text(
                      'No image available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

