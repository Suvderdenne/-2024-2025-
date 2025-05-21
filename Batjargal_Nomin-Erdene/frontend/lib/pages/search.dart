import 'dart:convert';
import 'package:ebook_app/models/book.dart';
import 'package:ebook_app/pages/detail/detail.dart';
import 'package:ebook_app/pages/option_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchService {
  // final String apiUrl = "http://172.20.10.5:8000/search/";
  final String apiUrl = "http://0.0.0.0:8000/search/";

  Future<List<Book>> searchBooks(
    String query, {
    String type = "",
    String genre = "",
  }) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action": "searchbook",
          "query": query,
          "type": type,
          "turul": genre,
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        List<Book> books =
            (responseData['data'] as List)
                .map((json) => Book.fromJson(json))
                .toList();
        return books;
      } else {
        throw Exception("Failed to load books");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Book> _searchResults = [];
  final SearchService _searchService = SearchService();

  String _selectedType = "";
  String _selectedGenre = "";

  List<String> _genreOptions = [];
  List<String> _typeOptions = [];

  final OptionService _optionService = OptionService();

  @override
  void initState() {
    super.initState();
    _loadOptionsFromServer();
  }

  void _loadOptionsFromServer() async {
    try {
      final options = await _optionService.fetchOptions();
      setState(() {
        _genreOptions = options['genres'] ?? [];
        _typeOptions = options['types'] ?? [];
      });
    } catch (e) {
      print("Options load error: $e");
    }
  }

  void _search(String query) async {
    if (query.isNotEmpty ||
        _selectedType.isNotEmpty ||
        _selectedGenre.isNotEmpty) {
      final results = await _searchService.searchBooks(
        query,
        type: _selectedType,
        genre: _selectedGenre,
      );
      setState(() {
        _searchResults = results;
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 208, 232, 255),
      appBar: AppBar(
        title: const Text('📚 Хайлт'),
        backgroundColor: Color.fromARGB(255, 75, 162, 238),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   'Ном хайх',
            //   style: TextStyle(
            //     fontSize: 24,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.blueAccent,
            //   ),
            // ),
            // const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'Номын нэр...',
                labelStyle: TextStyle(fontSize: 16),
                prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (text) {
                _search(text);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGenre.isEmpty ? null : _selectedGenre,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    hint: Text('Жанр'),
                    items:
                        _genreOptions.map((genre) {
                          return DropdownMenuItem<String>(
                            value: genre,
                            child: Text(genre.isEmpty ? 'Бүгд' : genre),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGenre = value ?? "";
                      });
                      _search(_controller.text);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType.isEmpty ? null : _selectedType,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    hint: Text('Төрөл'),
                    items:
                        _typeOptions.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                    onChanged: (value) async {
                      setState(() {
                        _selectedType = value ?? "";
                        _selectedGenre = "";
                        _genreOptions = [];
                      });

                      try {
                        final genres = await _optionService.fetchGenresByType(
                          _selectedType,
                        );
                        setState(() {
                          _genreOptions = genres;
                        });
                      } catch (e) {
                        print("Genre fetch error: $e");
                      }

                      _search(_controller.text);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _searchResults.isEmpty
                      ? Center(
                        child: Text(
                          'Хайлтын үр дүн алга 😕',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final book = _searchResults[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPage(book),
                                ),
                              );
                            },
                            child: Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 4,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(20),
                                    ),
                                    child: Image.asset(
                                      book.imgUrl,
                                      width: 100,
                                      height: 130,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12.0,
                                        horizontal: 8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            book.title,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            "Төрөл: ${book.type}",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
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
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:ebook_app/models/book.dart';
// import 'package:ebook_app/pages/detail/detail.dart';
// import 'package:ebook_app/pages/option_service.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class SearchService {
//   final String apiUrl = "http://0.0.0.0:8000/search/";

//   Future<List<Book>> searchBooks(
//     String query, {
//     String type = "",
//     String genre = "",
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "action": "searchbook",
//           "query": query,
//           "type": type,
//           "turul": genre,
//         }),
//       );

//       if (response.statusCode == 200) {
//         Map<String, dynamic> responseData = jsonDecode(response.body);
//         List<Book> books =
//             (responseData['data'] as List)
//                 .map((json) => Book.fromJson(json))
//                 .toList();
//         return books;
//       } else {
//         throw Exception("Failed to load books");
//       }
//     } catch (e) {
//       throw Exception("Error: $e");
//     }
//   }
// }

// class SearchScreen extends StatefulWidget {
//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController _controller = TextEditingController();
//   List<Book> _searchResults = [];
//   final SearchService _searchService = SearchService();

//   String _selectedType = "";
//   String _selectedGenre = "";

//   List<String> _genreOptions = [];
//   List<String> _typeOptions = [];

//   final OptionService _optionService = OptionService();

//   @override
//   void initState() {
//     super.initState();
//     _loadOptionsFromServer();
//   }

//   void _loadOptionsFromServer() async {
//     try {
//       final options = await _optionService.fetchOptions();
//       setState(() {
//         _genreOptions = options['genres'] ?? [];
//         _typeOptions = options['types'] ?? [];
//       });
//     } catch (e) {
//       print("Options load error: $e");
//     }
//   }

//   // Төрөл сонгогдсон үед жанрын жагсаалт шинэчлэгдэж байх
//   void _updateGenresByType(String selectedType) async {
//     try {
//       final genres = await _optionService.fetchGenresByType(selectedType);
//       setState(() {
//         _genreOptions = genres; // Жанрын жагсаалтыг шинэчилнэ.
//         _selectedGenre = ""; // Жанр сонголтыг цэвэрлэнэ.
//       });
//     } catch (e) {
//       print("Жанр авахад алдаа гарлаа: $e");
//     }
//   }

//   void _search(String query) async {
//     if (query.isNotEmpty ||
//         _selectedType.isNotEmpty ||
//         _selectedGenre.isNotEmpty) {
//       final results = await _searchService.searchBooks(
//         query,
//         type: _selectedType,
//         genre: _selectedGenre,
//       );
//       setState(() {
//         _searchResults = results;
//       });
//     } else {
//       setState(() {
//         _searchResults = [];
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Хайлт'),
//         backgroundColor: Color.fromARGB(255, 122, 189, 248),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Хайлтын талбар
//             TextField(
//               controller: _controller,
//               decoration: InputDecoration(
//                 labelText: 'Хайлтаа оруулна уу',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.search),
//               ),
//               onChanged: (text) {
//                 _search(text);
//               },
//             ),
//             const SizedBox(height: 16),

//             // Жанр ба төрөл сонголтууд
//             Row(
//               children: [
//                 // Жанр
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: _selectedGenre.isEmpty ? null : _selectedGenre,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 8,
//                       ),
//                     ),
//                     hint: Text('Жанр'),
//                     items:
//                         _genreOptions.map((genre) {
//                           return DropdownMenuItem<String>(
//                             value: genre,
//                             child: Text(genre),
//                           );
//                         }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedGenre = value ?? "";
//                       });
//                       _search(_controller.text);
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 8),

//                 // Төрөл
//                 Expanded(
//                   child: DropdownButtonFormField<String>(
//                     value: _selectedType.isEmpty ? null : _selectedType,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 8,
//                       ),
//                     ),
//                     hint: Text('Төрөл'),
//                     items:
//                         _typeOptions.map((type) {
//                           return DropdownMenuItem<String>(
//                             value: type,
//                             child: Text(type),
//                           );
//                         }).toList(),
//                     onChanged: (value) async {
//                       setState(() {
//                         _selectedType = value ?? "";
//                         _selectedGenre = ""; // Clear genre when type changes
//                         _genreOptions =
//                             []; // Clear genre options when type changes
//                       });

//                       try {
//                         final genres = await _optionService.fetchGenresByType(
//                           _selectedType,
//                         );
//                         setState(() {
//                           _genreOptions = genres;
//                         });
//                       } catch (e) {
//                         print("Genre fetch error: $e");
//                       }

//                       _search(_controller.text);
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // Үр дүн
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _searchResults.length,
//                 itemBuilder: (context, index) {
//                   final book = _searchResults[index];
//                   return GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => DetailPage(book),
//                         ),
//                       );
//                     },
//                     child: Card(
//                       margin: EdgeInsets.symmetric(vertical: 8),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 3,
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           ClipRRect(
//                             borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(12),
//                               bottomLeft: Radius.circular(12),
//                             ),
//                             child: Image.asset(
//                               book.imgUrl,
//                               width: 100,
//                               height: 130,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           SizedBox(width: 12),
//                           Expanded(
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 vertical: 12.0,
//                                 horizontal: 8,
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     book.title,
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                   SizedBox(height: 6),
//                                   Text(
//                                     "Төрөл: ${book.type}",
//                                     style: TextStyle(color: Colors.grey[700]),
//                                   ),
//                                   SizedBox(height: 4),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
