import 'dart:convert';
import 'dart:typed_data'; // For Uint8List
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Define the color scheme
const Color royalBlue = Color(0xFF4169E1); // Or Color(0xFF0D47A1) for a deeper blue
const Color softGrey = Color(0xFFF5F5F5);
const Color white = Colors.white;
const Color darkText = Color(0xFF333333);
const Color lightText = Color(0xFF757575);

class CareerDetailScreen extends StatefulWidget {
  final String careerName; // Used for AppBar title initially
  final String careerId;

  CareerDetailScreen(
      {required this.careerName, required this.careerId, Key? key}) // Added Key
      : super(key: key);

  @override
  _CareerDetailScreenState createState() => _CareerDetailScreenState();
}

class _CareerDetailScreenState extends State<CareerDetailScreen> {
  Map<String, dynamic>? careerDetails;
  bool _isLoading = true; // Renamed for clarity
  String? _error; // To store error messages

  @override
  void initState() {
    super.initState();
    fetchCareerDetails();
  }

  // --- Helper Functions ---

  // Decode Base64 Image (copied from previous examples)
  Uint8List? decodeBase64Image(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    String processedString = base64String;
    if (processedString.startsWith('data:image')) {
      processedString =
          processedString.substring(processedString.indexOf(',') + 1);
    }
    try {
      return base64Decode(base64.normalize(processedString));
    } catch (e) {
      print('Error decoding base64 image: $e');
      return null;
    }
  }

