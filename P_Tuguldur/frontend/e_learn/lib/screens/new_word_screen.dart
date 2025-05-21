import 'dart:convert';
import 'package:e_learn/screens/WordDetailScreen.dart'; // Assuming this screen exists
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Define the primary green color
const Color primaryGreen = Color(0xFF8BC34A);
const Color whiteColor = Colors.white;
const Color lightGreenBackground = Color(0xFFEFFAF1); // Light green for screen body background

// --- NewWordScreen ---
class NewWordScreen extends StatelessWidget {
  final String token; // Authentication token for API calls

  const NewWordScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        backgroundColor: lightGreenBackground, // Light green background for the screen
        appBar: AppBar(
          title: const Text(
            'New Words',
            style: TextStyle(color: whiteColor), // Title text color changed to white
          ),
          backgroundColor: primaryGreen, // AppBar background color changed to primaryGreen
          foregroundColor: whiteColor, // Icon and action button color changed to white
          bottom: const TabBar(
            indicatorColor: whiteColor, // Color of the underline for the selected tab
            labelColor: whiteColor, // Color of the text for the selected tab
            unselectedLabelColor: Color.fromARGB(200, 255, 255, 255), // Lighter white for unselected tabs
            tabs: [
              Tab(text: 'Word'), // First tab
              Tab(text: 'My Words'), // Second tab
            ],
          ),
        ),
        body: TabBarView(
          children: [
            WordListTab(token: token), // Content for the 'Word' tab
            MyWordsTab(token: token), // Content for the 'My Words' tab
          ],
        ),
      ),
    );
  }
}

// --- WordListTab ---
class WordListTab extends StatefulWidget {
  final String token;
  const WordListTab({super.key, required this.token});

  @override
  State<WordListTab> createState() => _WordListTabState();
}

class _WordListTabState extends State<WordListTab> {
  List<dynamic> words = []; // List to hold all words
  List<dynamic> filteredWords = []; // List to hold filtered words
  bool isLoading = true; // Flag to indicate loading state
  TextEditingController searchController = TextEditingController(); // Controller for the search field

  @override
  void initState() {
    super.initState();
    fetchWords(); // Fetch words when the widget is initialized
  }

  @override
  void dispose() {
    searchController.dispose(); // Clean up the controller when the widget is disposed
    super.dispose();
  }

  Future<void> fetchWords() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/words/'), // API endpoint for all words
        headers: {'Authorization': 'Bearer ${widget.token}'}, // Pass auth token
      );
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        setState(() {
          words = json.decode(decodedBody); // Parse JSON data
          filteredWords = words; // Initially, all words are shown
          isLoading = false; // Update loading state
        });
      } else {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to load words.")),
          );
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred while fetching words.")),
        );
      }
    }
  }

  void filterWords(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredWords = words; // Show all words if the query is empty
      } else {
        filteredWords = words.where((word) {
          final english = word['english']?.toLowerCase() ?? '';
          final mongolian = word['mongolian']?.toLowerCase() ?? '';
          return english.contains(query.toLowerCase()) || mongolian.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> bookmarkWord(int id) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/bookmark/'), // API endpoint for bookmarking
        headers: {
          'Authorization': 'Bearer ${widget.token}', // Auth token
          'Content-Type': 'application/json', // Specify JSON content type
        },
        body: json.encode({'word_id': id}), // Send word ID in the request body
      );

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bookmarked!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to bookmark: ${response.statusCode}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred while bookmarking.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: primaryGreen));
    if (words.isEmpty) return const Center(child: Text("No words available.", style: TextStyle(color: Colors.black54)));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search words',
              prefixIcon: const Icon(Icons.search, color: primaryGreen),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: primaryGreen, width: 2.0),
              ),
              labelStyle: const TextStyle(color: primaryGreen),
            ),
            onChanged: filterWords,
            cursorColor: primaryGreen,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredWords.length,
            itemBuilder: (context, index) {
              final word = filteredWords[index];
              return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(
                    word['english'] ?? 'N/A',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                  subtitle: Text(
                    word['mongolian'] ?? 'N/A',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WordDetailScreen(
                          wordId: word['id'],
                          token: widget.token,
                        ),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.bookmark_add, color: primaryGreen),
                    tooltip: 'Bookmark word',
                    onPressed: () {
                      bookmarkWord(word['id']);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- MyWordsTab ---
class MyWordsTab extends StatefulWidget {
  final String token;
  const MyWordsTab({super.key, required this.token});

  @override
  State<MyWordsTab> createState() => _MyWordsTabState();
}

class _MyWordsTabState extends State<MyWordsTab> {
  List<dynamic> myWords = []; // List to hold bookmarked words
  bool isLoading = true; // Flag to indicate loading state

  @override
  void initState() {
    super.initState();
    fetchMyWords(); // Fetch bookmarked words when the widget is initialized
  }

  Future<void> fetchMyWords() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/my-words/'), // API endpoint for bookmarked words
        headers: {'Authorization': 'Bearer ${widget.token}'}, // Pass auth token
      );
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        setState(() {
          myWords = json.decode(decodedBody); // Parse JSON data
          isLoading = false; // Update loading state
        });
      } else {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to load bookmarked words.")),
          );
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred while fetching bookmarked words.")),
        );
      }
    }
  }

  Future<void> removeBookmark(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8000/my-words/$id/'), // API endpoint to remove bookmark
        headers: {'Authorization': 'Bearer ${widget.token}'}, // Pass auth token
      );

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 204) {
          setState(() {
            myWords.removeWhere((word) => word['id'] == id); // Remove the word from the list
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bookmark removed!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to remove bookmark: ${response.statusCode}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred while removing the bookmark.")),
        );
      }
    }
  }

  Future<void> confirmAndRemoveBookmark(int id) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to remove this bookmark?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User chose "No"
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User chose "Yes"
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      // Proceed with deletion if the user confirmed
      removeBookmark(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: primaryGreen));
    if (myWords.isEmpty) return const Center(child: Text("No bookmarked words.", style: TextStyle(color: Colors.black54)));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myWords.length,
      itemBuilder: (context, index) {
        final word = myWords[index];
        return Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 4,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            title: Text(
              word['english'] ?? 'N/A',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
            subtitle: Text(
              word['mongolian'] ?? 'N/A',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            onTap: () {
              // Navigate to WordDetailScreen when tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WordDetailScreen(
                    wordId: word['id'],
                    token: widget.token,
                  ),
                ),
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Remove bookmark',
              onPressed: () {
                confirmAndRemoveBookmark(word['id']); // Show confirmation dialog
              },
            ),
          ),
        );
      },
    );
  }
}