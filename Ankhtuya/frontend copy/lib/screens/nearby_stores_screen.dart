import 'package:flutter/material.dart';

class NearbyStoresScreen extends StatelessWidget {
  const NearbyStoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> stores = [
      {
        'name': 'Ногоон Эрдэм Цэцэрлэг',
        'address': '123 Ургамал гудамж, Хот',
        'distance': '0.5 км',
        'rating': 4.8,
        'open': true,
      },
      {
        'name': 'Ботаник Дэлгүүр',
        'address': '456 Цэцэрлэг өргөө, Хот',
        'distance': '1.2 км',
        'rating': 4.6,
        'open': true,
      },
      {
        'name': 'Ургамлын Парадайз',
        'address': '789 Навч зам, Хот',
        'distance': '2.0 км',
        'rating': 4.9,
        'open': false,
      },
      {
        'name': 'Хотын Ой',
        'address': '321 Ногоон гудамж, Хот',
        'distance': '2.5 км',
        'rating': 4.7,
        'open': true,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Ойролцоох Дэлгүүрүүд',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border(
                bottom: BorderSide(
                  color: Colors.green.shade100,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.green.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Одоогийн байршил',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Хот, Аймаг',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Implement location refresh
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Шинэчлэх'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: stores.length,
              itemBuilder: (context, index) {
                final store = stores[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.store,
                        color: Colors.green.shade700,
                      ),
                    ),
                    title: Text(
                      store['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          store['address'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              store['rating'].toString(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              store['distance'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (store['open'] as bool)
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        (store['open'] as bool) ? 'Нээлттэй' : 'Хаалттай',
                        style: TextStyle(
                          fontSize: 12,
                          color: (store['open'] as bool)
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    onTap: () {
                      // TODO: Implement store details navigation
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 