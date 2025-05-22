import 'package:flutter/material.dart';
import 'package:frontvollmedia/pages/standings_page.dart';
import 'package:frontvollmedia/pages/profile_page.dart';
import 'package:frontvollmedia/pages/team_players_page.dart';
import 'package:frontvollmedia/services/api_service.dart';
import 'package:frontvollmedia/pages/settings_page.dart';
import 'package:frontvollmedia/pages/notifications_page.dart';
import 'package:frontvollmedia/pages/help_page.dart';
import 'package:frontvollmedia/pages/version_page.dart';

class MatchesPage extends StatefulWidget {
  @override
  _MatchesPageState createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  DateTime selectedDate = DateTime.now();
  int _selectedIndex = 1;
  final _apiService = ApiService();
  List<dynamic> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    try {
      final games = await _apiService.fetchGames();
      setState(() {
        _games = games.where((game) {
          final gameDate = DateTime.parse(game['date']);
          return gameDate.year == selectedDate.year &&
              gameDate.month == selectedDate.month &&
              gameDate.day == selectedDate.day;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Тоглолтын мэдээлэл ачаалахад алдаа гарлаа'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
      _isLoading = true;
    });
    _loadGames();
  }

  void _changeMonth(int offset) {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + offset, 1);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/');
    } else if (index == 1) {
      // Already on MatchesPage
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/standings');
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  void _showTeamPlayers(Map<String, dynamic> team) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamPlayersPage(
          teamId: team['id'],
          teamName: team['name'] ?? 'Баг',
          teamLogo: team['photo'] ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentMonth = selectedDate.month;
    final currentYear = selectedDate.year;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Тоглолт',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.06),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.blueAccent),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${currentYear}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    itemCount: 14,
                    itemBuilder: (context, index) {
                      final date = DateTime.now().subtract(Duration(days: 7)).add(Duration(days: index));
                      final isSelected = date.year == selectedDate.year &&
                          date.month == selectedDate.month &&
                          date.day == selectedDate.day;

                      return GestureDetector(
                        onTap: () => _selectDate(date),
                        child: Container(
                          width: 50,
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blueAccent : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.blueAccent.withOpacity(0.18),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                ['Дав', 'Мяг', 'Лха', 'Пүр', 'Баа', 'Бям', 'Ням'][date.weekday - 1],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? Colors.white : Colors.blueAccent,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${date.month}/${date.day}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSelected ? Colors.white : Colors.blueAccent,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    itemCount: _games.length,
                    itemBuilder: (context, index) {
                      final game = _games[index];
                      final homeTeam = game['team1'] ?? {};
                      final awayTeam = game['team2'] ?? {};

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: Row(
                            children: [
                              // Home team
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () => _showTeamPlayers(homeTeam),
                                    child: CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.blueAccent.withOpacity(0.08),
                                      backgroundImage: (homeTeam['photo'] != null && homeTeam['photo'].toString().isNotEmpty)
                                          ? NetworkImage(homeTeam['photo'])
                                          : null,
                                      child: (homeTeam['photo'] == null || homeTeam['photo'].toString().isEmpty)
                                          ? Icon(Icons.sports_basketball, color: Colors.blueAccent, size: 28)
                                          : null,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                      homeTeam['name'] ?? 'Баг',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              // Score
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          game['score_team1']?.toString() ?? '0',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8),
                                          child: Text(
                                            '-',
                                            style: TextStyle(
                                              fontSize: 28,
                                              color: Colors.grey[500],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          game['score_team2']?.toString() ?? '0',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: game['is_finished'] ? Colors.redAccent.withOpacity(0.08) : Colors.blueAccent.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        game['is_finished'] ? 'Дууссан' : (game['start_time'] ?? ''),
                                        style: TextStyle(
                                          color: game['is_finished'] ? Colors.redAccent : Colors.blueAccent,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Away team
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () => _showTeamPlayers(awayTeam),
                                    child: CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.redAccent.withOpacity(0.08),
                                      backgroundImage: (awayTeam['photo'] != null && awayTeam['photo'].toString().isNotEmpty)
                                          ? NetworkImage(awayTeam['photo'])
                                          : null,
                                      child: (awayTeam['photo'] == null || awayTeam['photo'].toString().isEmpty)
                                          ? Icon(Icons.sports_basketball, color: Colors.redAccent, size: 28)
                                          : null,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                      awayTeam['name'] ?? 'Баг',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey[500],
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Мэдээ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_basketball),
            label: 'Тоглолт',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Бусад',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Хэрэглэгч',
          ),
        ],
      ),
    );
  }
}