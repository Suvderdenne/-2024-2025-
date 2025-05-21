class Post {
  final int id;
  final String title;
  final String content;
  final String? image;
  final String? video;
  final String username;
  final int likesCount;
  final bool isLiked; // Add this field
  final DateTime createdAt;
  
  
  
  

  Post({
    required this.id,
    required this.title,
    required this.content,
    this.image,
    this.video,
    required this.username,
    required this.likesCount,
    required this.isLiked, // Initialize this field
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'] ?? '',
      image: json['image'],
      video: json['video'],
      username: json['user']['username'],
      likesCount: json['likes_count'],
      isLiked: json['is_liked'] ?? false, // Default to false if not present
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
