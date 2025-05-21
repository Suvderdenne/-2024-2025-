import 'package:ebook_app/models/book.dart';
import 'package:ebook_app/pages/detail/detail.dart';
import 'package:ebook_app/pages/favorite/favorite_service.dart';
import 'package:flutter/material.dart';

class BookItem extends StatefulWidget {
  final Book book;
  final bool isFavorite;
  final Function(bool isNowFavorite)? onFavoriteToggled;

  const BookItem({
    Key? key,
    required this.book,
    required this.isFavorite,
    this.onFavoriteToggled,
  }) : super(key: key);

  @override
  _BookItemState createState() => _BookItemState();
}

class _BookItemState extends State<BookItem> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
  }

  void _toggleFavorite() async {
    setState(() {
      isFavorite = !isFavorite;
    });

    if (isFavorite) {
      await FavoriteService.addFavorite({
        'id': widget.book.id,
        'title': widget.book.title,
        'imgUrl': widget.book.imgUrl,
        'name': widget.book.name,
      });
    } else {
      await FavoriteService.removeFavorite(widget.book.id);
    }

    // Callback — HomePage, FavoritePage гээд бүх дэлгэцүүдэд мэдэгдэх
    if (widget.onFavoriteToggled != null) {
      widget.onFavoriteToggled!(isFavorite);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => DetailPage(
                    widget.book,
                    onFavoriteChanged: () {
                      if (widget.onFavoriteToggled != null) {
                        widget.onFavoriteToggled!(isFavorite);
                      }
                    },
                  ),
            ),
          ),
      child: Container(
        width: 160,
        height: 200,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(widget.book.imgUrl, fit: BoxFit.cover),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.9),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.book.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleFavorite,
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 20,
                        ),
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
