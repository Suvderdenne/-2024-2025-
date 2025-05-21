// import 'package:ebook_app/pages/detail/detail.dart';
// import 'package:flutter/material.dart';
// import 'package:ebook_app/models/book.dart';

// class BookCard extends StatefulWidget {
//   final Book book;
//   const BookCard({Key? key, required this.book}) : super(key: key);

//   @override
//   State<BookCard> createState() => _BookCardState();
// }

// class _BookCardState extends State<BookCard>
//     with SingleTickerProviderStateMixin {
//   double _scale = 1.0;

//   void _onTapDown(TapDownDetails details) {
//     setState(() {
//       _scale = 0.97;
//     });
//   }

//   void _onTapUp(TapUpDetails details) {
//     setState(() {
//       _scale = 1.0;
//     });
//   }

//   void _onTapCancel() {
//     setState(() {
//       _scale = 1.0;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final book = widget.book;

//     return GestureDetector(
//       onTapDown: _onTapDown,
//       onTapUp: _onTapUp,
//       onTapCancel: _onTapCancel,
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => DetailPage(book)),
//         );
//       },
//       child: AnimatedScale(
//         scale: _scale,
//         duration: const Duration(milliseconds: 150),
//         child: Container(
//           margin: const EdgeInsets.only(bottom: 16),
//           decoration: BoxDecoration(
//             color: const Color.fromARGB(255, 107, 136, 218),
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black12,
//                 blurRadius: 6,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               Hero(
//                 tag: book.id, // 📌 Ensure book.id is unique
//                 child: ClipRRect(
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(16),
//                     bottomLeft: Radius.circular(16),
//                   ),
//                   child: Image.network(
//                     book.imgUrl,
//                     width: 100,
//                     height: 150,
//                     fit: BoxFit.cover,
//                     errorBuilder:
//                         (context, error, stackTrace) => Container(
//                           width: 100,
//                           height: 150,
//                           color: Colors.grey.shade300,
//                           child: const Icon(
//                             Icons.image_not_supported,
//                             color: Colors.grey,
//                           ),
//                         ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 10,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         book.title,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.access_time,
//                             size: 16,
//                             color: Colors.greenAccent,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             "${book.duration} мин",
//                             style: const TextStyle(color: Colors.white),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       Text(
//                         book.review.length > 100
//                             ? "${book.review.substring(0, 100)}..."
//                             : book.review,
//                         style: const TextStyle(color: Colors.white70),
//                         maxLines: 3,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:ebook_app/pages/detail/detail.dart';
import 'package:ebook_app/models/book.dart';
import 'package:flutter/material.dart';
import 'package:ebook_app/pages/detail/review_service.dart';

class BookCard extends StatefulWidget {
  final Book book;
  const BookCard({Key? key, required this.book}) : super(key: key);

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  double avgRating = 0.0;
  int ratingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadRatingInfo();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.97;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  Future<void> _loadRatingInfo() async {
    final result = await ReviewService.fetchReviewsWithRating(
      int.tryParse(widget.book.id) ?? 0,
    );
    setState(() {
      avgRating = result['avg_rating']?.toDouble() ?? 0.0;
      ratingCount = result['rating_count'] ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPage(book)),
        );
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 107, 136, 218),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Hero(
                tag: book.id,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Image.network(
                    book.imgUrl,
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: 100,
                          height: 150,
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.greenAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${book.duration} мин",
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            "$avgRating ($ratingCount)",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        book.review.length > 100
                            ? "${book.review.substring(0, 100)}..."
                            : book.review,
                        style: const TextStyle(color: Colors.white70),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
