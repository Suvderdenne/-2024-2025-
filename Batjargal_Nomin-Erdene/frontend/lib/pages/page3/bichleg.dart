import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ebook_app/models/book.dart';
import 'book_card.dart';

class BichlegPage extends StatelessWidget {
  const BichlegPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
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
                      color: Color.fromARGB(255, 51, 99, 255),
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
                  tabs: const [Tab(text: "Үлгэр"), Tab(text: "Домог")],
                ),
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  BooksTab(bookType: 'Үлгэр'),
                  BooksTab(bookType: 'Домог'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BooksTab extends StatefulWidget {
  final String bookType;
  const BooksTab({Key? key, required this.bookType}) : super(key: key);

  @override
  _BooksTabState createState() => _BooksTabState();
}

class _BooksTabState extends State<BooksTab> {
  List<Book> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    final response = await http.post(
      Uri.parse("http://0.0.0.0:8000/book/"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"action": "getallbook"}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List rawBooks = data["data"];

      setState(() {
        books = rawBooks.map((json) => Book.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      print("Error loading books");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Book> filteredBooks =
        books.where((book) => book.type == widget.bookType).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredBooks.length,
      itemBuilder: (context, index) {
        return BookCard(book: filteredBooks[index]);
      },
    );
  }
}
