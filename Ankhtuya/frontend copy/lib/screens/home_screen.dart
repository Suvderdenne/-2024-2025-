import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../components/category_tabs.dart';
import '../components/featured_slider.dart';
import '../components/popular_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? selectedCategoryId;
  int activePage = 0;

  final PageController controller = PageController(); // default

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> plants = [];
  List<Map<String, dynamic>> allPlants = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final fetchedCategories = await fetchCategories();
    final fetchedPlants = await fetchPlants();

    setState(() {
      categories = fetchedCategories;
      selectedCategoryId = 0;
      allPlants = fetchedPlants;
    });

    filterPlants();
  }

  void filterPlants() {
    if (selectedCategoryId == 0 || selectedCategoryId == null) {
      plants = List<Map<String, dynamic>>.from(allPlants);
    } else {
      plants = allPlants
          .where((plant) => plant['category'] == selectedCategoryId)
          .toList();
    }
    setState(() {});
  }

  static Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/categories/'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      List<Map<String, dynamic>> categoryList = List<Map<String, dynamic>>.from(
        data.map((item) => item as Map<String, dynamic>),
      );
      categoryList.insert(0, {"id": 0, "name": "Бүгд"});
      return categoryList;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchPlants() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/plants/'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(
        data.map((item) => item as Map<String, dynamic>),
      );
    } else {
      throw Exception('Failed to load plants');
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),

            // Category Tabs
            if (categories.isEmpty)
              const Center(child: Text("Ангиллууд олдсонгүй"))
            else
              CategoryTabs(
                categories: categories,
                selectedCategoryId: selectedCategoryId!,
                onCategorySelected: (categoryId) {
                  setState(() {
                    selectedCategoryId = categoryId;
                    filterPlants();
                  });
                },
              ),

            const SizedBox(height: 20),

            // Plant Slider and List
            if (plants.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("Ургамал олдсонгүй"),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FeaturedSlider(
                    plants: plants,
                    activePage: activePage,
                    onPageChanged: (val) => setState(() => activePage = val),
                  ),
                  const SizedBox(height: 30),
                  PopularSection(plants: plants),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
