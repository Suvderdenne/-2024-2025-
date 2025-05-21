import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;
import 'driver_map_screen.dart';
import 'services/driver_data_service.dart';

class DriverListScreen extends StatefulWidget {
  final LatLng currentLocation;
  final Function(Map<String, dynamic>) onDriverSelected;
  final Map<String, dynamic> userData;

  const DriverListScreen({
    Key? key,
    required this.currentLocation,
    required this.onDriverSelected,
    required this.userData,
  }) : super(key: key);

  @override
  State<DriverListScreen> createState() => _DriverListScreenState();
}

class _DriverListScreenState extends State<DriverListScreen> {
  List<Map<String, dynamic>> _driversWithDistance = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedZoneIndex = 0;

  final List<Map<String, dynamic>> zones = [
    {
      'name': 'A бүс',
      'price': 25000,
      'places': [
        '6н буудал, Оргил худалдааны төв',
        '21р хороолол, Толгойтын уулзвар',
        'Сутайн буянт, техникийн зах',
        'Яармаг, British school',
        'Зайсан',
        'Маршалын гүүр',
        'Цагдаагийн академи',
        'Да хүрээ техникийн зах',
      ],
    },
    {
      'name': 'B бүс',
      'price': 30000,
      'places': [
        'Зунжин',
        'Бэлх зуслан',
        'Амгалан, MCS үйлдвэр',
        'Маршалын гүүр',
        'Нүхтийн ам',
        'Нисэх тойрог',
        'Моносын уулзвар, Тэс ШТС',
        'Баян хошуу, Жанцан',
      ],
    },
    {
      'name': 'C бүс',
      'price': 35000,
      'places': [
        'Шарга морьт, Жигжид уулзвар',
        'Хужир Булан, 15ын буудал',
        'Хуучир улиастай гүүр',
        'Риверсайд амралт',
        'Нүхт ам, Танан өргөө',
        'Буянт ухаа, DHL',
        'Хуучин 22 товчоо, Оргил сүпер маркет',
        'Зүүн салаа, СБД 25р хороо',
      ],
    },
    {
      'name': 'D бүс',
      'price': 40000,
      'places': [
        'Өвөр Гүнт',
        'Гачуурт хүлэмж',
        'Баянзүрх товчоо,EFES',
        'Залаатын ам',
        'Нүхт Hotel&Resort',
        'Төв аймгийн зам, МТ ШТС',
        'Хуучин 22, Wellmart supermarket',
        'Зүүн салааны шинэ эцэс',
      ],
    },  
    {
      'name': 'E бүс',
      'price': 45000,
      'places': [
        'Майхан толгой автобусны буудал',
        'Гачуурт цагаан дэлгүүр',
        'Ургах наран хороолол',
        'Асем вилла',
        'Жаргалантын ам салдаг',
        'G Мобайл Arena',
        'Сонгиний тойрог',
        'Гүнтийн эцэс',
      ],
    },
    {
      'name': 'F бүс',
      'price': 65000,
      'places': [
        'Хандгайт',
        'Гачуурт эцэс',
        'Хонхорын Содмонгол ШТС',
        'Чулуут Скай Вилла',
        'Жаргалантын Амын адаг',
        'Өлзийт хороолол, 190р цэцэрлэг',
        'Эмээлтийн пост',
        'Гүнтийн давааны хойд тал',
      ],
    },
    {
      'name': 'G бүс',
      'price': 85000,
      'places': [
        'Санзай Вилла',
        'Гачуурт хүлэмж автобус буудал',
        'Налайх Оргилын зүүн тал',
        'Налайх тойрог',
        'Монгол Кувейтын Судалгааны хойд тал',
        'Өлзийт 9 буудал, Шувуун фабрик',
        'Эмээлт',
        'Цагаан өргөө амралтын зүүн тал',
      ],
    },
    {
      'name': 'H бүс',
      'price': 110000,
      'places': [
        'Сэлбэ голын эх',
        '',
        '',
        'Баян өртөө',
        'Төв аймаг, Спорт цогцолбор',
        '7р хэсгийн автобус буудал',
        'Хүй 7 худаг салдаг',
        'Sunshine Villa',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final drivers = await DriverDataService.getDriversWithDistance(
        widget.currentLocation.latitude,
        widget.currentLocation.longitude,
      );
      
      setState(() {
        _driversWithDistance = drivers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getInitial(String? name) {
    if (name == null || name.isEmpty) return '?';
    return name[0].toUpperCase();
  }

  Widget _buildStarDiagram(List<String> places) {
    // Only for A zone, show the star diagram with places
    if (places.isEmpty) return SizedBox(height: 80);
    // Place names in 8 directions
    final List<Widget> starLabels = [
      Positioned(top: 0, left: 0, right: 0, child: Center(child: Text(places[0], textAlign: TextAlign.center, style: TextStyle(fontSize: 12)))),
      Positioned(top: 40, left: 0, child: Align(alignment: Alignment.centerLeft, child: Text(places[1], textAlign: TextAlign.left, style: TextStyle(fontSize: 12)))),
      Positioned(top: 80, left: 0, child: Align(alignment: Alignment.centerLeft, child: Text(places[2], textAlign: TextAlign.left, style: TextStyle(fontSize: 12)))),
      Positioned(bottom: 40, left: 0, child: Align(alignment: Alignment.centerLeft, child: Text(places[3], textAlign: TextAlign.left, style: TextStyle(fontSize: 12)))),
      Positioned(bottom: 0, left: 0, right: 0, child: Center(child: Text(places[4], textAlign: TextAlign.center, style: TextStyle(fontSize: 12)))),
      Positioned(bottom: 40, right: 0, child: Align(alignment: Alignment.centerRight, child: Text(places[5], textAlign: TextAlign.right, style: TextStyle(fontSize: 12)))),
      Positioned(top: 80, right: 0, child: Align(alignment: Alignment.centerRight, child: Text(places[6], textAlign: TextAlign.right, style: TextStyle(fontSize: 12)))),
      Positioned(top: 40, right: 0, child: Align(alignment: Alignment.centerRight, child: Text(places[7], textAlign: TextAlign.right, style: TextStyle(fontSize: 12)))),
    ];
    return SizedBox(
      height: 160,
      child: Stack(
        children: [
          // Star lines
          Center(
            child: CustomPaint(
              size: Size(120, 120),
              painter: _StarPainter(),
            ),
          ),
          ...starLabels,
        ],
      ),
    );
  }

  Widget _buildZoneSelector() {
    final selectedZone = zones[_selectedZoneIndex];
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                'Бүсчлэл ба дуудлагын хөлс',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${selectedZone['name']} - ${selectedZone['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₮',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SizedBox(height: 16),
              _buildStarDiagram(selectedZone['places'] as List<String>),
              SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.8,
                ),
                itemCount: zones.length,
                itemBuilder: (context, index) {
                  final zone = zones[index];
                  final isSelected = _selectedZoneIndex == index;
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        )
                      ] : null,
                    ),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
                        side: BorderSide(
                          color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedZoneIndex = index;
                        });
                      },
                      child: Text(
                        '${zone['name']} - ${zone['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₮',
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Жолооч нарын жагсаалт',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDrivers,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadDrivers,
                        icon: Icon(Icons.refresh),
                        label: Text('Дахин оролдох'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : _driversWithDistance.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Жолооч олдсонгүй',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildZoneSelector(),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _driversWithDistance.length,
                            itemBuilder: (context, index) {
                              final driver = _driversWithDistance[index];
                              
                              return Card(
                                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DriverMapScreen(
                                          userData: widget.userData,
                                          selectedDriver: driver,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundColor: Theme.of(context).primaryColor,
                                          child: Text(
                                            _getInitial(driver['first_name']),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${driver['first_name'] ?? 'Нэргүй'} ${driver['last_name'] ?? ''}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              if (driver['phone_number'] != null)
                                                Text(
                                                  'Утас: ${driver['phone_number']}',
                                                  style: TextStyle(color: Colors.grey[600]),
                                                ),
                                              if (driver['license_number'] != null)
                                                Text(
                                                  'Жолоочийн үнэмлэх: ${driver['license_number']}',
                                                  style: TextStyle(color: Colors.grey[600]),
                                                ),
                                              if (driver['location'] != null)
                                                Text(
                                                  'Байршил: ${driver['location']}',
                                                  style: TextStyle(color: Colors.grey[600]),
                                                ),
                                              Text(
                                                'Зай: ${(driver['distance'] / 1000).toStringAsFixed(2)} км',
                                                style: TextStyle(
                                                  color: Theme.of(context).primaryColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: driver['is_verified'] == true
                                                    ? Colors.green.withOpacity(0.1)
                                                    : Colors.orange.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    driver['is_verified'] == true
                                                        ? Icons.verified
                                                        : Icons.pending,
                                                    color: driver['is_verified'] == true
                                                        ? Colors.green
                                                        : Colors.orange,
                                                    size: 16,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    driver['is_verified'] == true
                                                        ? 'Баталгаажсан'
                                                        : 'Хүлээгдэж буй',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: driver['is_verified'] == true
                                                          ? Colors.green
                                                          : Colors.orange,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
    );
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.2;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * math.pi / 180;
      final dx = center.dx + radius * 0.95 * math.cos(angle);
      final dy = center.dy + radius * 0.95 * math.sin(angle);
      canvas.drawLine(center, Offset(dx, dy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 