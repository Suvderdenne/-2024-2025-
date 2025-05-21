import 'dart:convert';
import 'package:e_learn/screens/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LessonScreen extends StatefulWidget {
  final String token;

  const LessonScreen({super.key, required this.token});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  List<String> categories = [];
  List<String> levels = [];
  List<dynamic> lessons = [];
  String? selectedCategory;
  String? selectedLevel;
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final categoryResponse =
          await http.get(Uri.parse('http://localhost:8000/categories/'));
      final levelResponse =
          await http.get(Uri.parse('http://localhost:8000/levels/'));

      if (categoryResponse.statusCode == 200 &&
          levelResponse.statusCode == 200) {
        final categoryData =
            json.decode(utf8.decode(categoryResponse.bodyBytes)) as List;
        final levelData =
            json.decode(utf8.decode(levelResponse.bodyBytes)) as List;

        setState(() {
          categories =
              categoryData.map((item) => item['name'] as String).toList();
          levels = levelData.map((item) => item['name'] as String).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  Future<void> fetchLessons() async {
    if (selectedCategory == null || selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both category and level')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:8000/lessons/?category=$selectedCategory&level=$selectedLevel'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as List;

        setState(() {
          lessons = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load lessons: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching lessons: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lessons',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8BC34A),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF8BC34A)))
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Select Category & Level',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category,
                              style: const TextStyle(fontSize: 18)),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: const TextStyle(fontSize: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF8BC34A)),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select a category'
                          : null,
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedLevel,
                      onChanged: (value) {
                        setState(() {
                          selectedLevel = value;
                        });
                      },
                      items: levels.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level,
                              style: const TextStyle(fontSize: 18)),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Level',
                        labelStyle: const TextStyle(fontSize: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF8BC34A)),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select a level'
                          : null,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          fetchLessons();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        backgroundColor: const Color(0xFF8BC34A),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      child: const Text('Get Lessons'),
                    ),
                    const SizedBox(height: 20),
                    // Display Lessons
                    Expanded(
                      child: lessons.isEmpty
                          ? const Center(
                              child: Text(
                                'No lessons available',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black54),
                              ),
                            )
                          : ListView.builder(
                              itemCount: lessons.length,
                              itemBuilder: (context, index) {
                                final lesson = lessons[index];
                                return Card(
  margin: const EdgeInsets.only(bottom: 12),
  elevation: 4,
  child: InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            token: widget.token,
            category: lesson['category']['name'],
            level: lesson['level']['name'],
          ),
        ),
      );
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lesson['image_base64'] != null)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            child: Image.memory(
              base64Decode(lesson['image_base64']),
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
          )
        else
          const SizedBox(
            height: 150,
            child: Center(child: Icon(Icons.image_not_supported, size: 40)),
          ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson['title'] ?? 'N/A',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 5),
              Text(
                '${lesson['level']['name']} - ${lesson['category']['name']}',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
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
              ),
      ),
    );
  }
}

