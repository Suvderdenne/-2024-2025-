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
          backgroundColor: Colors.black,
          elevation: 0,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Хүснэгт'),
              Tab(text: 'Тоглогчдын үзүүлэлт'),
            ],
            indicatorColor: Colors.purple,
          ),
        ),
        body: TabBarView(
          children: [
            StandingsTab(),
            PlayerStatsTab(),
          ],
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.black,
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.black,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.white,
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
              BottomNavigationBarItem(icon: Icon(Icons.sports_volleyball), label: 'Тоглолт'),
              BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Бусад'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Хэрэглэгч'),
            ],
          ),
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
      
      print('Fetched teams: ${teams.length}');
      print('Fetched team stats: ${teamStats.length}');
      
      // Create default stats for teams that don't have stats
      final Map<String, dynamic> teamStatsMap = {};
      for (var stat in teamStats) {
        teamStatsMap[stat['team']['id'].toString()] = stat;
      }

      final List<dynamic> allTeamStats = teams.map((team) {
        final teamId = team['id'].toString();
        if (teamStatsMap.containsKey(teamId)) {
          return teamStatsMap[teamId];
        } else {
          // Create default stats for teams without stats
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
      
      print('Male teams: ${_maleTeams.length}');
      print('Female teams: ${_femaleTeams.length}');
    } catch (e) {
      print('Error loading team stats: $e');
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
          color: Colors.black,
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
                  'ЭРЭГТЭЙ',
                  style: TextStyle(
                    color: isMaleSelected ? Colors.blue : Colors.white,
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
                  'ЭМЭГТЭЙ',
                  style: TextStyle(
                    color: !isMaleSelected ? Colors.blue : Colors.white,
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
                  itemCount: isMaleSelected ? _maleTeams.length : _femaleTeams.length,
                  itemBuilder: (context, index) {
                    final team = isMaleSelected ? _maleTeams[index] : _femaleTeams[index];
                    return TeamStandingRow(
                      rank: (index + 1).toString(),
                      teamLogo: team['team']['photo'] ?? 'default_team.png',
                      teamName: team['team']['name'] ?? '',
                      W: team['wins'].toString(),
                      L: team['losses'].toString(),
                      PTS: (team['wins'] * 3).toString(),
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
  final String PTS;
  final String teamId;
  final String gender;

  TeamStandingRow({
    required this.rank,
    required this.teamLogo,
    required this.teamName,
    required this.W,
    required this.L,
    required this.PTS,
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade800, width: 0.5)),
        ),
        child: Row(
          children: [
            SizedBox(width: 30, child: Text(rank)),
            SizedBox(
              width: 30,
              height: 30,
              child: teamLogo.startsWith('http')
                  ? Image.network(
                      teamLogo,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.sports_basketball, color: Colors.white, size: 20),
                        );
                      },
                    )
                  : Image.asset(
                      teamLogo,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.sports_basketball, color: Colors.white, size: 20),
                        );
                      },
                    ),
            ),
            SizedBox(width: 8),
            SizedBox(width: 100, child: Text(teamName)),
            Spacer(),
            Row(
              children: [
                SizedBox(width: 50, child: Text(W)),
                SizedBox(width: 50, child: Text(L)),
                SizedBox(width: 50, child: Text(PTS)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PlayerStatsTab extends StatefulWidget {
  @override
  _PlayerStatsTabState createState() => _PlayerStatsTabState();
}

class _PlayerStatsTabState extends State<PlayerStatsTab> {
  bool isMaleSelected = true;
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
      print('Error loading player stats: $e');
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
          color: Colors.black,
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
                  'ЭРЭГТЭЙ',
                  style: TextStyle(
                    color: isMaleSelected ? Colors.blue : Colors.white,
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
                  'ЭМЭГТЭЙ',
                  style: TextStyle(
                    color: !isMaleSelected ? Colors.blue : Colors.white,
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
                  itemCount: _playerStats.length,
                  itemBuilder: (context, index) {
                    final stat = _playerStats[index];
                    final player = stat['player'];
                    if (player['team']['gender'] != (isMaleSelected ? 'male' : 'female')) {
                      return SizedBox.shrink();
                    }
                    return PlayerStatsRow(
                      playerName: '${player['first_name']} ${player['last_name']}',
                      teamName: player['team']['name'],
                      gamesPlayed: stat['games_played'].toString(),
                      avgPoints: stat['average_points'].toStringAsFixed(1),
                      avgAssists: stat['average_assists'].toStringAsFixed(1),
                      avgBlocks: stat['average_blocks'].toStringAsFixed(1),
                      avgAces: stat['average_aces'].toStringAsFixed(1),
                      playerPhoto: player['photo'] ?? 'default_player.png',
                    );
                  },
                ),
        ),
      ],
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
  final String avgAces;
  final String playerPhoto;

  PlayerStatsRow({
    required this.playerName,
    required this.teamName,
    required this.gamesPlayed,
    required this.avgPoints,
    required this.avgAssists,
    required this.avgBlocks,
    required this.avgAces,
    required this.playerPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade800, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: playerPhoto.startsWith('http')
                      ? Image.network(
                          playerPhoto,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.person, color: Colors.white, size: 20),
                            );
                          },
                        )
                      : Image.asset(
                          playerPhoto,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.person, color: Colors.white, size: 20),
                            );
                          },
                        ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playerName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      teamName,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatColumn('Тоглолт', gamesPlayed),
              _buildStatColumn('Оноо', avgPoints),
              _buildStatColumn('Дамжуулалт', avgAssists),
              _buildStatColumn('Блок', avgBlocks),
              _buildStatColumn('Эйс', avgAces),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}