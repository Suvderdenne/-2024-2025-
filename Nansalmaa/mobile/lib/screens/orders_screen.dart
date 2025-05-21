import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _apiService = ApiService();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await _apiService.getOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load orders: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No orders yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        final items = order['cart']['items'] as List;
        
        return Card(
          margin: const EdgeInsets.all(8),
          child: ExpansionTile(
            title: Text('Order #${order['id']}'),
            subtitle: Text(
              '${order['status_display']} - \$${order['total_amount']}',
              style: TextStyle(
                color: _getStatusColor(order['status']),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Items
                    const Text(
                      'Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...items.map((item) {
                      final clothes = item['clothes'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(clothes['title']),
                            ),
                            Text('x${item['quantity']}'),
                            const SizedBox(width: 16),
                            Text('\$${(clothes['price'] * item['quantity']).toStringAsFixed(2)}'),
                          ],
                        ),
                      );
                    }),
                    const Divider(),
                    
                    // Shipping Details
                    const Text(
                      'Shipping Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Name: ${order['shipping_name']}'),
                    Text('Phone: ${order['shipping_phone']}'),
                    Text('Address: ${order['shipping_address']}'),
                    const Divider(),
                    
                    // Order Details
                    const Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Order Date: ${_formatDate(order['created_at'])}'),
                    Text('Status: ${order['status_display']}'),
                    Text('Payment Status: ${order['payment_status_display']}'),
                    if (order['paid_at'] != null)
                      Text('Paid: ${_formatDate(order['paid_at'])}'),
                    if (order['shipped_at'] != null)
                      Text('Shipped: ${_formatDate(order['shipped_at'])}'),
                    if (order['delivered_at'] != null)
                      Text('Delivered: ${_formatDate(order['delivered_at'])}'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
} 