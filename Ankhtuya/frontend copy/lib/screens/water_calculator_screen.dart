import 'package:flutter/material.dart';

class WaterCalculatorScreen extends StatefulWidget {
  const WaterCalculatorScreen({super.key});

  @override
  State<WaterCalculatorScreen> createState() => _WaterCalculatorScreenState();
}

class _WaterCalculatorScreenState extends State<WaterCalculatorScreen> {
  final TextEditingController _potSizeController = TextEditingController();
  String _selectedPlantType = '';
  String _result = '';

  final Map<String, Map<String, dynamic>> _plantTypes = {
    'succulent': {
      'name': 'Шүүслэг ургамал',
      'waterRatio': 0.1,
      'frequency': '2-3 долоо хоногт нэг удаа',
    },
    'tropical': {
      'name': 'Тропик ургамал',
      'waterRatio': 0.2,
      'frequency': 'Долоо хоногт нэг удаа',
    },
    'cactus': {
      'name': 'Кактус',
      'waterRatio': 0.05,
      'frequency': '3-4 долоо хоногт нэг удаа',
    },
    'fern': {
      'name': 'Сэлэм',
      'waterRatio': 0.25,
      'frequency': '3-4 хоногт нэг удаа',
    },
    'monstera': {
      'name': 'Монстера',
      'waterRatio': 0.15,
      'frequency': 'Долоо хоногт нэг удаа',
    },
    'snake_plant': {
      'name': 'Могой ургамал',
      'waterRatio': 0.08,
      'frequency': '2-3 долоо хоногт нэг удаа',
    },
    'pothos': {
      'name': 'Потос',
      'waterRatio': 0.15,
      'frequency': 'Долоо хоногт нэг удаа',
    },
    'aloe': {
      'name': 'Алое',
      'waterRatio': 0.1,
      'frequency': '2-3 долоо хоногт нэг удаа',
    },
    'orchid': {
      'name': 'Орхидей',
      'waterRatio': 0.12,
      'frequency': 'Долоо хоногт нэг удаа',
    },
    'peace_lily': {
      'name': 'Энхтайвны лили',
      'waterRatio': 0.2,
      'frequency': 'Долоо хоногт нэг удаа',
    },
  };

  void _calculateWater() {
    if (_potSizeController.text.isEmpty || _selectedPlantType.isEmpty) {
      setState(() {
        _result = 'Бүх талбарыг бөглөнө үү';
      });
      return;
    }

    double potSize = double.tryParse(_potSizeController.text) ?? 0;
    var plantInfo = _plantTypes[_selectedPlantType]!;

    double waterAmount = potSize * plantInfo['waterRatio'];
    String frequency = plantInfo['frequency'];

    setState(() {
      _result = '${waterAmount.toStringAsFixed(1)} аяга ус $frequency';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Усны тооцоолуур',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Усны хэрэгцээг тооцоолох',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ургамлын дэлгэрэнгүй мэдээллийг оруулж оптималь услах хуваарийг тооцоолно уу.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _potSizeController,
              decoration: InputDecoration(
                labelText: 'Савны хэмжээ (см)', // Changed from inch to cm
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPlantType.isEmpty ? null : _selectedPlantType,
                  hint: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Ургамлын төрөл сонгоно уу'),
                  ),
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  items: _plantTypes.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value['name']),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPlantType = newValue ?? '';
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _calculateWater,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue.shade700,
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Тооцоолох'),
            ),
            if (_result.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.water_drop, color: Colors.blue.shade300),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _result,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Услах зөвлөмж',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTip('Услахаас өмнө хөрсний чийгшилийг шалгана уу'),
                  _buildTip('Өглөөний цагт услах нь хамгийн сайн'),
                  _buildTip(
                      'Улирлын болон агаарын чийгшилд тохируулан услана уу'),
                  _buildTip('Өрөөний температуртай ус ашиглана уу'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
