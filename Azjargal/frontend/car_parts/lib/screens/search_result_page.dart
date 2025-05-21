import 'package:car_parts/screens/detail_page.dart';
import 'package:flutter/material.dart';

class SearchResultsPage extends StatelessWidget {
  final String searchQuery;
  final List<dynamic> results;

  const SearchResultsPage({
    Key? key,
    required this.searchQuery,
    required this.results,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('"$searchQuery" хайлтын үр дүн')),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final item = results[index];
          // Handle both escaped and unescaped field names
          final name =
              item['Нэр'] ?? item['\u041d\u044d\u0440'] ?? 'Нэр олдсонгүй';
          final price = item['Үнэ'] ?? item['\u04ae\u043d\u044d'] ?? '0';
          final image = item['Зураг'] ?? item['\u0417\u0443\u0440\u0430\u0433'];
          final type = item['Төрөл'] ?? item['\u0422\u04e9\u0440\u04e9\u043b'];

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: image != null
                  ? Image.network(
                      image,
                      width: 50,
                      height: 50,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.image_not_supported),
                    )
                  : Icon(Icons.image),
              title: Text(name),
              subtitle: Text('₮$price • $type'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailPage(carPart: item)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
