import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/comment_service.dart';
import 'profile_page.dart';
import 'dart:convert';
import 'dart:ui';

class DetailPage extends StatefulWidget {
  final dynamic carPart;

  const DetailPage({Key? key, required this.carPart}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final CommentService _commentService = CommentService();
  List<Map<String, dynamic>> comments = [];
  bool _isLoading = false;
  bool _isLoadingComments = true;

  // Custom theme colors
  final Color primaryColor = const Color(0xFF0F1923);
  final Color accentColor = const Color(0xFFF58220);
  final Color bgColor = const Color(0xFFF5F7FA);
  final Color cardColor = Colors.white;
  final Color textPrimaryColor = const Color(0xFF2D3748);
  final Color textSecondaryColor = const Color(0xFF718096);

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      setState(() {
        _isLoadingComments = true;
      });

      final carPartId = widget.carPart['id'];
      final loadedComments = await _commentService.getComments(carPartId);

      setState(() {
        comments = loadedComments;
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingComments = false;
      });
      _showSnackBar('Сэтгэгдлүүдийг ачаалахад алдаа гарлаа: $e');
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final carPartId = widget.carPart['id'];
      final newComment = await _commentService.addComment(carPartId, text);

      setState(() {
        comments.add(newComment);
        _commentController.clear();
      });

      _showSnackBar('Сэтгэгдэл амжилттай нэмэгдлээ');
    } catch (e) {
      _showSnackBar('Сэтгэгдэл нэмэхэд алдаа гарлаа: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  String _getPropertyValue(String property) {
    // Handle Mongolian Unicode characters
    final mongolianKey = {
      'Нэр': '\u041d\u044d\u0440',
      'Үнэ': '\u04ae\u043d\u044d',
      'Төрөл': '\u0422\u04e9\u0440\u04e9\u043b',
      'Тайлбар': '\u0422\u0430\u0439\u043b\u0431\u0430\u0440',
      'Зураг': '\u0417\u0443\u0440\u0430\u0433',
      'Орсон_цаг': '\u041e\u0440\u0441\u043e\u043d_\u0446\u0430\u0433',
    };

    return widget.carPart[property] ??
        widget.carPart[mongolianKey[property] ?? ''] ??
        'Тодорхойгүй';
  }

  @override
  Widget build(BuildContext context) {
    final part = widget.carPart;

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => _showSnackBar('Хүслийн жагсаалтад нэмэгдлээ'),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _showSnackBar('Хуваалцах сонголтууд'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Hero image with gradient overlay
          SizedBox(
            height: 280,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Product image
                Image.network(
                  _getPropertyValue('Зураг'),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: primaryColor.withOpacity(0.8),
                      child: Center(
                        child: Icon(
                          Icons.car_repair,
                          size: 80,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    );
                  },
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        primaryColor.withOpacity(0.7),
                        primaryColor.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Product name overlay at bottom
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getPropertyValue('Нэр'),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3.0,
                              color: Color.fromARGB(150, 0, 0, 0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Price and brand chip
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '₮${_getPropertyValue('Үнэ')}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              part['brand'] is Map
                                  ? part['brand']['name'] ?? 'Тодорхойгүй'
                                  : part['brand']?.toString() ?? 'Тодорхойгүй',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(0),
              children: [
                // Specifications section
                _buildSection(
                  title: 'Дэлэгрэнгүй',
                  icon: Icons.info_outline,
                  child: Column(
                    children: [
                      _buildSpecificationItem(
                        'Төрөл',
                        _getPropertyValue('Төрөл'),
                        Icons.calendar_today,
                      ),
                      _buildSpecificationItem(
                        'Орсон огноо',
                        _getPropertyValue('Орсон_цаг'),
                        Icons.calendar_today,
                      ),
                      _buildSpecificationItem(
                        'Бэлэн байдал',
                        'Агуулахад бэлэн байгаа',
                        Icons.check_circle_outline,
                        valueColor: Colors.green,
                      ),
                    ],
                  ),
                ),

                // Description section
                _buildSection(
                  title: 'Бүтээгдэхүүний тайлбар',
                  icon: Icons.description_outlined,
                  child: Text(
                    _getPropertyValue('Тайлбар'),
                    style: TextStyle(
                      fontSize: 15,
                      color: textPrimaryColor,
                      height: 1.5,
                    ),
                  ),
                ),

                // Comment section
                _buildCommentSection(),

                // Call to action buttons
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showSnackBar(
                            'Дэлгэрэнгүй мэдээлэл авах утас: 80803193',
                          ),
                          icon: const Icon(Icons.phone),
                          label: const Text('Холбогдох'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showSnackBar('Захиалга амжилттай'),
                          icon: const Icon(Icons.shopping_cart_outlined),
                          label: const Text('Захиалах'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildSpecificationItem(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: textSecondaryColor),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? textPrimaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection() {
    return _buildSection(
      title: 'Сэтгэгдлүүд',
      icon: Icons.chat_bubble_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Сэтгэгдлээ энд бичнэ үү...',
                    hintStyle: TextStyle(color: textSecondaryColor),
                    fillColor: const Color.fromARGB(255, 232, 230, 230),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _isLoading ? null : _addComment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(14),
                  minimumSize: const Size(50, 56),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Сэтгэгдлүүд (${comments.length})',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textPrimaryColor,
            ),
          ),
          const SizedBox(height: 10),
          if (_isLoadingComments)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (comments.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              width: double.infinity,
              child: Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 40,
                    color: textSecondaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Одоогоор сэтгэгдэл алга',
                    style: TextStyle(
                      color: textSecondaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            )
          else
            ...comments.map((comment) => _buildCommentItem(comment)),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilePage(userId: comment['user']['id']),
                ),
              );
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  backgroundImage: comment['user_profile_picture'] != null
                      ? MemoryImage(
                          base64Decode(
                              comment['user_profile_picture'].split(',')[1]),
                          scale: 1.0,
                        )
                      : null,
                  child: comment['user_profile_picture'] == null
                      ? Text(
                          comment['user']['username'][0].toUpperCase(),
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment['user']['username'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textPrimaryColor,
                      ),
                    ),
                    Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(
                        DateTime.parse(comment['created_at']),
                      ),
                      style: TextStyle(fontSize: 12, color: textSecondaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            comment['text'],
            style: TextStyle(color: textPrimaryColor, height: 1.4),
          ),
        ],
      ),
    );
  }
}
