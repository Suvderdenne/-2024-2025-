import 'package:flutter/material.dart';
import 'package:frontvollmedia/pages/standings_page.dart';
import 'package:frontvollmedia/pages/profile_page.dart';
import 'package:frontvollmedia/pages/team_players_page.dart';
import 'package:frontvollmedia/services/api_service.dart';
import 'package:frontvollmedia/pages/settings_page.dart';
import 'package:frontvollmedia/pages/notifications_page.dart';
import 'package:frontvollmedia/pages/help_page.dart';
import 'package:frontvollmedia/pages/version_page.dart';

void main() {
  runApp(VolleyballApp());
}

class VolleyballApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volleyball App',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: MatchesPage(),
    );
  }
}

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
        // Filter games for the selected date
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
    _loadGames(); // Reload games when date is selected
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
    
    // Generate dates for 6 months before and 6 months after current month
    final allDates = <Map<String, dynamic>>[];
    for (int monthOffset = -6; monthOffset <= 6; monthOffset++) {
      final date = DateTime(currentYear, currentMonth + monthOffset, 1);
      final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
      
      for (int day = 1; day <= daysInMonth; day++) {
        final currentDate = DateTime(date.year, date.month, day);
        allDates.add({
          'date': currentDate,
          'isCurrentMonth': monthOffset == 0,
          'isPastMonth': monthOffset < 0,
          'isFutureMonth': monthOffset > 0,
        });
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Тоглолт',
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
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${currentYear}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
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
                    itemCount: 14, // Show 14 days (7 days before and 7 days after today)
                    itemBuilder: (context, index) {
                      // Calculate date: 7 days before today + index
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
                            color: isSelected ? Colors.blue : Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ] : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                ['Дав', 'Мяг', 'Лха', 'Пүр', 'Баа', 'Бям', 'Ням'][date.weekday - 1],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? Colors.white : Colors.grey[400],
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${date.month}/${date.day}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isSelected ? Colors.white : Colors.white,
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
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: _games.length,
                    itemBuilder: (context, index) {
                      final game = _games[index];
                      final homeTeam = game['team1'] ?? {};
                      final awayTeam = game['team2'] ?? {};
                      
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        color: Colors.grey[850],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () => _showTeamPlayers(homeTeam),
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Image.network(
                                        homeTeam['photo'] ?? '',
                                        height: 40,
                                        width: 40,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(Icons.sports_basketball, color: Colors.white, size: 40);
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () => _showTeamPlayers(awayTeam),
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Image.network(
                                        awayTeam['photo'] ?? '',
                                        height: 40,
                                        width: 40,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(Icons.sports_basketball, color: Colors.white, size: 40);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    homeTeam['name'] ?? 'Unknown Team',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    awayTeam['name'] ?? 'Unknown Team',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    game['score_team1']?.toString() ?? '0',
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    game['score_team2']?.toString() ?? '0',
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  game['is_finished'] ? 'дууссан' : '${game['start_time']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[300],
                                    fontWeight: FontWeight.w500,
                                  ),
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Мэдээ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_volleyball),
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
