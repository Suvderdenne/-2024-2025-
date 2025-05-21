import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // Add this for File handling
import 'package:image_picker/image_picker.dart'; // Add this for image picking
import 'package:flutter/foundation.dart'; // Add this for kIsWeb

import 'package:career_choicer/Tools/post.dart';
import 'package:career_choicer/Tools/comment.dart';
import 'package:career_choicer/pages/create_post_widget.dart';
import 'package:career_choicer/pages/comment_input_widget.dart';

class PostScreen extends StatefulWidget {
  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<Post> posts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    if (!mounted) return; // Ensure the widget is still in the tree
    setState(() => isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Authentication token not found")),
        );
        setState(() => isLoading = false);
      }
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/posts/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List jsonData = jsonDecode(utf8.decode(response.bodyBytes)); // Decode response using UTF-8
        if (mounted) {
          setState(() {
            posts = jsonData.map((e) => Post.fromJson(e)).toList();
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch posts")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> toggleLike(int postId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) return;

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/posts/$postId/like/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 201 || response.statusCode == 204) {
      if (mounted) {
        setState(() {
          posts = posts.map((post) {
            if (post.id == postId) {
              return Post(
                id: post.id,
                title: post.title,
                content: post.content,
                image: post.image,
                video: post.video,
                username: post.username,
                likesCount: response.statusCode == 201
                    ? post.likesCount + 1
                    : post.likesCount - 1,
                isLiked: !post.isLiked,
                createdAt: post.createdAt,
              );
            }
            return post;
          }).toList();
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to toggle like")),
        );
      }
    }
  }

  Future<void> deletePost(int postId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) return;

    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/posts/$postId/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 204) {
      setState(() {
        posts.removeWhere((post) => post.id == postId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Post deleted")),
      );
    } else if (response.statusCode == 403) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You can only delete your own posts")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete post")),
      );
    }
  }

  Future<void> editPost(int postId, String newTitle, String newContent, File? newImage) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("token");

  if (token == null) return;

  var request = http.MultipartRequest('PUT', Uri.parse('http://127.0.0.1:8000/posts/$postId/edit/'));
  request.headers['Authorization'] = 'Bearer $token';

  request.fields['title'] = newTitle;
  request.fields['content'] = newContent;

  if (newImage != null) {
    request.files.add(await http.MultipartFile.fromPath('image', newImage.path));
  }

  final response = await request.send();

  if (response.statusCode == 200) {
    fetchPosts(); // Refresh posts to reflect the changes
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Post updated successfully")),
    );
  } else if (response.statusCode == 403) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("You can only edit your own posts")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to update post")),
    );
  }
}

  Future<List<Comment>> fetchComments(int postId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/posts/$postId/comments/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List jsonData = jsonDecode(utf8.decode(response.bodyBytes)); // Decode response using UTF-8
      return jsonData.map((e) => Comment.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  Future<void> replyToComment(int postId, int commentId, String replyContent) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) return;

final response = await http.post(
  Uri.parse('http://127.0.0.1:8000/posts/$postId/comments/$commentId/reply/'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({'content': replyContent}),
);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reply added successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add reply")),
      );
    }
  }

  void _showReplyDialog(int postId, int commentId) {
    TextEditingController replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Reply to Comment"),
          content: TextField(
            controller: replyController,
            decoration: InputDecoration(labelText: "Your Reply"),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await replyToComment(postId, commentId, replyController.text);
                Navigator.pop(context);
                fetchPosts(); // Refresh posts to update comments
              },
              child: Text("Reply"),
            ),
          ],
        );
      },
    );
  }

  void _showEditCommentDialog(int postId, Comment comment) {
    TextEditingController commentController = TextEditingController(text: comment.content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Comment"),
          content: TextField(
            controller: commentController,
            decoration: InputDecoration(labelText: "Your Comment"),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _editComment(postId, comment.id, commentController.text);
                Navigator.pop(context);
                fetchPosts(); // Refresh posts to update comments
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editComment(int postId, int commentId, String newContent) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) return;

    final response = await http.put(
      Uri.parse('http://127.0.0.1:8000/comments/$commentId/edit/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': newContent}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Comment updated successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update comment")),
      );
    }
  }

  Future<void> _deleteComment(int postId, int commentId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) return;

    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/comments/$commentId/delete/'), // Removed postId from the URL
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Comment deleted successfully")),
      );
      fetchPosts(); // Refresh posts to update comments
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete comment")),
      );
    }
  }

  Widget postCard(Post post) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    post.title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      showDialog(
                        context: context,
                        builder: (context) {
                          TextEditingController titleController =
                              TextEditingController(text: post.title);
                          TextEditingController contentController =
                              TextEditingController(text: post.content);
                          File? selectedImage;

                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                title: Text("Edit Post"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: titleController,
                                      decoration: InputDecoration(labelText: "Title"),
                                    ),
                                    TextField(
                                      controller: contentController,
                                      decoration: InputDecoration(labelText: "Content"),
                                      maxLines: 3,
                                    ),
                                    SizedBox(height: 10),
                                    if (selectedImage != null)
                                      kIsWeb
                                          ? Image.network(
                                              selectedImage!.path,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              selectedImage!,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                    TextButton.icon(
                                      onPressed: () async {
                                        final picker = ImagePicker();
                                        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                                        if (pickedFile != null) {
                                          setState(() {
                                            selectedImage = File(pickedFile.path);
                                          });
                                        }
                                      },
                                      icon: Icon(Icons.image),
                                      label: Text("Change Image"),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      editPost(post.id, titleController.text, contentController.text, selectedImage);
                                      Navigator.pop(context);
                                    },
                                    child: Text("Save"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    } else if (value == 'delete') {
                      deletePost(post.id);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),

            // Content
            Text(post.content),
            SizedBox(height: 12),

            // Image
            if (post.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.image!.startsWith('http')
                      ? post.image!
                      : 'http://127.0.0.1:8000${post.image!}',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 12),

            // Footer: User + Likes + Comments
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("By ${post.username}",
                        style: TextStyle(color: Colors.grey[700])),
                    SizedBox(height: 4),
                    Text("Posted: ${post.createdAt.toLocal().toString().split(' ')[0]}",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        post.isLiked ? Icons.favorite : Icons.favorite_border, // Toggle icon
                        color: post.isLiked ? Colors.redAccent : Colors.grey, // Toggle color
                      ),
                      onPressed: () => toggleLike(post.id),
                    ),
                    Text("${post.likesCount}"),
                    SizedBox(width: 16),
                    Icon(Icons.comment, size: 20, color: Colors.blue),
                    SizedBox(width: 4),
                    FutureBuilder<List<Comment>>(
                      future: fetchComments(post.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text("...");
                        } else if (snapshot.hasError) {
                          return Text("0");
                        } else {
                          return Text("${snapshot.data!.length}");
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),

            Divider(height: 24),

            // Comments Section
            FutureBuilder<List<Comment>>(
              future: fetchComments(post.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();

                final comments = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: comments.map((comment) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                comment.username,
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.reply, color: Colors.blue), // Reply icon
                                    onPressed: () {
                                      _showReplyDialog(post.id, comment.id);
                                    },
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showEditCommentDialog(post.id, comment);
                                      } else if (value == 'delete') {
                                        _deleteComment(post.id, comment.id);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => [
                                      PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(comment.content),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            CommentInputWidget(
              postId: post.id,
              onCommentAdded: fetchPosts,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Posts"),

        titleTextStyle: TextStyle(fontSize: 24, color: Colors.white),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text("Create New Post"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[700],
                      foregroundColor: Colors.white, // Set text color to white
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreatePostScreen(onPostCreated: fetchPosts),
                        ),
                      );
                      fetchPosts();
                    },
                  ),
                  SizedBox(height: 16),
                  ...posts.map(postCard).toList(),
                ],
              ),
            ),
    );
  }
}
