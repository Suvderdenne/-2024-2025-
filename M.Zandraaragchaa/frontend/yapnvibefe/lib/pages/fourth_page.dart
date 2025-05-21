import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:card_swiper/card_swiper.dart';
import 'dart:math'; // Import for Random

class FourthPage extends StatefulWidget {
  final String levelName;
  final String playerName;

  FourthPage({required this.levelName, required this.playerName});

  @override
  State<FourthPage> createState() => _FourthPageState();
}

class _FourthPageState extends State<FourthPage> {
  String _selectedLanguage = "eng";
  bool _isPenaltyMode = false;
  int _timeLeft = 15;
  Timer? _timer;
  List<Map<String, dynamic>> questionsWithIds = [];
  List<Map<String, dynamic>> daresWithIds = []; // For storing dares

  Color getCardColor(String playerName) {
    final name = playerName.toLowerCase();

    if (_selectedLanguage == 'eng') {
      // English check
      if (name.contains("couple")) return Colors.pink.shade100;
      if (name.contains("friends")) return Colors.lightBlue.shade100;
      if (name.contains("work")) return Colors.purpleAccent.shade100;
      if (name.contains("hobby")) return Colors.teal.shade100;
      if (name.contains("original")) return Colors.redAccent.shade100;
      if (name.contains("family"))
        return const Color.fromARGB(255, 151, 231, 155);
      if (name.contains("classmates")) return Colors.yellowAccent.shade100;
      if (name.contains("major")) return Colors.orange.shade100;
      if (name.contains("parents")) return Colors.white;
    } else {
      // Mongolian check
      if (name.contains("хос")) return Colors.pink.shade100;
      if (name.contains("найз")) return Colors.lightBlue.shade100;
      if (name.contains("ажил") || name.contains("work"))
        return Colors.purpleAccent.shade100;
      if (name.contains("хобби")) return Colors.teal.shade100;
      if (name.contains("original")) return Colors.redAccent.shade100;
      if (name.contains("гэр бүл"))
        return const Color.fromARGB(255, 151, 231, 155);
      if (name.contains("ангийнхан")) return Colors.yellowAccent.shade100;
      if (name.contains("мэргэжил")) return Colors.orange.shade100;
      if (name.contains("эхчүүд") || name.contains("parents"))
        return Colors.white;
    }

    return Colors.tealAccent; // Default color if no match found
  }

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _fetchQuestions();
    _fetchDares(); // Fetch dares when the page is initialized
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? "eng";
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 15;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        timer.cancel();
        _showDareBox();
      }
    });
  }

  void _showDareBox() {
    if (daresWithIds.isEmpty) {
      print('No dares available.');
      return; // Exit if there are no dares
    }

    // Pick a random dare from the list
    final randomIndex = Random().nextInt(daresWithIds.length);
    final dare = daresWithIds[randomIndex];

    // Choose the correct dare text based on the selected language
    String dareText =
        _selectedLanguage == 'eng' ? dare['eng_text'] : dare['mon_text'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            _selectedLanguage == 'eng' ? 'Dare Time!' : 'Шийтгэл!',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            dareText,
            style: TextStyle(fontSize: 20),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                _selectedLanguage == 'eng' ? 'OK' : 'OK',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  void _togglePenaltyMode(bool value) {
    setState(() {
      _isPenaltyMode = value;
      if (_isPenaltyMode) {
        _startTimer();
      } else {
        _timer?.cancel();
        _timeLeft = 15;
      }
    });
  }

  Future<void> _fetchQuestions() async {
    final url = Uri.parse('http://127.0.0.1:8000/questions/');
    // final url = Uri.parse('http://192.168.4.245/questions/');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'playertypee': widget.playerName.toLowerCase(),
          'questionlevel': widget.levelName.toLowerCase(),
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['questions'] != null && data['questions'] is List) {
          setState(() {
            questionsWithIds = List<Map<String, dynamic>>.from(
              data['questions'].map((q) => {
                    'id': q['id'],
                    'text': _selectedLanguage == 'eng'
                        ? q['eng_text']
                        : q['mon_text'],
                  }),
            );
            questionsWithIds.shuffle(); // Shuffle questions
          });
        } else {
          print('No questions or invalid format');
        }
      } else {
        print('Failed to fetch questions');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fetchDares() async {
    final url = Uri.parse('http://127.0.0.1:8000/dares/');
    // final url = Uri.parse('http://192.168.4.245/dares/');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'playertypee': widget.playerName.toLowerCase(),
          'questionlevel': widget.levelName.toLowerCase(),
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['dares'] != null && data['dares'] is List) {
          setState(() {
            daresWithIds = List<Map<String, dynamic>>.from(
              data['dares'].map((d) => {
                    'id': d['id'], // Assuming each dare has an 'id'
                    'eng_text': d['eng_text'] ?? '', // English text for dare
                    'mon_text': d['mon_text'] ?? '' // Mongolian text for dare
                  }),
            );
            daresWithIds.shuffle(); // Shuffle dares along with their IDs
          });
        } else {
          print('No dares or invalid format');
        }
      } else {
        print('Failed to fetch dares');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color cardColor = getCardColor(widget.playerName);

    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedLanguage == 'eng'
                      ? 'Play with penalty:'
                      : 'Шийтгэлтэй тоглох',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: _isPenaltyMode,
                  onChanged: _togglePenaltyMode,
                  activeColor: Colors.red,
                ),
              ],
            ),
            SizedBox(height: 10),

            // Swipable Cards
            Expanded(
              child: questionsWithIds.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : Swiper(
                      itemCount: questionsWithIds.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "${widget.playerName} - ${widget.levelName}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      questionsWithIds[index]['text'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_isPenaltyMode)
                                  Text(
                                    '0:${_timeLeft.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 35,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        );
                      },
                      onIndexChanged: (index) {
                        if (_isPenaltyMode) _startTimer();
                      },
                      loop: false,
                      control: null,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
