import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clothes_provider.dart';
import '../providers/cart_provider.dart';
import 'clothes_detail_screen.dart';

class ClothesScreen extends StatefulWidget {
  const ClothesScreen({super.key});

  @override
  State<ClothesScreen> createState() => _ClothesScreenState();
}

class _ClothesScreenState extends State<ClothesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<ClothesProvider>(context, listen: false).loadClothes()
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
      Provider.of<ClothesProvider>(context, listen: false)
          .loadClothes(searchQuery: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clothes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search clothes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: Consumer<ClothesProvider>(
        builder: (context, clothesProvider, child) {
          if (clothesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (clothesProvider.clothes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No clothes available'
                        : 'No results found for "$_searchQuery"',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: clothesProvider.clothes.length,
            itemBuilder: (context, index) {
              final clothes = clothesProvider.clothes[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Stack(
                    children: [
                      clothes['image_base64'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.memory(
                                base64Decode(clothes['image_base64']),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Error loading image: $error');
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.error_outline),
                                  );
                                },
                              ),
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported),
                            ),
                      if (clothes['is_sold'] == true)
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Text(
                              'SOLD',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    clothes['title'] ?? 'No title',
                    style: TextStyle(
                      color: clothes['is_sold'] == true ? Colors.grey : null,
                    ),
                  ),
                  subtitle: Text(
                    '\$${(clothes['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                    style: TextStyle(
                      color: clothes['is_sold'] == true ? Colors.grey : null,
                    ),
                  ),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClothesDetailScreen(clothes: clothes),
                      ),
                    );
                    
                    // If we got updated clothes data back, refresh the list
                    if (result != null && result is Map<String, dynamic>) {
                      Provider.of<ClothesProvider>(context, listen: false).loadClothes();
                    }
                  },
                  trailing: IconButton(
                    icon: Icon(
                      Icons.add_shopping_cart,
                      color: clothes['is_sold'] == true ? Colors.grey : null,
                    ),
                    onPressed: clothes['is_sold'] == true
                        ? null
                        : () {
                            Provider.of<CartProvider>(context, listen: false)
                                .addToCart(context, clothes['id']);
                          },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 