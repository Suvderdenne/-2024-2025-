//book_review.dart
// import 'package:ebook_app/models/book.dart';
// import 'package:ebook_app/pages/detail/review_service.dart';
// import 'package:ebook_app/pages/favorite/favorite_service.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class BookReview extends StatefulWidget {
//   final Book book;
//   final VoidCallback? onFavoriteChanged;

//   const BookReview(this.book, {Key? key, this.onFavoriteChanged})
//     : super(key: key);

//   @override
//   State<BookReview> createState() => _BookReviewState();
// }

// class _BookReviewState extends State<BookReview> {
//   int userRating = 0;
//   String _commentText = '';
//   List<Map<String, dynamic>> _otherReviews = [];
//   String currentUserId = '';
//   bool showFullReview = false;
//   bool isFavorite = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadCurrentUser();
//     _checkIfFavorite();
//   }

//   Future<void> _loadCurrentUser() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       currentUserId = prefs.getInt('userid')?.toString() ?? '';
//     });
//     await _loadReviews();
//   }

//   Future<void> _loadReviews() async {
//     final result = await ReviewService.fetchReviewsWithRating(
//       int.tryParse(widget.book.id) ?? 0,
//     );
//     setState(() {
//       _otherReviews = List<Map<String, dynamic>>.from(result['reviews']);
//       userRating = result['user_rating'] ?? 0;
//     });
//   }

//   Future<void> _checkIfFavorite() async {
//     final favorites = await FavoriteService.getFavorites();
//     final bookId = widget.book.id.toString();
//     setState(() {
//       isFavorite = favorites.any((b) => b['id'].toString() == bookId);
//     });
//   }

//   Future<void> _toggleFavorite() async {
//     final book = widget.book;
//     final bookId = book.id.toString();

//     setState(() {
//       isFavorite = !isFavorite;
//     });

//     bool success = false;
//     try {
//       if (isFavorite) {
//         await FavoriteService.addFavorite({
//           'id': book.id,
//           'title': book.title,
//           'imgUrl': book.imgUrl,
//           'name': book.name,
//         });
//         success = true;
//       } else {
//         await FavoriteService.removeFavorite(bookId);
//         success = true;
//       }
//     } catch (e) {
//       success = false;
//     }

//     if (success) {
//       await _checkIfFavorite();
//       if (widget.onFavoriteChanged != null) {
//         widget.onFavoriteChanged!();
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Хадгалах үед алдаа гарлаа')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final book = widget.book;
//     String shortReview =
//         book.review.length > 200 ? book.review.substring(0, 200) : book.review;

//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildInteractiveStarsWithFavorite(),
//           Text(
//             showFullReview ? book.review : shortReview,
//             textAlign: TextAlign.justify, //text 2 tal zeregtsvvlex
//             style: const TextStyle(
//               color: Colors.black,
//               fontSize: 16,
//               height: 1.8,
//             ),
//           ),
//           if (book.review.length > 200)
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   showFullReview = !showFullReview;
//                 });
//               },
//               child: Text(
//                 showFullReview ? "Хураах" : "… Дэлгэрэнгүй",
//                 style: const TextStyle(color: Colors.black),
//               ),
//             ),
//           const SizedBox(height: 8),
//           const Text(
//             'Сэтгэгдэл:',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   decoration: const InputDecoration(
//                     hintText: 'Сэтгэгдэл бичих...',
//                     border: OutlineInputBorder(),
//                     contentPadding: EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                   ),
//                   style: const TextStyle(fontSize: 14),
//                   maxLines: 2,
//                   onChanged: (val) {
//                     setState(() {
//                       _commentText = val;
//                     });
//                   },
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.send, color: Colors.black),
//                 onPressed: () async {
//                   if (_commentText.trim().isEmpty) return;

//                   if (userRating > 0) {
//                     await ReviewService.submitRating(
//                       bookId: int.tryParse(widget.book.id) ?? 0,
//                       rating: userRating,
//                       comment: _commentText,
//                     );
//                   } else {
//                     await ReviewService.submitComment(
//                       bookId: int.tryParse(widget.book.id) ?? 0,
//                       comment: _commentText,
//                     );
//                   }

//                   setState(() {
//                     _commentText = '';
//                   });

