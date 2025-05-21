import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WorkerMadeListPage extends StatefulWidget {
  final int workerId;

  const WorkerMadeListPage({Key? key, required this.workerId})
      : super(key: key);

  @override
  _WorkerMadeListPageState createState() => _WorkerMadeListPageState();
}

class _WorkerMadeListPageState extends State<WorkerMadeListPage> {
  List<dynamic> madeWorks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMadeByWorker();
  }

  Future<void> fetchMadeByWorker() async {
    // Use your machine's IP address if testing on a real device
    final url =
        Uri.parse('http://127.0.0.1:8000/made/worker/${widget.workerId}/');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          madeWorks = data['made_works'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load made works');
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildMadeCard(Map<String, dynamic> made) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (made['made_image'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  made['made_image'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Text("Image failed to load"),
                ),
              )
            else
              const Text("No image available"),
            const SizedBox(height: 8),
            Text("👤 Артист: ${made['worker_name']}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("💇 Үйлчилгээ: ${made['service_category']}"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ажилчдын хийсэн бүтээл",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 218, 175, 249),
        iconTheme: IconThemeData(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
        toolbarHeight: 70,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : madeWorks.isEmpty
              ? const Center(child: Text("Бүтээл байхгүй байна."))
              : ListView.builder(
                  itemCount: madeWorks.length,
                  itemBuilder: (context, index) {
                    return buildMadeCard(madeWorks[index]);
                  },
                ),
    );
  }
}
