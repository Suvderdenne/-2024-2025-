// level_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart'; // Import AuthProvider

class LevelScreen extends StatelessWidget {
  const LevelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final completedLevels = authProvider.completedLevels;

    return Scaffold(
      appBar: AppBar(title: const Text('Level')),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 18, // Total number of levels
        itemBuilder: (context, index) {
          final levelNumber = index + 1;
          final isLocked =
              levelNumber > 1 && !completedLevels.contains(levelNumber - 1);

          return ElevatedButton(
            onPressed:
                isLocked
                    ? null
                    : () {
                      // Disable button if locked
                      // Navigate to the GameScreen with the level number
                      Navigator.pushNamed(
                        context,
                        '/game',
                        arguments: levelNumber,
                      );
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isLocked
                      ? Colors.grey
                      : Colors.deepPurple[400], // Grey out if locked
              foregroundColor: Colors.black,
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              padding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child:
                isLocked
                    ? Icon(Icons.lock, color: Colors.white) // Show lock icon
                    : Text('Level $levelNumber'),
          );
        },
      ),
    );
  }
}
