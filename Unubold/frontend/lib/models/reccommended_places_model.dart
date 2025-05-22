import 'package:uuid/uuid.dart';

class ReccommendedPlacesModel {
  final String id;
  final String name;
  final String image;
  final double rating;
  final String location;
  final String description;
  final String phoneNumber;
  final String hotelRating;
  final List<String> images;
  final String type;

  ReccommendedPlacesModel({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.location,
    required this.description,
    required this.phoneNumber,
    required this.hotelRating,
    required this.type,
    this.images = const [],
  });

  factory ReccommendedPlacesModel.fromJson(Map<String, dynamic> json) {
    // Handle main image URL
    String mainImage = json['image'] is String ? json['image'] : '';
    if (mainImage.isNotEmpty && !mainImage.startsWith('http')) {
      mainImage = 'http://127.0.0.1:8000${mainImage.startsWith('/') ? '' : '/'}$mainImage';
    }

    // Process gallery images
    List<String> galleryImages = [];
    if (json['images'] != null && json['images'] is List) {
      for (var img in json['images']) {
        if (img is String) {
          // If image is directly a string
          String imgUrl = img;
          if (!imgUrl.startsWith('http')) {
            imgUrl = 'http://127.0.0.1:8000${imgUrl.startsWith('/') ? '' : '/'}$imgUrl';
          }
          galleryImages.add(imgUrl);
        } else if (img is Map && img['image'] is String) {
          // If image is an object with 'image' property
          String imgUrl = img['image'];
          if (!imgUrl.startsWith('http')) {
            imgUrl = 'http://127.0.0.1:8000${imgUrl.startsWith('/') ? '' : '/'}$imgUrl';
          }
          galleryImages.add(imgUrl);
        }
      }
    }

    return ReccommendedPlacesModel(
      id: json['id']?.toString() ?? const Uuid().v4(),
      name: json['name']?.toString() ?? 'Unknown Place',
      image: mainImage,
      rating: json['rating'] is int ? json['rating'].toDouble() : 
             json['rating'] is double ? json['rating'] : 0.0,
      location: json['location']?.toString() ?? 'Unknown Location',
      description: json['description']?.toString() ?? 'No description available',
      phoneNumber: json['phone_number']?.toString() ?? 'Not available',
      hotelRating: json['hotel_rating']?.toString() ?? 'Not rated',
      images: galleryImages,
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'rating': rating,
      'location': location,
      'description': description,
      'phone_number': phoneNumber,
      'hotel_rating': hotelRating,
      'images': images,
    };
  }
}