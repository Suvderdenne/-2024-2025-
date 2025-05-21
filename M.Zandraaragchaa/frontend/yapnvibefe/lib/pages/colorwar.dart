import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

class Cell {
  int count = 0;
  int? player;
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final int rows = 6;
  final int cols = 6;
  late List<List<Cell>> grid;
  int currentPlayer = 0;
  final int numPlayers = 4;
  bool gameStarted = false;
  List<bool> hasMadeFirstMove = [];
  late List<Color> playerColors;
  late List<Color> softColors;
  Timer? _longPressTimer;
  double _iconSize = 40;
  List<int> playerWins = [];

  @override
  void initState() {
    super.initState();
    playerColors = [Colors.red, Colors.yellow, Colors.blue, Colors.green];
    softColors = [
      Colors.red.shade100,
      Colors.yellow.shade200,
      Colors.blue.shade100,
      Colors.green.shade100
    ];
    playerWins = List.generate(numPlayers, (_) => 0);
    resetGame();
  }

  void resetGame() {
    grid = List.generate(rows, (_) => List.generate(cols, (_) => Cell()));
    currentPlayer = 0;
    gameStarted = false;
    hasMadeFirstMove = List.generate(numPlayers, (_) => false);
    setState(() {});
  }

  void playMove(int row, int col) {
    Cell cell = grid[row][col];

    if (!hasMadeFirstMove[currentPlayer]) {
      if (cell.player != null && cell.player != currentPlayer) return;
    } else {
      if (cell.player != currentPlayer) return;
    }

    if (!hasMadeFirstMove[currentPlayer]) {
      hasMadeFirstMove[currentPlayer] = true;
    }

    gameStarted = true;

    cell.count++;
    cell.player = currentPlayer;

    if (cell.count > 3) {
      processExplosions(row, col, currentPlayer);
    } else {
      nextPlayer();
    }

    setState(() {});
  }

  void processExplosions(int row, int col, int owner) async {
    List<List<int>> explosionQueue = [
      [row, col]
    ];

    while (explosionQueue.isNotEmpty) {
      await Future.delayed(Duration(milliseconds: 200));

      List<List<int>> nextQueue = [];

      for (var pos in explosionQueue) {
        int r = pos[0], c = pos[1];
        if (grid[r][c].count <= 3) continue;

        grid[r][c].count = 0;
        grid[r][c].player = null;

        List<List<int>> dirs = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1]
        ];

        for (var d in dirs) {
          int nr = r + d[0];
          int nc = c + d[1];
          if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
            Cell neighbor = grid[nr][nc];
            neighbor.count++;
            neighbor.player = owner;
            if (neighbor.count > 3) {
              nextQueue.add([nr, nc]);
            }
          }
        }
      }

      explosionQueue = nextQueue;
      setState(() {});
    }

    checkWinner();
    nextPlayer();
  }

  void nextPlayer() {
    int checked = 0;
    do {
      currentPlayer = (currentPlayer + 1) % numPlayers;
      checked++;
    } while (gameStarted &&
        !hasCells(currentPlayer) &&
        hasMadeFirstMove[currentPlayer] &&
        checked < numPlayers);
  }

  bool hasCells(int player) {
    for (var row in grid) {
      for (var cell in row) {
        if (cell.player == player) return true;
      }
    }
    return false;
  }

  void checkWinner() {
    Set<int> remaining = {};
    for (var row in grid) {
      for (var cell in row) {
        if (cell.player != null) {
          remaining.add(cell.player!);
        }
      }
    }

    if (remaining.length == 1 && gameStarted) {
      int winner = remaining.first;
      playerWins[winner]++;
      showWinnerScreen(winner);
    }
  }

  void showWinnerScreen(int winner) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Winner",
      transitionDuration: Duration(milliseconds: 800),
      pageBuilder: (_, __, ___) {
        return AnimatedWinnerScreen(
          color: playerColors[winner],
          message: "Congratulations!",
          onFinish: () {
            Navigator.of(context).pop();
            resetGame();
          },
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return FadeTransition(opacity: anim, child: child);
      },
    );
  }

  int countBoxes(int player) {
    int count = 0;
    for (var row in grid) {
      for (var cell in row) {
        if (cell.player == player) count++;
      }
    }
    return count;
  }

  Widget _buildCornerCircle(int playerIndex) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipOval(
          child: Container(
            width: 100,
            height: 100,
            color: playerColors[playerIndex],
          ),
        ),
        Transform.rotate(
          angle: playerIndex == 0 || playerIndex == 1 ? 3.1415 : 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${playerWins[playerIndex]} - ${countBoxes(playerIndex)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCell(Cell cell, int row, int col) {
    Color? cellColor = cell.player != null ? playerColors[cell.player!] : null;

    return GestureDetector(
      onTap: () => playMove(row, col),
      child: Container(
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black12),
        ),
        child: Center(
          child: cell.count > 0
              ? Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cellColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        cell.count.clamp(1, 4),
                        (_) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softColors[currentPlayer],
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                    ),
                    itemCount: rows * cols,
                    itemBuilder: (context, index) {
                      int row = index ~/ cols;
                      int col = index % cols;
                      return buildCell(grid[row][col], row, col);
                    },
                  ),
                ),
              ),
            ),
            Positioned(top: -20, left: -20, child: _buildCornerCircle(0)),
            Positioned(top: -20, right: -20, child: _buildCornerCircle(1)),
            Positioned(bottom: -20, left: -20, child: _buildCornerCircle(3)),
            Positioned(bottom: -20, right: -20, child: _buildCornerCircle(2)),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: GestureDetector(
                  onLongPressStart: (_) {
                    setState(() => _iconSize = 60);
                    _longPressTimer = Timer(Duration(seconds: 3), () {
                      resetGame();
                      setState(() => _iconSize = 40);
                    });
                  },
                  onLongPressEnd: (_) {
                    _longPressTimer?.cancel();
                    setState(() => _iconSize = 40);
                  },
                  child: Icon(
                    Icons.refresh,
                    color: Colors.black87,
                    size: _iconSize,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AnimatedWinnerScreen extends StatefulWidget {
  final Color color;
  final String message;
  final VoidCallback onFinish;

  const AnimatedWinnerScreen({
    required this.color,
    required this.message,
    required this.onFinish,
  });

  @override
  _AnimatedWinnerScreenState createState() => _AnimatedWinnerScreenState();
}

class _AnimatedWinnerScreenState extends State<AnimatedWinnerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    _animation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();

    Future.delayed(Duration(seconds: 3), widget.onFinish);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: Container(color: widget.color),
            );
          },
        ),
        Center(
          child: FadeTransition(
            opacity: _controller,
            child: Text(
              widget.message,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }
}
