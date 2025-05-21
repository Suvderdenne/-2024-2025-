import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'third_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  String _selectedLanguage = "eng";
  List playertypes = [];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    fetchPlayertypes();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? "eng";
    });
  }

  Future<void> fetchPlayertypes() async {
    final url = Uri.parse('http://127.0.0.1:8000/players/');
    // final url = Uri.parse('http://192.168.4.245/players/');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data != null && data["playertypes"] != null) {
          setState(() {
            playertypes = data["playertypes"];
          });
        } else {
          print("Invalid response format or missing data.");
        }
      } else {
        print("Failed to fetch data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: playertypes.isEmpty
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two items per row
                  crossAxisSpacing: 10.0, // Space between columns
                  mainAxisSpacing: 10.0, // Space between rows
                  childAspectRatio: 1, // Aspect ratio of each card
                ),
                itemCount: playertypes.length,
                itemBuilder: (context, index) {
                  var item = playertypes[index];
                  String displayName = _selectedLanguage == "eng"
                      ? item["eng_name"]
                      : item["mon_name"];
                  return _buildListItem(displayName, item);
                },
              ),
      ),
    );
  }

  Widget _buildListItem(String displayName, Map item) {
    Widget leadingIcon;
    Color backgroundColor;

    if (item['eng_name'].toLowerCase().contains("couple")) {
      leadingIcon = FaIcon(FontAwesomeIcons.handHoldingHeart,
          color: Colors.pink, size: 30);
      backgroundColor = Colors.pink.shade100;
    } else if (item['eng_name'].toLowerCase().contains("friends")) {
      leadingIcon = FaIcon(FontAwesomeIcons.userFriends,
          color: Colors.lightBlue, size: 30); // Changed icon to userFriends
      backgroundColor = Colors.lightBlue.shade100;
    } else if (item['eng_name'].toLowerCase().contains("work")) {
      leadingIcon = FaIcon(FontAwesomeIcons.briefcase,
          color: Colors.purple, size: 30); // Changed icon to briefcase
      backgroundColor = Colors.purpleAccent.shade100;
    } else if (item['eng_name'].toLowerCase().contains("hobby")) {
      leadingIcon = FaIcon(FontAwesomeIcons.paintBrush,
          color: Colors.teal, size: 30); // Changed icon to paintBrush
      backgroundColor = Colors.teal.shade100;
    } else if (item['eng_name'].toLowerCase().contains("original")) {
      leadingIcon = FaIcon(FontAwesomeIcons.cogs,
          color: Colors.red, size: 30); // Changed icon to cogs
      backgroundColor = Colors.redAccent.shade100;
    } else if (item['eng_name'].toLowerCase().contains("family")) {
      leadingIcon = FaIcon(FontAwesomeIcons.users,
          color: Colors.green, size: 30); // Changed icon to users
      backgroundColor = const Color.fromARGB(255, 151, 231, 155);
    } else if (item['eng_name'].toLowerCase().contains("classmates")) {
      leadingIcon = FaIcon(FontAwesomeIcons.graduationCap,
          color: Colors.yellow, size: 30); // Changed icon to graduationCap
      backgroundColor = Colors.yellowAccent.shade100;
    } else if (item['eng_name'].toLowerCase().contains("major")) {
      leadingIcon = FaIcon(FontAwesomeIcons.laptopCode,
          color: Colors.orange, size: 30); // Changed icon to laptopCode
      backgroundColor = Colors.orange.shade100;
    } else if (item['eng_name'].toLowerCase().contains("parents")) {
      leadingIcon = FaIcon(FontAwesomeIcons.child,
          color: Colors.blue, size: 30); // Changed icon to child
      backgroundColor = Colors.white;
    } else {
      leadingIcon = FaIcon(FontAwesomeIcons.heart,
          color: Colors.teal, size: 30); // Changed icon to sports
      backgroundColor = Colors.tealAccent;
    }

    return Card(
      color: backgroundColor,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThirdPage(playerName: displayName),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(children: [
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.0),
                child: leadingIcon,
              ),
            ])
          ],
        ),
      ),
    );
  }
}
