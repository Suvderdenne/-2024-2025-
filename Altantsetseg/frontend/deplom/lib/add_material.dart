import 'package:flutter/material.dart';

class AddMaterialPage extends StatefulWidget {
  const AddMaterialPage({super.key});

  @override
  State<AddMaterialPage> createState() => _AddMaterialPageState();
}

class _AddMaterialPageState extends State<AddMaterialPage> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();

  bool isLoading = false;
  String? error;

  Future<void> submitMaterial() async {
    final name = nameController.text.trim();
    final desc = descController.text.trim();
    final price = double.tryParse(priceController.text) ?? 0;

    if (name.isEmpty || desc.isEmpty || price <= 0) {
      setState(() => error = 'Бүх талбарыг зөв бөглөнө үү');
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // API илгээх хэсгийг энд бичнэ
      await Future.delayed(const Duration(seconds: 2)); // mock delay
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Материал нэмэгдлээ')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => error = 'Алдаа гарлаа: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Материал нэмэх')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Нэр'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Тайлбар'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Үнэ'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: isLoading ? null : submitMaterial,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Нэмэх'),
            ),
          ],
        ),
      ),
    );
  }
}
