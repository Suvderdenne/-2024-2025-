// game_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/auth_provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final level = ModalRoute.of(context)?.settings.arguments as int?;
      if (level != null) {
        Provider.of<GameProvider>(
          context,
          listen: false,
        ).initGame(level, context).catchError((error) {
          // Handle error, perhaps show a snackbar or dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error initializing game: $error")),
          );
          Navigator.pop(context); // Go back to level select
        });
      } else {
        Navigator.pop(context); // Go back to level select if no level provided
      }
    });
  }

  void _showLevelCompleteDialog(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Level Completed!'),
            content: const Text(
              'Congratulations! You have completed this level.',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Next Level'),
                onPressed: () {
                  Navigator.of(context).pop();
                  int nextLevel =
                      Provider.of<GameProvider>(
                        context,
                        listen: false,
                      ).currentLevel +
                      1;
                  if (nextLevel <= 18) {
                    // Or whatever your max level is
                    Navigator.pushReplacementNamed(
                      context,
                      '/game',
                      arguments: nextLevel,
                    );
                  } else {
                    // Handle all levels completed (e.g., go to a "You Win" screen)
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${gameProvider.currentLevel}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () {
              gameProvider.useHint(context);
            },
          ),
        ],
      ),
      body:
          gameProvider.gridSize == 0
              ? const Center(child: CircularProgressIndicator())
              : Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: gameProvider.gridSize,
                              ),
                          itemCount:
                              gameProvider.gridSize * gameProvider.gridSize,
                          itemBuilder: (context, index) {
                            final row = index ~/ gameProvider.gridSize;
                            final col = index % gameProvider.gridSize;
                            return GestureDetector(
                              onTap: () {
                                gameProvider.selectCell(row, col, context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      gameProvider.isSelected(row, col)
                                          ? Colors.amber.withOpacity(0.7)
                                          : Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    gameProvider.getCellLetter(row, col),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          gameProvider.isSelected(row, col)
                                              ? Colors.black
                                              : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                gameProvider.clearSelection();
                              },
                              child: const Text('Clear'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                gameProvider.submitWord(context);
                              },
                              child: const Text('Submit'),
                            ),
                          ],
                        ),
                      ),
                      if (gameProvider.levelCompleted) ...[
                        Builder(
                          builder: (context) {
                            _showLevelCompleteDialog(context);
                            return Container();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
    );
  }
}
