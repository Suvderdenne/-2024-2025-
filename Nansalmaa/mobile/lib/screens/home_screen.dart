import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../providers/auth_provider.dart';
import '../providers/clothes_provider.dart';
import '../providers/cart_provider.dart';
import '../models/clothes_category.dart';
import 'cart_screen.dart';
import 'add_clothes_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'clothes_detail_screen.dart';
import 'category_items_screen.dart';
import 'package:google_fonts/google_fonts.dart';

/// A stateful widget representing the main home screen of the Thrift Store application.
///
/// This screen serves as the primary interface for browsing available clothes items,
/// with search and filtering capabilities.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Navigation and UI state
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final List<Widget> _pages = [
    const _HomeContent(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  // Search and filter state
  String _searchQuery = '';
  Timer? _debounce;
  String? _selectedGender;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Load clothes data when screen initializes
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Initialize data by loading clothes from the provider
  void _initializeData() {
    Future.microtask(() =>
        Provider.of<ClothesProvider>(context, listen: false).loadClothes());
  }

  /// Handle bottom navigation item selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Implement debounced search to prevent excessive API calls
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
      _refreshClothes();
    });
  }

  /// Refresh clothes based on current search and filter criteria
  void _refreshClothes() {
    Provider.of<ClothesProvider>(context, listen: false).loadClothes(
      searchQuery: _searchQuery,
      categoryId: _selectedCategoryId,
      gender: _selectedGender,
    );
  }

  /// Show the filter options in a bottom sheet
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  /// Build the filter bottom sheet content
  Widget _buildFilterBottomSheet() {
    return StatefulBuilder(
      builder: (context, setState) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterHeader(),
                    const SizedBox(height: 20),
                    _buildGenderFilter(setState),
                    const SizedBox(height: 20),
                    _buildCategoryFilter(setState),
                    const SizedBox(height: 20),
                    _buildApplyFilterButton(context),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Build the filter header
  Widget _buildFilterHeader() {
    return const Text(
      'Шүүлт',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Build the gender filter section
  Widget _buildGenderFilter(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Хүйс',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('Бүгд'),
              selected: _selectedGender == null,
              onSelected: (selected) {
                setModalState(() {
                  _selectedGender = null;
                });
              },
              selectedColor: Colors.black,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: _selectedGender == null ? Colors.white : Colors.black,
              ),
            ),
            FilterChip(
              label: const Text('Эрэгтэй'),
              selected: _selectedGender == 'M',
              onSelected: (selected) {
                setModalState(() {
                  _selectedGender = selected ? 'M' : null;
                });
              },
              selectedColor: Colors.black,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: _selectedGender == 'M' ? Colors.white : Colors.black,
              ),
            ),
            FilterChip(
              label: const Text('Эмэгтэй'),
              selected: _selectedGender == 'F',
              onSelected: (selected) {
                setModalState(() {
                  _selectedGender = selected ? 'F' : null;
                });
              },
              selectedColor: Colors.black,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: _selectedGender == 'F' ? Colors.white : Colors.black,
              ),
            ),
            FilterChip(
              label: const Text('Хоёр хүйст'),
              selected: _selectedGender == 'U',
              onSelected: (selected) {
                setModalState(() {
                  _selectedGender = selected ? 'U' : null;
                });
              },
              selectedColor: Colors.black,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: _selectedGender == 'U' ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build the category filter section
  Widget _buildCategoryFilter(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ангилал',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<ClothesCategory>>(
          future: Provider.of<ClothesProvider>(context, listen: false)
              .getCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Text('Ангилал ачаалахад алдаа гарлаа');
            }

            final categories = snapshot.data ?? [];
            return Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Бүгд'),
                  selected: _selectedCategoryId == null,
                  onSelected: (selected) {
                    setModalState(() {
                      _selectedCategoryId = null;
                    });
                  },
                ),
                ...categories.map((category) => FilterChip(
                      label: Text(category.name),
                      selected: _selectedCategoryId == category.id,
                      onSelected: (selected) {
                        setModalState(() {
                          _selectedCategoryId = selected ? category.id : null;
                        });
                      },
                    )),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Build the apply filter button
  Widget _buildApplyFilterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedGender = _selectedGender;
            _selectedCategoryId = _selectedCategoryId;
          });
          _refreshClothes();
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Шүүлт хэрэглэх'),
      ),
    );
  }

  /// Handle user login navigation
  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  /// Handle user logout
  Future<void> _handleLogout() async {
    await Provider.of<AuthProvider>(context, listen: false).logout();
    if (!mounted) return;
    setState(() {}); // Refresh the UI
  }

  /// Navigate to add clothes screen
  void _navigateToAddClothes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddClothesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final backgroundColor = const Color.fromARGB(255, 10, 38, 46);
    final accentColor = const Color(0xFFE0E0E0);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Дэлгүүр',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
            tooltip: 'Шүүлт',
            color: Colors.white,
          ),
          if (authProvider.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _handleLogout,
              tooltip: 'Гарах',
              color: Colors.white,
            )
          else
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: _navigateToLogin,
              tooltip: 'Нэвтрэх',
              color: Colors.white,
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Хайх...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                filled: true,
                fillColor: const Color(0xFF1A3C2E),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: Container(
        color: backgroundColor,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _HomeContent(searchQuery: _searchQuery),
            const CartScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.2),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[800]!,
              hoverColor: Colors.grey[700]!,
              gap: 8,
              activeColor: Colors.white,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: const Color(0xFF0F594F),
              color: Colors.white,
              tabs: [
                const GButton(
                  icon: Icons.home_rounded,
                  text: 'Нүүр',
                ),
                const GButton(
                  icon: Icons.shopping_cart_rounded,
                  text: 'Сагс',
                ),
                if (authProvider.isAuthenticated)
                  const GButton(
                    icon: Icons.list_rounded,
                    text: 'Миний зар',
                  ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                if (index == 2 && !authProvider.isAuthenticated) {
                  _navigateToLogin();
                  return;
                }
                _onItemTapped(index);
              },
            ),
          ),
        ),
      ),
      floatingActionButton: authProvider.isAuthenticated && _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _navigateToAddClothes,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Зар нэмэх',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF0F594F),
              elevation: 4,
            )
          : null,
    );
  }
}

