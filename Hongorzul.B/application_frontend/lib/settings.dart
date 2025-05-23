import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  String _selectedLanguage =
      'English'; // Default value should be in the _languages list.

  // Language list updated to match the available options.
  final List<String> _languages = [
    'English',
    'Mongolian'
  ]; // Corrected language names.

  final Color primaryAccent = const Color.fromARGB(255, 218, 175, 249);

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _selectedLanguage = prefs.getString('language') ??
          'English'; // Default language should match the list
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    await prefs.setString('language', _selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = _isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _buildHeaderContainer(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSectionTitle('Өнгө'),
                _buildCard(child: _buildDarkModeToggle()),
                const SizedBox(height: 20),
                _buildSectionTitle('Хэл'),
                _buildCard(
                    child: _buildLanguageSelector()), // Corrected section title
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderContainer() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: primaryAccent,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 25,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 15),
              child: Text(
                'Тохиргоо',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: _isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 6,
      shadowColor: _isDarkMode ? Colors.grey[800] : Colors.grey[300],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: _isDarkMode ? Colors.grey[850] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: child,
      ),
    );
  }

  Widget _buildDarkModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('харанхуй горим', style: TextStyle(fontSize: 18)),
        FlutterSwitch(
          width: 55,
          height: 30,
          toggleSize: 20,
          value: _isDarkMode,
          activeColor: primaryAccent,
          inactiveColor: Colors.grey,
          onToggle: (val) {
            setState(() {
              _isDarkMode = val;
            });
            _savePreferences();
          },
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedLanguage,
      decoration: InputDecoration(
        filled: true,
        fillColor: _isDarkMode ? Colors.grey[700] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelText: 'Хэл сонгох',
        labelStyle: TextStyle(
          color: _isDarkMode ? Colors.white70 : Colors.black87,
        ),
      ),
      dropdownColor: _isDarkMode ? Colors.grey[850] : Colors.white,
      style: TextStyle(
        color: _isDarkMode ? Colors.white : Colors.black,
      ),
      items: _languages.map((String lang) {
        return DropdownMenuItem<String>(
          value: lang,
          child: Text(lang),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedLanguage = value!;
        });
        _savePreferences();
      },
    );
  }
}
