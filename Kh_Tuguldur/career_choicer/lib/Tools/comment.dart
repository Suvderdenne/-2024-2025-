class Comment {
  final int id;
  final String content;
  final String username;
  final String createdAt;
  final List<Comment> replies;
  final bool isOwnedByUser; // Add this property


  Comment({
    required this.id,
    required this.content,
    required this.username,
    required this.createdAt,
    required this.replies,
    this.isOwnedByUser = false, // Default to false
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      username: json['user']['username'],
      createdAt: json['created_at'],
      replies: (json['replies'] as List)
          .map((reply) => Comment.fromJson(reply))
          .toList(),
      isOwnedByUser: json['is_owned_by_user'] ?? false, // Default to false if not present
    );
  }
}
