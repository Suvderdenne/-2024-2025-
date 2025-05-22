import 'package:flutter/material.dart';
import 'package:frontvollmedia/services/api_service.dart';

class TeamPlayersPage extends StatefulWidget {
  final int teamId;
  final String teamName;
  final String teamLogo;

  TeamPlayersPage({
    required this.teamId,
    required this.teamName,
    required this.teamLogo,
  });

  @override
  _TeamPlayersPageState createState() => _TeamPlayersPageState();
}

class _TeamPlayersPageState extends State<TeamPlayersPage> {
  final _apiService = ApiService();
  List<dynamic> _players = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    try {
      final players = await _apiService.fetchPlayers();
      setState(() {
        _players = players.where((player) => player['team']['id'] == widget.teamId).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Тоглогчдын мэдээлэл ачаалахад алдаа гарлаа'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teamName),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _players.length,
              itemBuilder: (context, index) {
                final player = _players[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  color: Colors.grey[850],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: player['photo'] != null
                          ? NetworkImage(player['photo'])
                          : null,
                      child: player['photo'] == null
                          ? Icon(Icons.person, size: 30, color: Colors.white)
                          : null,
                    ),
                    title: Text(
                      '${player['first_name']} ${player['last_name']}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          player['position'] ?? 'Тодорхойгүй',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.height, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              '${player['height']} см',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(width: 16),
                            Icon(Icons.monitor_weight, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              '${player['weight']} кг',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
} 