import 'package:flutter/material.dart';
import 'game_page.dart';
import '../services/api_service.dart';
import 'team_details_page.dart';

class StandingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Хүснэгт'),
              Tab(text: 'Тоглогчдын үзүүлэлт'),
            ],
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey[500],
          ),
        ),
        body: TabBarView(
          children: [
            StandingsTab(),
            PlayerStatsTab(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey[500],
          currentIndex: 2,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacementNamed(context, '/');
            } else if (index == 1) {
              Navigator.pushReplacementNamed(context, '/matches');
            } else if (index == 2) {
              // Already on StandingsPage
            } else if (index == 3) {
              Navigator.pushReplacementNamed(context, '/profile');
            }
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Мэдээ'),
            BottomNavigationBarItem(icon: Icon(Icons.sports_basketball), label: 'Тоглолт'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Бусад'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Хэрэглэгч'),
          ],
        ),
      ),
    );
  }
}

class StandingsTab extends StatefulWidget {
  @override
  _StandingsTabState createState() => _StandingsTabState();
}

class _StandingsTabState extends State<StandingsTab> {
  bool isMaleSelected = true;
  final _apiService = ApiService();
  List<dynamic> _maleTeams = [];
  List<dynamic> _femaleTeams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeamStats();
  }

  Future<void> _loadTeamStats() async {
    try {
      final teams = await _apiService.fetchTeams();
      final teamStats = await _apiService.fetchTeamStats();

      final Map<String, dynamic> teamStatsMap = {};
      for (var stat in teamStats) {
        teamStatsMap[stat['team']['id'].toString()] = stat;
      }

      final List<dynamic> allTeamStats = teams.map((team) {
        final teamId = team['id'].toString();
        if (teamStatsMap.containsKey(teamId)) {
          return teamStatsMap[teamId];
        } else {
          return {
            'team': team,
            'wins': 0,
            'losses': 0,
          };
        }
      }).toList();

      setState(() {
        _maleTeams = allTeamStats.where((stat) => stat['team']['gender'] == 'male').toList();
        _femaleTeams = allTeamStats.where((stat) => stat['team']['gender'] == 'female').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Өгөгдөл ачаалахад алдаа гарлаа: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isMaleSelected = true;
                  });
                },
                child: Text(
                  'Дорнод',
                  style: TextStyle(
                    color: isMaleSelected ? Colors.blueAccent : Colors.grey[600],
                    fontWeight: isMaleSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isMaleSelected = false;
                  });
                },
                child: Text(
                  'Өрнөд',
                  style: TextStyle(
                    color: !isMaleSelected ? Colors.blueAccent : Colors.grey[600],
                    fontWeight: !isMaleSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
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
                  itemCount: isMaleSelected ? _maleTeams.length : _femaleTeams.length,
                  itemBuilder: (context, index) {
                    final team = isMaleSelected ? _maleTeams[index] : _femaleTeams[index];
                    return TeamStandingRow(
                      rank: (index + 1).toString(),
                      teamLogo: team['team']['photo'] ?? 'default_team.png',
                      teamName: team['team']['name'] ?? '',
                      W: team['wins'].toString(),
                      L: team['losses'].toString(),
                      teamId: team['team']['id'].toString(),
                      gender: team['team']['gender'],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class TeamStandingRow extends StatelessWidget {
  final String rank;
  final String teamLogo;
  final String teamName;
  final String W;
  final String L;
  final String teamId;
  final String gender;

  TeamStandingRow({
    required this.rank,
    required this.teamLogo,
    required this.teamName,
    required this.W,
    required this.L,
    required this.teamId,
    required this.gender,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeamDetailsPage(
              teamId: teamId,
              teamName: teamName,
              teamLogo: teamLogo,
              gender: gender,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.07),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.blueAccent.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              alignment: Alignment.center,
              child: Text(
                rank,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(
              width: 38,
              height: 38,
              child: ClipOval(
                child: teamLogo.startsWith('http')
                    ? Image.network(
                        teamLogo,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.sports_basketball, color: Colors.blueAccent, size: 22),
                          );
                        },
                      )
                    : Image.asset(
                        teamLogo,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.sports_basketball, color: Colors.blueAccent, size: 22),
                          );
                        },
                      ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                teamName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8),
            _buildStatBox('W', W, Colors.green),
            SizedBox(width: 6),
            _buildStatBox('L', L, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      width: 38,
      padding: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 15,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class PlayerStatsTab extends StatefulWidget {
  @override
  _PlayerStatsTabState createState() => _PlayerStatsTabState();
}

class _PlayerStatsTabState extends State<PlayerStatsTab> {
  final _apiService = ApiService();
  List<dynamic> _playerStats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayerStats();
  }

  Future<void> _loadPlayerStats() async {
    try {
      final stats = await _apiService.fetchPlayerSeasonStats();
      setState(() {
        _playerStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Өгөгдөл ачаалахад алдаа гарлаа: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _playerStats.length,
            itemBuilder: (context, index) {
              final stat = _playerStats[index];
              final player = stat['player'];
              return PlayerStatsRow(
                playerName: '${player['first_name']} ${player['last_name']}',
                teamName: player['team']['name'],
                gamesPlayed: stat['games_played'].toString(),
                avgPoints: stat['average_points'].toStringAsFixed(1),
                avgAssists: stat['average_assists'].toStringAsFixed(1),
                avgBlocks: stat['average_blocks'].toStringAsFixed(1),
                playerPhoto: player['photo'] ?? 'default_player.png',
              );
            },
          );
  }
}

class PlayerStatsRow extends StatelessWidget {
  final String playerName;
  final String teamName;
  final String gamesPlayed;
  final String avgPoints;
  final String avgAssists;
  final String avgBlocks;
  final String playerPhoto;

  PlayerStatsRow({
    required this.playerName,
    required this.teamName,
    required this.gamesPlayed,
    required this.avgPoints,
    required this.avgAssists,
    required this.avgBlocks,
    required this.playerPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.07),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.blueAccent.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: playerPhoto.startsWith('http')
                      ? Image.network(
                          playerPhoto,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Icon(Icons.person, color: Colors.blueAccent, size: 24),
                            );
                          },
                        )
                      : Image.asset(
                          playerPhoto,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Icon(Icons.person, color: Colors.blueAccent, size: 24),
                            );
                          },
                        ),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playerName,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                    ),
                    Text(
                      teamName,
                      style: TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatColumn('Тоглолт', gamesPlayed, Colors.blueAccent),
              _buildStatColumn('Оноо', avgPoints, Colors.green),
              _buildStatColumn('Дамжуулалт', avgAssists, Colors.orange),
              _buildStatColumn('Блок', avgBlocks, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color.withOpacity(0.7), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}