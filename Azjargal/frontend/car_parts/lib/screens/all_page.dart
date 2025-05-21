import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'cart_part.dart';
import 'detail_page.dart';
import '../models/carpart.dart';

class AllPage extends StatefulWidget {
  const AllPage({Key? key}) : super(key: key);

  @override
  State<AllPage> createState() => _AllPageState();
}

class _AllPageState extends State<AllPage> {
  late Future<List<CarPart>> _carParts;
  List<CarPart> _displayedParts = [];
  final TextEditingController _searchController = TextEditingController();
  List<CarPart> _cartItems = [];

  Future<List<CarPart>> fetchCarParts() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/carpart_list/'),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['car_parts'];
      return data.map((item) => CarPart.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load car parts');
    }
  }

  void _searchParts(String query) {
    if (query.isEmpty) {
      _carParts.then((parts) {
        setState(() {
          _displayedParts = parts;
        });
      });
    } else {
      _carParts.then((parts) {
        setState(() {
          _displayedParts = parts.where((part) {
            return part.name.toLowerCase().contains(query.toLowerCase()) ||
                (part.category?.toLowerCase().contains(query.toLowerCase()) ??
                    false) ||
                (part.brand?.toLowerCase().contains(query.toLowerCase()) ??
                    false) ||
                (part.description
                        ?.toLowerCase()
                        .contains(query.toLowerCase()) ??
                    false);
          }).toList();
        });
      });
    }
  }

  void _addToCart(CarPart part) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/cart/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'part_id': part.id, 'quantity': 1}),
      );
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        setState(() {
          _cartItems.add(part);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${part.name} сагсанд нэмэгдлээ'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Серверийн хариу амжилтгүй байна');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Алдаа гарлаа: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _carParts = fetchCarParts();
    _carParts.then((parts) {
      setState(() {
        _displayedParts = parts;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Авто Сэлбэгийн Худалдаа'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart, size: 28),
                if (_cartItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${_cartItems.length}',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {}, // disabled due to _navigateToCart removed
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Хайх...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _searchParts,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<CarPart>>(
              future: _carParts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Алдаа гарлаа: ${snapshot.error}'));
                } else {
                  return _displayedParts.isEmpty
                      ? Center(child: Text('Хайлтын үр дүн олдсонгүй'))
                      : GridView.builder(
                          padding: EdgeInsets.all(8.0),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _displayedParts.length,
                          itemBuilder: (context, index) {
                            final part = _displayedParts[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetailPage(
                                              carPart: {
                                                'id': part.id,
                                                'Нэр': part.name,
                                                'Зураг': part.imageUrl,
                                                'Үнэ': part.price,
                                                'Тайлбар': part.description,
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(12),
                                        ),
                                        child: part.imageUrl != null
                                            ? Image.network(
                                                part.imageUrl!,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context, error, stack) {
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    child: Icon(
                                                        Icons.broken_image,
                                                        size: 50),
                                                  );
                                                },
                                              )
                                            : Container(
                                                color: Colors.grey[200],
                                                child: Icon(
                                                    Icons.image_not_supported,
                                                    size: 50),
                                              ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          part.name,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (part.price != null)
                                          Text(
                                            '${part.price!}₮',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.blue),
                                          ),
                                        SizedBox(height: 4),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () => _addToCart(part),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Text('Сагсанд нэмэх'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