  // Build Image Placeholder (copied from previous examples)
  Widget _buildImagePlaceholder({double height = 200}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0), // Consistent rounding
      ),
      child: Center(
          child: Icon(Icons.work_outline, // Career related icon
              size: 50,
              color: Colors.grey[400])),
    );
  }

  // --- Data Fetching ---
  Future<void> fetchCareerDetails() async {
    // Ensure state is reset before fetching
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/career-details/${widget.careerId}/'),
      );

      if (!mounted) return; // Check again after async gap

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          careerDetails = data;
          _isLoading = false;
        });
      } else {
         // Throw specific error based on status code
         throw Exception('Failed to load details (Code: ${response.statusCode})');
      }
    } catch (e) {
       print("Error fetching career details: $e");
       if (mounted) {
         setState(() {
           _isLoading = false;
           _error = e.toString().replaceFirst('Exception: ', ''); // Store error message
         });
         // Keep SnackBar as an additional notification if desired, but primary error shown in body
         // ScaffoldMessenger.of(context).showSnackBar(
         //   SnackBar(content: Text('Error: $_error'), backgroundColor: Colors.red),
         // );
       }
    }
  }

  // --- Build Methods ---
  @override
  Widget build(BuildContext context) {
    // Determine AppBar title - Use fetched title if available, otherwise fallback
    String appBarTitle = widget.careerName; // Default
    if (!_isLoading && careerDetails != null) {
       appBarTitle = careerDetails?['career']?['career'] ?? widget.careerName;
    }

    return Scaffold(
      backgroundColor: softGrey, // Use soft grey background
      appBar: AppBar(
        title: Text(appBarTitle, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: royalBlue, // Use royal blue
        foregroundColor: white, // Ensure text/icons are white
        elevation: 2.0,
      ),
      body: _buildDetailBody(),
    );
  }

  Widget _buildDetailBody() {
    // 1. Loading State
    if (_isLoading) {
       return const Center(child: CircularProgressIndicator(color: royalBlue));
    }

    // 2. Error State
    if (_error != null) {
       return Center(
         child: Padding(
           padding: const EdgeInsets.all(20.0),
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Icon(Icons.error_outline, color: Colors.red[600], size: 50),
               const SizedBox(height: 10),
               Text(
                 "Error: $_error",
                 textAlign: TextAlign.center,
                 style: TextStyle(color: Colors.red[700], fontSize: 16),
               ),
               const SizedBox(height: 20),
               ElevatedButton.icon(
                  icon: Icon(Icons.refresh, color: Colors.white),
                  label: Text("Retry", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: royalBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: fetchCareerDetails, // Add a retry button
                ),
             ],
           ),
         ),
       );
     }

    // 3. No Data State (after loading, if details are still null)
    if (careerDetails == null) {
       return Center(
         child: Padding(
           padding: const EdgeInsets.all(20.0),
           child: Text(
             'Career details not found.',
             style: TextStyle(fontSize: 16, color: lightText),
           ),
         ),
       );
     }

    // 4. Data Loaded State
    Uint8List? imageBytes = decodeBase64Image(careerDetails!['image_base64'] as String?);
    String displayTitle = careerDetails!['career']?['career'] ?? 'Career Details'; // Title for body content

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Image ---
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0), // Consistent rounding
              child: imageBytes != null
                  ? Image.memory(
                      imageBytes,
                      width: double.infinity,
                      height: 220, // Adjusted height
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImagePlaceholder(height: 220),
                    )
                  : _buildImagePlaceholder(height: 220),
            ),
          ),

          // --- Main Title ---
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              displayTitle,
              style: TextStyle(
                 fontSize: 26, // Prominent title
                 fontWeight: FontWeight.bold,
                 color: royalBlue, // Use royal blue
              ),
            ),
          ),

          // --- Details Card ---
          _buildInfoCard(
            children: [
               _buildDetailItem(
                 'Тайлбар', // Description (Mongolian)
                 careerDetails!['description'],
                 icon: Icons.info_outline
               ),
               _buildDetailItem(
                 'Дундаж цалин', // Average Salary (Mongolian)
                 careerDetails!['salary'] != null ? '\$${careerDetails!['salary']}' : null, // Add '$' prefix
                  icon: Icons.attach_money
               ),
               _buildDetailItem(
                 'Preparation Time',
                 careerDetails!['preparationTime'],
                  icon: Icons.timer_outlined
               ),
               _buildDetailItem(
                 'Үүрэг', // Purpose/Role (Mongolian)
                 careerDetails!['purpose'],
                  icon: Icons.checklist_rtl_outlined
               ),
            ],
          ),
           const SizedBox(height: 20),

          // --- Related Courses Card ---
          _buildRelatedSection(
            'Related Courses',
             careerDetails!['course'], // Expects List<dynamic>
             Icons.school_outlined, // Icon for courses
          ),
           const SizedBox(height: 20),

          // --- Related Universities Card ---
          _buildRelatedSection(
            'Related Universities',
             careerDetails!['university'], // Expects List<dynamic>
             Icons.account_balance_outlined, // Icon for universities
          ),
           const SizedBox(height: 20), // Padding at the bottom
        ],
      ),
    );
  }

  // Helper to build styled cards for grouping info
  Widget _buildInfoCard({required List<Widget> children}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 0), // Margin handled by SizedBox outside
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: white, // White background for card
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: children,
        ),
      ),
    );
  }


  // Refined detail item display (now using Row for better alignment)
  Widget _buildDetailItem(String title, String? value, {IconData? icon}) {
    final String displayValue = value != null && value.isNotEmpty ? value : 'Not available';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0), // Increased vertical padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
             Icon(icon, size: 20, color: royalBlue),
             const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   title,
                   style: TextStyle(
                      fontSize: 16, // Slightly smaller title
                      fontWeight: FontWeight.w600, // Bold title
                      color: royalBlue, // Use royal blue for title
                   ),
                 ),
                 const SizedBox(height: 5), // Space between title and value
                 Text(
                   displayValue,
                   style: TextStyle(
                      fontSize: 15, // Standard text size
                      color: darkText, // Use dark text color for value
                      height: 1.4 // Improve line spacing for longer text
                   ),
                 ),
               ],
             ),
          ),
        ],
      ),
    );
  }

  // Refined related section display, wrapped in a Card
  Widget _buildRelatedSection(String title, List<dynamic>? items, IconData sectionIcon) {
    if (items == null || items.isEmpty) return const SizedBox.shrink(); // Don't show if empty

    return _buildInfoCard( // Use the card builder
       children: [
          // Section Header inside the card
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
               children: [
                 Icon(sectionIcon, size: 22, color: royalBlue),
                 const SizedBox(width: 10),
                 Text(
                   title,
                   style: const TextStyle(
                      fontSize: 18, // Section title size
                      fontWeight: FontWeight.bold,
                      color: royalBlue, // Use royal blue
                   ),
                 ),
               ],
             ),
          ),
          // List of items
          ...items.map((item) {
             // Assuming item is a Map with a 'name' key
             final name = (item is Map && item.containsKey('name')) ? item['name'] as String? : 'Unnamed Item';
             final displayName = name != null && name.isNotEmpty ? name : 'Unnamed Item';

             return Padding(
               padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0), // Indent items
               child: Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Text('• ', style: TextStyle(color: royalBlue, fontWeight: FontWeight.bold)), // Bullet point
                   Expanded(
                     child: Text(
                        displayName,
                        style: TextStyle(fontSize: 15, color: darkText, height: 1.4),
                     ),
                   ),
                 ],
               ),
             );
          }).toList(),
       ],
     );
  }
}