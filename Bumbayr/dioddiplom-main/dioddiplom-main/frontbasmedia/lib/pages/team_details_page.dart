import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TeamDetailsPage extends StatefulWidget {
  final String teamId;
  final String teamName;
  final String teamLogo;
  final String gender;

  TeamDetailsPage({
    required this.teamId,
    required this.teamName,
    required this.teamLogo,
    required this.gender,
  });

  @override
  _TeamDetailsPageState createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage> {
  final _apiService = ApiService();
  List<dynamic> _players = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeamPlayers();
  }

  Future<void> _loadTeamPlayers() async {
    try {
      final players = await _apiService.fetchPlayers();
      setState(() {
        _players = players.where((player) => player['team']['id'].toString() == widget.teamId).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Өгөгдөл ачаалахад алдаа гарлаа'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          widget.teamName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.06),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueAccent.withOpacity(0.08),
                            border: Border.all(color: Colors.blueAccent, width: 2),
                          ),
                          child: ClipOval(
                            child: widget.teamLogo.startsWith('http')
                                ? Image.network(
                                    widget.teamLogo,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.sports_basketball, color: Colors.blueAccent, size: 60);
                                    },
                                  )
                                : Image.asset(
                                    widget.teamLogo,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.sports_basketball, color: Colors.blueAccent, size: 60);
                                    },
                                  ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          widget.teamName,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.gender == 'male' ? 'Эрэгтэй баг' : 'Эмэгтэй баг',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Багийн тамирчид',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _players.length,
                          itemBuilder: (context, index) {
                            final player = _players[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 14),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.06),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blueAccent.withOpacity(0.08),
                                      border: Border.all(color: Colors.blueAccent, width: 1),
                                    ),
                                    child: ClipOval(
                                      child: player['photo'] != null && player['photo'].toString().isNotEmpty
                                          ? Image.network(
                                              player['photo'],
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Icon(Icons.person, color: Colors.blueAccent, size: 36);
                                              },
                                            )
                                          : Icon(Icons.person, color: Colors.blueAccent, size: 36),
                                    ),
                                  ),
                                  SizedBox(width: 18),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${player['first_name']} ${player['last_name']}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          '${player['position']}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.blueAccent,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(Icons.height, color: Colors.grey[500], size: 16),
                                            SizedBox(width: 4),
                                            Text(
                                              '${player['height']} см',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Icon(Icons.monitor_weight, color: Colors.grey[500], size: 16),
                                            SizedBox(width: 4),
                                            Text(
                                              '${player['weight']} кг',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}