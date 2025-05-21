import 'package:flutter/material.dart';

class FinalRevealScreen extends StatelessWidget {
  final List<Map<String, String>> playerRoles;

  const FinalRevealScreen({super.key, required this.playerRoles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("All Roles Revealed"),
          backgroundColor: Colors.pink),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: playerRoles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final player = playerRoles[index];
            final isSpy = player['role'] == 'Spy';
            return Container(
              decoration: BoxDecoration(
                color: isSpy ? Colors.red[100] : Colors.green[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isSpy ? Colors.red : Colors.green, width: 2),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      player['role']!,
                      style: TextStyle(
                        fontSize: 22,
                        color: isSpy ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      player['name']!,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
