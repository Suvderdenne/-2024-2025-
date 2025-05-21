import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:ebook_app/pages/favorite/favorite.dart';
import 'package:ebook_app/pages/favorite/favorite_service.dart';
import 'package:ebook_app/pages/profile1.dart';
import 'package:ebook_app/pages/search.dart';
import 'package:flutter/material.dart';
import 'package:ebook_app/constants/colors.dart';
import 'package:ebook_app/pages/detail/detail.dart';
import 'package:ebook_app/pages/home/widgets/book_staggered_gridview.dart';
import 'package:ebook_app/models/book.dart';
import 'package:ebook_app/pages/page3/bichleg.dart';

class HomePage extends StatefulWidget {
  final int userId;
  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var tabIndex = 0;
  var bottomIndex = 0;
  final pageController = PageController();
  final storyPageController = PageController();
  int currentPage = 0;

  List<Book> allBooks = [];
  Book? randomBook;
  List<Map<String, dynamic>> favoriteBooks = [];

  @override
  void initState() {
    super.initState();
    fetchBooksAndInit();
  }

  Future<void> fetchBooksAndInit() async {
    allBooks = await Book.fetchBooks(context);
    randomBook = Book.getRandomBook(allBooks);
    favoriteBooks = await FavoriteService.getFavorites();
    setState(() {});
  }

  Future<void> _handleFavoriteChanged() async {
    final updated = await FavoriteService.getFavorites();
    setState(() {
      favoriteBooks = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Column(
        children: [
          _buildStorySlider(),
          Expanded(
            child: BookStaggeredGridView(
              tabIndex,
              pageController,
              (int index, List<Map<String, dynamic>> updatedFavorites) {
                setState(() {
                  tabIndex = index;
                  favoriteBooks = updatedFavorites;
                });
              },
              favoriteBooks,
              onFavoriteChanged: _handleFavoriteChanged,
            ),
          ),
        ],
      ),
      FavoritePage(
        userId: widget.userId,
        onFavoriteChanged: _handleFavoriteChanged,
      ),
      BichlegPage(),
      Profile1Page(),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 253, 253, 253),
                    Color.fromARGB(255, 252, 252, 252),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.05)),
          ),
          pages[bottomIndex],
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildStorySlider() {
    List<Book> limitedStories = allBooks.take(3).toList();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: storyPageController,
            itemCount: limitedStories.length,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => DetailPage(
                            limitedStories[index],
                            onFavoriteChanged: _handleFavoriteChanged,
                          ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      limitedStories[index].imgUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            limitedStories.length,
            (index) => Container(
              margin: const EdgeInsets.all(4.0),
              width: currentPage == index ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentPage == index ? Colors.blueAccent : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 75, 162, 238),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu_book, color: white),
          ),
          const SizedBox(width: 8),
          const Text(
            "Монгол ардын үлгэр",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
          },
          icon: const Icon(Icons.search_outlined, color: white),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    final bottoms = [
      const Icon(Icons.home, size: 30, color: Colors.white),
      const Icon(Icons.favorite, size: 30, color: Colors.white),
      const Icon(Icons.access_time, size: 30, color: Colors.white),
      const Icon(Icons.person, size: 30, color: Colors.white),
    ];

    return CurvedNavigationBar(
      backgroundColor: Colors.transparent,
      color: const Color.fromARGB(255, 75, 162, 238),
      buttonBackgroundColor: Colors.blueAccent,
      height: 60,
      items: bottoms,
      onTap: (index) {
        setState(() {
          bottomIndex = index;
        });
      },
    );
  }
}
