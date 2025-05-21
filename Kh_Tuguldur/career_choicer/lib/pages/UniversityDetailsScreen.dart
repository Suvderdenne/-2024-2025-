import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For json.decode and base64Decode
import 'dart:typed_data'; // For Uint8List
import 'package:url_launcher/url_launcher.dart';

// Define the color scheme
const Color royalBlue = Color(0xFF4169E1); // A nice shade of Royal Blue
const Color softGrey = Color(0xFFF5F5F5); // A light, soft grey for background
const Color darkText = Color(0xFF333333); // Dark grey for primary text
const Color lightText = Color(0xFF757575); // Lighter grey for secondary text

class UniversityDetailsScreen extends StatefulWidget {
  final int universityId;
  UniversityDetailsScreen({required this.universityId, Key? key}) : super(key: key); // Added Key

  @override
  _UniversityDetailsScreenState createState() =>
      _UniversityDetailsScreenState();
}

class _UniversityDetailsScreenState extends State<UniversityDetailsScreen> {
  Map<String, dynamic>? universityDetails;
  bool _isLoading = true; // Track loading state
  String? _error; // Track fetch error

  @override
  void initState() {
    super.initState();
    fetchUniversityDetails();
  }

  // Fetch university details from the server
  Future<void> fetchUniversityDetails() async {
    setState(() {
      _isLoading = true; // Start loading
      _error = null; // Reset error on new fetch attempt
    });
    try {
      final response = await http.get(Uri.parse(
          'http://127.0.0.1:8000/universities/${widget.universityId}/'));

      if (response.statusCode == 200) {
        setState(() {
          // Decode response body safely, handling potential UTF-8 issues
          try {
            universityDetails = json.decode(utf8.decode(response.bodyBytes));
          } catch (e) {
            // Handle potential decoding errors (e.g., if not valid JSON)
            print("Error decoding JSON: $e");
            _error = "Failed to parse university data.";
          }
          _isLoading = false; // Stop loading on success
        });
      } else {
        // Handle HTTP errors (like 404, 500)
        print('Failed to load university details. Status code: ${response.statusCode}');
        setState(() {
          _error = 'Failed to load university details (Code: ${response.statusCode}).';
          _isLoading = false; // Stop loading on error
        });
      }
    } catch (e) {
      // Handle network errors (like no connection)
      print("Error fetching university details: $e");
      setState(() {
        _error = 'Network error. Please check your connection.';
        _isLoading = false; // Stop loading on error
      });
    }
  }

