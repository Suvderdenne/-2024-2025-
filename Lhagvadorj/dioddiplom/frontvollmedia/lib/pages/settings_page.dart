import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = true;
  bool _isNotificationsEnabled = true;
  String _language = 'Монгол';
  String _selectedTheme = 'Хар';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
      _isNotificationsEnabled = prefs.getBool('isNotificationsEnabled') ?? true;
      _language = prefs.getString('language') ?? 'Монгол';
      _selectedTheme = prefs.getString('theme') ?? 'Хар';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('isNotificationsEnabled', _isNotificationsEnabled);
    await prefs.setString('language', _language);
    await prefs.setString('theme', _selectedTheme);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Тохиргоо'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSection(
            'Харагдац',
            [
              SwitchListTile(
                title: Text('Хар темийн горим'),
                subtitle: Text('Хар өнгөтэй интерфейс'),
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                  _saveSettings();
                },
              ),
              ListTile(
                title: Text('Өнгөний сонголт'),
                subtitle: Text(_selectedTheme),
                trailing: DropdownButton<String>(
                  value: _selectedTheme,
                  items: ['Хар', 'Цэнхэр', 'Ногоон'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedTheme = newValue;
                      });
                      _saveSettings();
                    }
                  },
                ),
              ),
            ],
          ),
          _buildSection(
            'Хэл',
            [
              ListTile(
                title: Text('Хэл сонгох'),
                subtitle: Text(_language),
                trailing: DropdownButton<String>(
                  value: _language,
                  items: ['Монгол', 'English'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _language = newValue;
                      });
                      _saveSettings();
                    }
                  },
                ),
              ),
            ],
          ),
          _buildSection(
            'Мэдэгдэл',
            [
              SwitchListTile(
                title: Text('Мэдэгдэл идэвхжүүлэх'),
                subtitle: Text('Тоглолтын мэдэгдэл'),
                value: _isNotificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _isNotificationsEnabled = value;
                  });
                  _saveSettings();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
        ),
        ...children,
        Divider(color: Colors.grey[800]),
      ],
    );
  }
} 