import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Мэдэгдэл'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: 10, // Example count
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[850],
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.2),
                child: Icon(
                  Icons.sports_volleyball,
                  color: Colors.blue,
                ),
              ),
              title: Text(
                'Шинэ тоглолт нэмэгдлээ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Team A vs Team B',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  Text(
                    '2024-04-${index + 1}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              trailing: Text(
                '${index + 1} цаг',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              onTap: () {
                // Handle notification tap
              },
            ),
          );
        },
      ),
    );
  }
} 