  // Method to open website in a browser
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString); // Use Uri.parse for safety
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) { // Updated launchUrl usage
      print('Could not launch $urlString');
      if (mounted) { // Check if the widget is still in the tree
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Could not open website: $urlString')),
         );
      }
    }
  }

  // Helper function to build the Base64 image widget
  Widget _buildBase64Image(String? base64Image) { // Allow null input
    // Default placeholder
    Widget placeholder = Container(
      height: 220, // Increased height slightly
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12), // Match card radius
      ),
      child: Center(
          child: Icon(Icons.school, size: 60, color: Colors.grey[500])), // Themed icon
    );

    if (base64Image == null || base64Image.isEmpty) {
      return placeholder;
    }

    try {
      // Ensure the base64 string is correctly formatted
      String base64Cleaned = base64Image;
      if (base64Image.contains(',')) {
         base64Cleaned = base64Image.split(',').last;
      }
      // Add padding if necessary
       base64Cleaned = base64.normalize(base64Cleaned);

      final Uint8List imageBytes = base64Decode(base64Cleaned);

      return ClipRRect(
        borderRadius: BorderRadius.circular(12.0), // Consistent rounding
        child: Image.memory(
          imageBytes,
          width: double.infinity,
          height: 220, // Match placeholder height
          fit: BoxFit.cover,
          // Add error builder for Image.memory
          errorBuilder: (context, error, stackTrace) {
             print("Error rendering base64 image: $error");
            return Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.red[100], // Softer error color
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                  child: Icon(Icons.broken_image, size: 60, color: Colors.red[700])),
            );
          },
        ),
      );
    } catch (e) {
      print("Error decoding base64 string: $e");
      return placeholder; // Show placeholder on decoding error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softGrey, // Use soft grey for the background
      appBar: AppBar(
        title: Text(universityDetails?['name'] ?? "University Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: royalBlue, // Royal blue AppBar
        foregroundColor: Colors.white, // Ensure back button icon is white
        elevation: 2.0, // Subtle elevation
      ),
      body: _buildBody(), // Use a helper method for the body
    );
  }

  // Helper method to build the body content based on state
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: royalBlue));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[700], size: 50),
              const SizedBox(height: 10),
              Text(
                _error!,
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
                 onPressed: fetchUniversityDetails, // Add a retry button
               ),
            ],
          ),
        ),
      );
    }

    if (universityDetails == null) {
      // Should ideally be covered by _error state, but as a fallback
      return const Center(child: Text("University details not available."));
    }

    // If data is loaded successfully
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // University Image (Base64)
          Center(child: _buildBase64Image(universityDetails!['image_base64'] as String?)), // Handle potential null
          const SizedBox(height: 24),

          // University Name - Centered, larger, royal blue
          Center(
            child: Text(
              universityDetails!['name'] ?? 'University Name',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28, // Larger font
                fontWeight: FontWeight.bold,
                color: royalBlue, // Use royal blue
              ),
            ),
          ),
          const SizedBox(height: 12),

          // University Description - Centered, readable grey
          Center(
            child: Text(
              universityDetails!['description'] ?? 'No description provided.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: lightText, // Lighter grey for description
                height: 1.5, // Improve line spacing
              ),
            ),
          ),
          const SizedBox(height: 24), // Increased spacing

          // University Details Section Header
          const Text(
            "Details",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: darkText),
          ),
          const SizedBox(height: 10),

          // University Details using the improved _infoCard
          _infoCard("🏆 Ranking", universityDetails!['ranking']?.toString() ?? 'N/A'), // Handle potential null
          _infoCard("📍 Location", universityDetails!['location'] ?? 'N/A'),
          _infoCard("💰 Est. Price", universityDetails!['price']?.toString() ?? 'N/A'), // Added Est. prefix
          _infoCard("🎓 Careers", (universityDetails!['career_names'] as List<dynamic>?)?.join(', ') ?? 'N/A'), // Handle null list

          const SizedBox(height: 24), // Increased spacing

           // Contact Information Section Header
          const Text(
            "Contact",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: darkText),
          ),
           const SizedBox(height: 10),
          _infoCard("📧 Email", universityDetails!['email'] ?? 'N/A'),
          _infoCard("📞 Phone", universityDetails!['phone'] ?? 'N/A'),


          const SizedBox(height: 30), // Increased spacing before button

          // Visit Website Button - Centered, styled
          if (universityDetails!['website'] != null && (universityDetails!['website'] as String).isNotEmpty)
             Center(
               child: ElevatedButton.icon(
                 icon: const Icon(Icons.open_in_new, color: Colors.white), // Changed icon
                 style: ElevatedButton.styleFrom(
                   backgroundColor: royalBlue, // Royal blue background
                   foregroundColor: Colors.white, // White text/icon
                   shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(8)), // Slightly rounded
                   padding: const EdgeInsets.symmetric(
                       horizontal: 25, vertical: 14), // More padding
                   textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold) // Bolder text
                 ),
                 onPressed: () {
                   _launchURL(universityDetails!['website']);
                 },
                 label: const Text("Visit Website"),
               ),
             )
           else
             const Center(child: Text("No website available.", style: TextStyle(color: lightText))),


          const SizedBox(height: 20), // Padding at the bottom
        ],
      ),
    );
  }

  // Card Widget for University Information - Refined Style
  Widget _infoCard(String title, String value) {
    return Card(
      color: Colors.white, // White card background
      margin: const EdgeInsets.only(bottom: 12), // Consistent spacing
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Softer rounding
      elevation: 2, // Subtle shadow
      shadowColor: Colors.grey.withOpacity(0.3), // Soft shadow color
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with specific styling
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: royalBlue, fontSize: 15), // Royal blue title
            ),
            const SizedBox(width: 12), // Consistent spacing

            // Value text - Expanded to wrap correctly
            Expanded(
              child: Text(
                value.isEmpty ? "N/A" : value, // Handle empty string case
                style: const TextStyle(fontSize: 15, color: darkText, fontWeight: FontWeight.w500), // Use dark text
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}