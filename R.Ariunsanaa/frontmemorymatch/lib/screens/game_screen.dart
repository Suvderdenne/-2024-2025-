class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final ApiService _apiService = ApiService();
  List<Game> games = [];

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    try {
      final loadedGames = await _apiService.getGames();
      setState(() {
        games = loadedGames;
      });
    } catch (e) {
      print('Error loading games: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return ListTile(
          title: Text('Player: ${game.playerName}'),
          subtitle: Text('Score: ${game.score}'),
        );
      },
    );
  }
} 