//                   await _loadReviews();
//                 },
//               ),
//             ],
//           ),
//           if (_otherReviews.isEmpty)
//             const Text("Одоогоор сэтгэгдэл алга байна."),
//           ..._otherReviews.map((review) {
//             final isOwn = review['user_id'].toString() == currentUserId;
//             return Padding(
//               padding: const EdgeInsets.only(bottom: 12),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: isOwn ? Colors.yellow[100] : Colors.grey[100],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 padding: const EdgeInsets.all(8),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("★ ${review['rating']} | ${review['created_at']}"),
//                     const SizedBox(height: 4),
//                     Text(
//                       "${review['username']}${isOwn ? ' (Та)' : ''}",
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blueGrey,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       review['comment'].toString().isNotEmpty
//                           ? review['comment']
//                           : "(Сэтгэгдэл бичээгүй)",
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   Widget _buildInteractiveStarsWithFavorite() {
//     return Row(
//       children: [
//         ...List.generate(5, (index) {
//           return IconButton(
//             icon: Icon(
//               Icons.star,
//               size: 24,
//               color: index < userRating ? Colors.amber : Colors.grey,
//             ),
//             onPressed: () async {
//               setState(() {
//                 userRating = index + 1;
//               });

//               await ReviewService.submitRating(
//                 bookId: int.tryParse(widget.book.id) ?? 0,
//                 rating: userRating,
//                 comment: _commentText,
//               );

//               await _loadReviews();
//             },
//           );
//         }),
//         const SizedBox(width: 200), // Энд зай нэмсэн
//         IconButton(
//           icon: Icon(
//             isFavorite ? Icons.favorite : Icons.favorite_border,
//             color: isFavorite ? Colors.red : Colors.grey,
//             size: 24,
//           ),
//           onPressed: _toggleFavorite,
//         ),
//       ],
//     );
//   }
// }

import 'package:ebook_app/models/book.dart';
import 'package:ebook_app/pages/detail/review_service.dart';
import 'package:ebook_app/pages/favorite/favorite_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookReview extends StatefulWidget {
  final Book book;
  final VoidCallback? onFavoriteChanged;

  const BookReview(this.book, {Key? key, this.onFavoriteChanged})
    : super(key: key);

  @override
  State<BookReview> createState() => _BookReviewState();
}

class _BookReviewState extends State<BookReview> {
  int userRating = 0;
  String _commentText = '';
  List<Map<String, dynamic>> _otherReviews = [];
  String currentUserId = '';
  bool showFullReview = false;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _checkIfFavorite();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getInt('userid')?.toString() ?? '';
    });
    await _loadReviews();
  }

  Future<void> _loadReviews() async {
    final result = await ReviewService.fetchReviewsWithRating(
      int.tryParse(widget.book.id) ?? 0,
    );
    setState(() {
      _otherReviews = List<Map<String, dynamic>>.from(result['reviews']);
      userRating = result['user_rating'] ?? 0;
    });
  }

  Future<void> _checkIfFavorite() async {
    final favorites = await FavoriteService.getFavorites();
    final bookId = widget.book.id.toString();
    setState(() {
      isFavorite = favorites.any((b) => b['id'].toString() == bookId);
    });
  }

  Future<void> _toggleFavorite() async {
    final book = widget.book;
    final bookId = book.id.toString();

    bool success = false;

    try {
      if (isFavorite) {
        await FavoriteService.removeFavorite(bookId);
      } else {
        await FavoriteService.addFavorite({
          'id': book.id,
          'title': book.title,
          'imgUrl': book.imgUrl,
          'name': book.name,
        });
      }
      success = true;
    } catch (e) {
      success = false;
    }

    if (success) {
      setState(() {
        isFavorite = !isFavorite;
      });
      if (widget.onFavoriteChanged != null) {
        widget.onFavoriteChanged!();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Хадгалах үед алдаа гарлаа')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    String shortReview =
        book.review.length > 200 ? book.review.substring(0, 200) : book.review;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInteractiveStarsWithFavorite(),
          Text(
            showFullReview ? book.review : shortReview,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              height: 1.8,
            ),
          ),
          if (book.review.length > 200)
            TextButton(
              onPressed: () {
                setState(() {
                  showFullReview = !showFullReview;
                });
              },
              child: Text(
                showFullReview ? "Хураах" : "… Дэлгэрэнгүй",
                style: const TextStyle(color: Colors.black),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'Сэтгэгдэл:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Сэтгэгдэл бичих...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  onChanged: (val) {
                    setState(() {
                      _commentText = val;
                    });
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.black),
                onPressed: () async {
                  if (_commentText.trim().isEmpty) return;

                  if (userRating > 0) {
                    await ReviewService.submitRating(
                      bookId: int.tryParse(widget.book.id) ?? 0,
                      rating: userRating,
                      comment: _commentText,
                    );
                  } else {
                    await ReviewService.submitComment(
                      bookId: int.tryParse(widget.book.id) ?? 0,
                      comment: _commentText,
                    );
                  }

                  setState(() {
                    _commentText = '';
                  });

                  await _loadReviews();
                },
              ),
            ],
          ),
          if (_otherReviews.isEmpty)
            const Text("Одоогоор сэтгэгдэл алга байна."),
          ..._otherReviews.map((review) {
            final isOwn = review['user_id'].toString() == currentUserId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: isOwn ? Colors.yellow[100] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("★ ${review['rating']} | ${review['created_at']}"),
                    const SizedBox(height: 4),
                    Text(
                      "${review['username']}${isOwn ? ' (Та)' : ''}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      review['comment'].toString().isNotEmpty
                          ? review['comment']
                          : "(Сэтгэгдэл бичээгүй)",
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInteractiveStarsWithFavorite() {
    return Row(
      children: [
        ...List.generate(5, (index) {
          return IconButton(
            icon: Icon(
              Icons.star,
              size: 24,
              color: index < userRating ? Colors.amber : Colors.grey,
            ),
            onPressed: () async {
              setState(() {
                userRating = index + 1;
              });

              await ReviewService.submitRating(
                bookId: int.tryParse(widget.book.id) ?? 0,
                rating: userRating,
                comment: _commentText,
              );

              await _loadReviews();
            },
          );
        }),
        const SizedBox(width: 200),
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.grey,
            size: 24,
          ),
          onPressed: _toggleFavorite,
        ),
      ],
    );
  }
}
