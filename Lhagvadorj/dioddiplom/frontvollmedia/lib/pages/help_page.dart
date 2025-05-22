import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatelessWidget {
  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@example.com',
      queryParameters: {
        'subject': 'Volleyball App Support',
        'body': 'I need help with the Volleyball App',
      },
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneLaunchUri = Uri(
      scheme: 'tel',
      path: '+1234567890',
    );
    if (await canLaunchUrl(phoneLaunchUri)) {
      await launchUrl(phoneLaunchUri);
    }
  }

  Future<void> _launchMaps() async {
    final Uri mapsLaunchUri = Uri(
      scheme: 'geo',
      host: '0,0',
      queryParameters: {
        'q': '123 Main St, City, Country',
      },
    );
    if (await canLaunchUrl(mapsLaunchUri)) {
      await launchUrl(mapsLaunchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Тусламж',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSection(
            'Түгээмэл асуултууд',
            [
              _buildFAQItem(
                'Тоглолтын мэдээллийг хэрхэн харах вэ?',
                'Тоглолтын хуудсанд орж, хүссэн өдрийн тоглолтуудыг харах боломжтой.',
              ),
              _buildFAQItem(
                'Багын мэдээллийг хэрхэн харах вэ?',
                'Тоглолтын жагсаалтаас багийн нэр дээр дараж, дэлгэрэнгүй мэдээллийг харах боломжтой.',
              ),
              _buildFAQItem(
                'Тоглогчийн мэдээллийг хэрхэн харах вэ?',
                'Багын дэлгэрэнгүй мэдээллээс тоглогчийн жагсаалтыг харах боломжтой.',
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildSection(
            'Холбоо барих',
            [
              ListTile(
                leading: Icon(Icons.email, color: Colors.blue),
                title: Text('И-мэйл', style: TextStyle(color: Colors.white)),
                subtitle: Text('support@example.com', style: TextStyle(color: Colors.grey)),
                onTap: _launchEmail,
              ),
              ListTile(
                leading: Icon(Icons.phone, color: Colors.blue),
                title: Text('Утас', style: TextStyle(color: Colors.white)),
                subtitle: Text('+1234567890', style: TextStyle(color: Colors.grey)),
                onTap: _launchPhone,
              ),
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.blue),
                title: Text('Хаяг', style: TextStyle(color: Colors.white)),
                subtitle: Text('123 Main St, City, Country', style: TextStyle(color: Colors.grey)),
                onTap: _launchMaps,
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildSection(
            'Хувилбар',
            [
              ListTile(
                leading: Icon(Icons.info, color: Colors.blue),
                title: Text('Одоогийн хувилбар', style: TextStyle(color: Colors.white)),
                subtitle: Text('1.0.0', style: TextStyle(color: Colors.grey)),
              ),
              ListTile(
                leading: Icon(Icons.update, color: Colors.blue),
                title: Text('Сүүлд шинэчилсэн', style: TextStyle(color: Colors.white)),
                subtitle: Text('2024-03-20', style: TextStyle(color: Colors.grey)),
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
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            answer,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
} 