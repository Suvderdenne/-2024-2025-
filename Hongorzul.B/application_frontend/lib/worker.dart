import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'made.dart'; // Make sure this import is correct

class WorkerPage extends StatefulWidget {
  @override
  _WorkerPageState createState() => _WorkerPageState();
}

class _WorkerPageState extends State<WorkerPage> {
  bool isGrid = true;
  List<dynamic> workers = [];

  @override
  void initState() {
    super.initState();
    fetchWorkers();
  }

  Future<void> fetchWorkers() async {
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:8000/worker/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          workers = data;
        });
      } else {
        throw Exception(
            'Failed to load workers. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching workers: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Container for "Хаяг байрлал"
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 218, 175, 249),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Center(
              child: Text(
                "Ажилтан",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: isGrid
                ? GridView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: workers.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      String imageUrl = workers[index]['worker_image'] != null
                          ? 'http://127.0.0.1:8000${workers[index]['worker_image']}'
                          : 'https://via.placeholder.com/150';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkerMadeListPage(
                                workerId: workers[index]['worker_id'],
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Image.network(imageUrl,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                child: Column(
                                  children: [
                                    Text(
                                      '${workers[index]['wfirst']} ${workers[index]['wname']}',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                              255, 218, 175, 249)),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      workers[index]['role_name'] ?? 'Role',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    Text(
                                      workers[index]['bname'] ?? 'Branch',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: workers.length,
                    itemBuilder: (context, index) {
                      String imageUrl = workers[index]['worker_image'] != null
                          ? 'http://127.0.0.1:8000${workers[index]['worker_image']}'
                          : 'https://via.placeholder.com/180';

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(imageUrl,
                                width: 50, height: 50, fit: BoxFit.cover),
                          ),
                          title: Text(
                            '${workers[index]['wfirst']} ${workers[index]['wname']}',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workers[index]['role_name'] ?? '',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                workers[index]['bname'] ?? '',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WorkerMadeListPage(
                                  workerId: workers[index]['worker_id'],
                                ),
                              ),
                            );
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
