import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'animal_detail.dart';

class Animal {
  final String name;
  final String? imageBase64;
  final String? audioBase64;
  final int id;

  Animal(
      {required this.name,
      this.imageBase64,
      this.audioBase64,
      required this.id});

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      name: json['animal_name'],
      imageBase64: json['image_base64'],
      audioBase64: json['audio_base64'],
      id: json['id'],
    );
  }
}

class AnimalListPage extends StatefulWidget {
  final int subjectId;

  const AnimalListPage({super.key, required this.subjectId});

  @override
  State<AnimalListPage> createState() => _AnimalListPageState();
}

class _AnimalListPageState extends State<AnimalListPage> {
  List<Animal> animals = [];
  bool _isLoading = true;

  final String apiUrl = 'http://127.0.0.1:8000/animals/by-subject/6/';

  @override
  void initState() {
    super.initState();
    fetchAnimalsBySubject(widget.subjectId);
  }

  Future<void> fetchAnimalsBySubject(int subjectId) async {
    final response = await http.get(Uri.parse('$apiUrl$subjectId/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        animals = data.map((e) => Animal.fromJson(e)).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      throw Exception('Failed to load animals');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Амьтдын жагсаалт')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: animals.length,
              itemBuilder: (context, index) {
                final animal = animals[index];
                return ListTile(
                  title: Text(animal.name),
                  leading: animal.imageBase64 != null
                      ? Image.memory(
                          base64Decode(animal.imageBase64!),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image),
                  onTap: () {
                    // Navigate to the animal detail page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AnimalDetailPage(animalId: animal.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