/// Private widget that displays the home content with clothes grid
class _HomeContent extends StatelessWidget {
  final String searchQuery;

  const _HomeContent({this.searchQuery = ''});

  /// Format price to ensure consistent display
  String _formatPrice(dynamic price) {
    if (price == null) return '0.00';
    if (price is num) return price.toStringAsFixed(2);
    if (price is String) {
      final numValue = double.tryParse(price);
      return numValue?.toStringAsFixed(2) ?? '0.00';
    }
    return '0.00';
  }

  Widget _buildFeaturedSection(
      BuildContext context, List<Map<String, dynamic>> clothes) {
    if (clothes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Онцлох бараанууд',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              // TextButton(
              //   onPressed: () {
              //     // TODO: Navigate to featured items
              //   },
              //   style: TextButton.styleFrom(
              //     foregroundColor: const Color(0xFF74C69D),
              //   ),
              //   child: Text(
              //     'Бүгдийг харах',
              //     style: GoogleFonts.lato(
              //       fontSize: 14,
              //       fontWeight: FontWeight.w500,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: clothes.length > 5 ? 5 : clothes.length,
            itemBuilder: (context, index) {
              final item = clothes[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildFeaturedCard(context, item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(
      BuildContext context, Map<String, dynamic> clothes) {
    final bool isSold = clothes['is_sold'] == true;
    
    return GestureDetector(
      onTap: isSold ? null : () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClothesDetailScreen(clothes: clothes),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        color: const Color(0xFF1A3C2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildItemImage(clothes),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3C2E),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clothes['title'] ?? 'No title',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isSold ? Colors.grey : Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${_formatPrice(clothes['price'])}',
                          style: TextStyle(
                            color: isSold ? Colors.grey : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildAddToCartButton(context, clothes),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (isSold)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'ЗАРАГДСАН',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F594F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Шинэ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClothesCard(BuildContext context, Map<String, dynamic> clothes) {
    final bool isSold = clothes['is_sold'] == true;
    
    return GestureDetector(
      onTap: isSold ? null : () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClothesDetailScreen(clothes: clothes),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        color: const Color(0xFF1A3C2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Hero(
                    tag: 'product_${clothes['id']}',
                    child: _buildItemImage(clothes),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3C2E),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clothes['title'] ?? 'No title',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isSold ? Colors.grey : Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${_formatPrice(clothes['price'])}',
                              style: TextStyle(
                                color: isSold ? Colors.grey : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Icon(
                              Icons.favorite_border,
                              color: isSold ? Colors.grey : Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildAddToCartButton(context, clothes),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (isSold)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'ЗАРАГДСАН',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            if (clothes['discount'] != null && clothes['discount'] > 0)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F594F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${clothes['discount']}% Хямдрал',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Ангилалууд',
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: Consumer<ClothesProvider>(
            builder: (context, clothesProvider, child) {
              if (clothesProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: clothesProvider.categories.length,
                itemBuilder: (context, index) {
                  final category = clothesProvider.categories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryItemsScreen(
                              category: category,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        color: const Color(0xFF1A3C2E),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: Colors.white24,
                            width: 1,
                          ),
                        ),
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getCategoryIcon(category.name),
                                size: 32,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  category.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'shirts':
        return Icons.checkroom;
      case 'pants':
        return Icons.accessibility_new;
      case 'shoes':
        return Icons.shopping_bag;
      case 'accessories':
        return Icons.watch;
      default:
        return Icons.category;
    }
  }

  Widget _buildEmptyState() {
    return Container(
      color: const Color.fromARGB(255, 10, 38, 46),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? 'Бараа байхгүй байна'
                  : '"$searchQuery" гэсэн хайлтад олдсонгүй',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClothesProvider>(
      builder: (context, clothesProvider, child) {
        if (clothesProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          );
        }

        if (clothesProvider.clothes.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await Provider.of<ClothesProvider>(context, listen: false)
                .loadClothes(searchQuery: searchQuery);
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeaturedSection(context, clothesProvider.clothes),
                _buildCategoriesSection(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All Items',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Show sorting options
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Sort'),
                      ),
                    ],
                  ),
                ),
                GridView.builder(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: clothesProvider.clothes.length,
                  itemBuilder: (context, index) {
                    final clothes = clothesProvider.clothes[index];
                    return _buildClothesCard(context, clothes);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build the item image
  Widget _buildItemImage(Map<String, dynamic> clothes) {
    return clothes['image_base64'] != null
        ? Image.memory(
            base64Decode(clothes['image_base64']),
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorImage();
            },
          )
        : _buildNoImage();
  }

  /// Build placeholder for when image fails to load
  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Icon(
          Icons.error_outline,
          size: 50,
          color: Colors.black,
        ),
      ),
    );
  }

  /// Build placeholder for when no image is available
  Widget _buildNoImage() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 50,
          color: Colors.black,
        ),
      ),
    );
  }

  /// Build add to cart button
  Widget _buildAddToCartButton(
      BuildContext context, Map<String, dynamic> clothes) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final bool isInCart = cartProvider.isInCart(clothes['id']);
        final bool isSold = clothes['is_sold'] == true;

        return SizedBox(
          width: double.infinity,
          height: 32,
          child: ElevatedButton.icon(
            onPressed: isSold || isInCart ? null : () => _addToCart(context, clothes),
            icon: Icon(
              isSold ? Icons.block : (isInCart ? Icons.check_circle : Icons.add_shopping_cart),
              size: 16,
              color: Colors.white,
            ),
            label: Text(
              isSold ? 'Зарагдсан' : (isInCart ? 'Нэмсэн' : 'Сагсанд нэмэх'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: isSold ? Colors.grey : (isInCart ? const Color(0xFF0F594F) : const Color(0xFF0F594F)),
              disabledBackgroundColor: isSold ? Colors.grey : const Color(0xFF0F594F),
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSold ? Colors.grey : (isInCart ? const Color(0xFF0F594F) : const Color(0xFF0F594F)),
                  width: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Add item to cart
  void _addToCart(BuildContext context, Map<String, dynamic> clothes) {
    Provider.of<CartProvider>(context, listen: false)
        .addToCart(context, clothes['id']);
  }
}
