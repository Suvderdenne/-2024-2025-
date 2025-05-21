import 'package:flutter/material.dart';
import 'package:ebook_app/pages/favorite/favorite_service.dart';
import 'package:ebook_app/pages/favorite/watched_history_tab.dart';

class FavoritePage extends StatefulWidget {
  final int userId;
  final VoidCallback? onFavoriteChanged;

  const FavoritePage({Key? key, required this.userId, this.onFavoriteChanged})
    : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Map<String, dynamic>> _favoriteBooks = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final books = await FavoriteService.getFavorites();
    setState(() {
      _favoriteBooks = books;
    });
    if (widget.onFavoriteChanged != null) {
      widget.onFavoriteChanged!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: const Color.fromARGB(255, 216, 220, 253),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Color.fromARGB(255, 47, 139, 245),
                      width: 2,
                    ),
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black,
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [Tab(text: "Үзсэн түүх"), Tab(text: "Хадгалсан")],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  WatchedHistoryTab(userId: widget.userId),
                  SavedBooksTab(
                    favoriteBooks: _favoriteBooks,
                    onFavoriteChanged: _loadFavorites,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SavedBooksTab extends StatefulWidget {
  final List<Map<String, dynamic>> favoriteBooks;
  final VoidCallback? onFavoriteChanged;

  const SavedBooksTab({
    Key? key,
    required this.favoriteBooks,
    this.onFavoriteChanged,
  }) : super(key: key);

  @override
  State<SavedBooksTab> createState() => _SavedBooksTabState();
}

class _SavedBooksTabState extends State<SavedBooksTab> {
  late List<Map<String, dynamic>> favorites;

  @override
  void initState() {
    super.initState();
    favorites = widget.favoriteBooks;
  }

  @override
  void didUpdateWidget(covariant SavedBooksTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.favoriteBooks != widget.favoriteBooks) {
      setState(() {
        favorites = widget.favoriteBooks;
      });
    }
  }

  Future<void> _removeFavorite(String bookId) async {
    await FavoriteService.removeFavorite(bookId);
    final updated =
        favorites.where((book) => book['id'].toString() != bookId).toList();
    setState(() {
      favorites = updated;
    });

    if (widget.onFavoriteChanged != null) {
      widget.onFavoriteChanged!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return const Center(child: Text("Хадгалсан ном алга байна."));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final book = favorites[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    book['imgUrl'] ?? '',
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 48),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Зохиогч: ${book['name'] ?? 'Тодорхойгүй'}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.redAccent),
                  onPressed: () => _removeFavorite(book['id'].toString()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// import 'package:ebook_app/models/book.dart';
// import 'package:flutter/material.dart';
// import 'package:ebook_app/pages/favorite/favorite_service.dart';
// import 'package:ebook_app/pages/favorite/watched_history_tab.dart';
// import 'package:ebook_app/pages/detail/detail.dart';

// class FavoritePage extends StatefulWidget {
//   final int userId;
//   final VoidCallback? onFavoriteChanged;
//   final List<Map<String, dynamic>> favoriteBooks;

//   const FavoritePage({
//     Key? key,
//     required this.userId,
//     required this.favoriteBooks,
//     this.onFavoriteChanged,
//   }) : super(key: key);

//   @override
//   State<FavoritePage> createState() => _FavoritePageState();
// }

// class _FavoritePageState extends State<FavoritePage> {
//   late List<Map<String, dynamic>> favoriteBooks;

//   @override
//   void initState() {
//     super.initState();
//     favoriteBooks = widget.favoriteBooks;
//     _loadFavorites();
//   }

//   Future<void> _loadFavorites() async {
//     final result = await FavoriteService.getFavorites();
//     setState(() {
//       favoriteBooks = List<Map<String, dynamic>>.from(result);
//     });

//     // Callback to parent (like HomePage)
//     if (widget.onFavoriteChanged != null) {
//       widget.onFavoriteChanged!();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: Column(
//           children: [
//             const SizedBox(height: 10),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 child: TabBar(
//                   indicator: BoxDecoration(
//                     color: const Color.fromARGB(255, 216, 220, 253),
//                     borderRadius: BorderRadius.circular(30),
//                     border: Border.all(
//                       color: Color.fromARGB(255, 47, 139, 245),
//                       width: 2,
//                     ),
//                   ),
//                   labelColor: Colors.black,
//                   unselectedLabelColor: Colors.black,
//                   labelStyle: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   indicatorSize: TabBarIndicatorSize.tab,
//                   tabs: const [Tab(text: "Үзсэн түүх"), Tab(text: "Хадгалсан")],
//                 ),
//               ),
//             ),
//             Expanded(
//               child: TabBarView(
//                 children: [
//                   WatchedHistoryTab(userId: widget.userId),
//                   SavedBooksTab(
//                     favoriteBooks: favoriteBooks,
//                     onFavoriteChanged: _loadFavorites,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SavedBooksTab extends StatefulWidget {
//   final List<Map<String, dynamic>> favoriteBooks;
//   final VoidCallback? onFavoriteChanged;

//   const SavedBooksTab({
//     Key? key,
//     required this.favoriteBooks,
//     this.onFavoriteChanged,
//   }) : super(key: key);

//   @override
//   State<SavedBooksTab> createState() => _SavedBooksTabState();
// }

// class _SavedBooksTabState extends State<SavedBooksTab> {
//   late List<Map<String, dynamic>> favorites;

//   @override
//   void initState() {
//     super.initState();
//     favorites = widget.favoriteBooks;
//   }

//   @override
//   void didUpdateWidget(covariant SavedBooksTab oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.favoriteBooks != widget.favoriteBooks) {
//       setState(() {
//         favorites = widget.favoriteBooks;
//       });
//     }
//   }

//   Future<void> _removeFavorite(String bookId) async {
//     await FavoriteService.removeFavorite(bookId);
//     final updated =
//         favorites.where((book) => book['id'].toString() != bookId).toList();
//     setState(() {
//       favorites = updated;
//     });

//     if (widget.onFavoriteChanged != null) {
//       widget.onFavoriteChanged!();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (favorites.isEmpty) {
//       return const Center(child: Text("Хадгалсан ном алга байна."));
//     }

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: ListView.builder(
//         itemCount: favorites.length,
//         itemBuilder: (context, index) {
//           final book = favorites[index];
//           print("🎯 Book map: $book"); // ← зөв байрлал
//           return GestureDetector(
//             onTap: () async {
//               await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder:
//                       (context) => DetailPage(
//                         bookFromMap(book),
//                         onFavoriteChanged: widget.onFavoriteChanged,
//                       ),
//                 ),
//               );
//               if (widget.onFavoriteChanged != null) {
//                 widget.onFavoriteChanged!();
//               }
//             },
//             child: Container(
//               margin: const EdgeInsets.only(bottom: 16),
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(16),
//                     child: Image.network(
//                       book['imgUrl'] ?? '',
//                       width: 90,
//                       height: 90,
//                       fit: BoxFit.cover,
//                       errorBuilder:
//                           (context, error, stackTrace) =>
//                               const Icon(Icons.broken_image, size: 48),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           book['title'] ?? '',
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF1E293B),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           "Зохиогч: ${book['name'] ?? 'Тодорхойгүй'}",
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Color(0xFF64748B),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.favorite, color: Colors.redAccent),
//                     onPressed: () => _removeFavorite(book['id'].toString()),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Book bookFromMap(Map<String, dynamic> map) {
//     return Book(
//       id: map['id']?.toString() ?? '',
//       title: map['title']?.toString() ?? 'Гарчиг байхгүй',
//       name: map['name']?.toString() ?? 'Зохиолч байхгүй',
//       type: map['type']?.toString() ?? '',
//       date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
//       imgUrl: map['imgUrl']?.toString() ?? '',
//       altImgUrls:
//           (map['altImgUrls'] is List)
//               ? (map['altImgUrls'] as List).map((e) => e.toString()).toList()
//               : [],
//       audioUrl: map['audioUrl']?.toString() ?? '',
//       score: map['score'] is int ? map['score'] : 0,
//       review: map['review']?.toString() ?? '',
//       height: num.tryParse(map['height']?.toString() ?? '0') ?? 0,
//       duration: int.tryParse(map['duration']?.toString() ?? '0') ?? 0,
//       turul: map['turul']?.toString() ?? '',
//       summary: map['summary']?.toString() ?? '',
//       progress: double.tryParse(map['progress']?.toString() ?? '0.0') ?? 0.0,
//     );
//   }
// }
