import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'drawer_menu.dart';
import 'driver_list_screen.dart';
import 'services/driver_data_service.dart';

class DriverMapScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Map<String, dynamic>? selectedDriver;

  const DriverMapScreen({
    Key? key,
    required this.userData,
    this.selectedDriver,
  }) : super(key: key);

  @override
  _DriverMapScreenState createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> with SingleTickerProviderStateMixin {
  late GoogleMapController mapController;
  LatLng _currentLocation = LatLng(47.921, 106.920); // Default to Ulaanbaatar coordinates
  Set<Marker> _markers = {};
  bool _driverCalled = false;
  Map<String, dynamic>? _nearestDriver;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  bool _isLoading = false;
  bool _mapError = false;
  List<Map<String, dynamic>> _calledDrivers = [];
  BitmapDescriptor? _driverIcon;
  List<Map<String, dynamic>> _drivers = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<double>(begin: 200, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _fetchLocation();
    _loadCustomIcon();
    _loadDrivers();

    // If selected driver is provided, set them as the nearest driver
    if (widget.selectedDriver != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _nearestDriver = widget.selectedDriver;
          _driverCalled = true;
          _calledDrivers.add(_nearestDriver!);
        });
        _animationController.forward();
        _callDriver();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomIcon() async {
    try {
      _driverIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)), 
        'assets/driver_icon.png',
      );
    } catch (e) {
      print('Error loading custom icon: $e');
      _driverIcon = BitmapDescriptor.defaultMarker;
    }
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isLoading = true;
      _mapError = false;
    });
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorDialog('Location services are disabled. Please enable them.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          _showErrorDialog('Location permissions are required to use this app.');
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      await _findNearestDriver(position);
      await _updateMarkers();
      
      if (mapController != null) {
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(_currentLocation, 15),
        );
      }
    } catch (e) {
      setState(() {
        _mapError = true;
      });
      _showErrorDialog('Error getting location: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Алдаа'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateMarkers() async {
    _markers.clear();
    
    // Add current location marker
    _markers.add(Marker(
      markerId: MarkerId("me"),
      position: _currentLocation,
      infoWindow: InfoWindow(title: "Таны байршил"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    ));

    // Add driver markers
    final drivers = await DriverDataService.getDrivers();
    for (var driver in drivers) {
      if (driver['lat'] != null && driver['lng'] != null) {
        _markers.add(Marker(
          markerId: MarkerId(driver['license_number']),
          position: LatLng(driver['lat'], driver['lng']),
          infoWindow: InfoWindow(
            title: '${driver['first_name']} ${driver['last_name']}',
            snippet: '${driver['car']} - ${driver['rating']} ★',
          ),
          icon: _driverIcon ?? BitmapDescriptor.defaultMarker,
        ));
      }
    }
  }

  Future<void> _findNearestDriver(Position position) async {
    final drivers = await DriverDataService.getDriversWithDistance(
      position.latitude,
      position.longitude,
    );
    
    if (drivers.isEmpty) return;

    final closest = drivers.reduce((a, b) => 
      a['distance'] < b['distance'] ? a : b
    );

    setState(() {
      _nearestDriver = closest;
    });
  }

  void _showDriverList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriverListScreen(
          currentLocation: _currentLocation,
          onDriverSelected: (driver) {
            setState(() {
              _nearestDriver = driver;
              _nearestDriver!['distance'] = Geolocator.distanceBetween(
                _currentLocation.latitude,
                _currentLocation.longitude,
                driver['lat'],
                driver['lng'],
              );
            });
            _callDriver();
          },
          userData: widget.userData,
        ),
      ),
    );
  }

  Future<void> _callDriver() async {
    if (_nearestDriver != null) {
      try {
        setState(() {
          _driverCalled = true;
          _calledDrivers.add(_nearestDriver!);
        });
        _animationController.forward();

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Жолооч дуудагдав"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${_nearestDriver?['first_name']} ${_nearestDriver?['last_name']} жолооч таны дуудлагад ирж байна."),
                SizedBox(height: 8),
                Text("Машин: ${_nearestDriver?['car']}"),
                Text("Үнэлгээ: ${_nearestDriver?['rating']} ★"),
                Text("Зай: ${(_nearestDriver!['distance'] / 1000).toStringAsFixed(2)} км"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showRatingDialog();
                },
                child: Text("Цуцлах"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
      } catch (e) {
        print('Error calling driver: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Жолооч дуудахад алдаа гарлаа')),
        );
      }
    }
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Шалтгаан"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Яагаад цуцлах вэ?"),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.timer),
              title: Text("Хэт удаан"),
              onTap: () {
                Navigator.pop(context);
                _cancelDriverCall("Хэт удаан");
              },
            ),
            ListTile(
              leading: Icon(Icons.money),
              title: Text("Үнэ өндөр"),
              onTap: () {
                Navigator.pop(context);
                _cancelDriverCall("Үнэ өндөр");
              },
            ),
            ListTile(
              leading: Icon(Icons.directions_car),
              title: Text("Машин тохирохгүй"),
              onTap: () {
                Navigator.pop(context);
                _cancelDriverCall("Машин тохирохгүй");
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Жолооч тохирохгүй"),
              onTap: () {
                Navigator.pop(context);
                _cancelDriverCall("Жолооч тохирохгүй");
              },
            ),
            ListTile(
              leading: Icon(Icons.more_horiz),
              title: Text("Бусад шалтгаан"),
              onTap: () {
                Navigator.pop(context);
                _cancelDriverCall("Бусад шалтгаан");
              },
            ),
          ],
        ),
      ),
    );
  }

  void _cancelDriverCall(String reason) {
    setState(() {
      _driverCalled = false;
      _calledDrivers.remove(_nearestDriver);
    });
    _animationController.reverse();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Дуудлага цуцлагдлаа"),
        content: Text("Шалтгаан: $reason"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard() {
    if (_nearestDriver == null || !_driverCalled) return SizedBox.shrink();

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Positioned(
          bottom: _slideAnimation.value,
          left: 16,
          right: 16,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          _nearestDriver!['first_name']?[0] ?? '?',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_nearestDriver!['first_name'] ?? 'Нэргүй'} ${_nearestDriver!['last_name'] ?? ''}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _nearestDriver!['car'] ?? 'Машин тодорхойгүй',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          Text(
                            _nearestDriver!['rating']?.toString() ?? '0.0',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Зай: ${(_nearestDriver!['distance'] / 1000).toStringAsFixed(2)} км",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          Text(
                            "Ирж байна",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              _showRatingDialog();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadDrivers() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final drivers = await DriverDataService.getDrivers();
      
      setState(() {
        _drivers = drivers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(userData: widget.userData),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text('Жолооч дуудах'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: _showDriverList,
            tooltip: 'Жолооч нарын жагсаалт',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_mapError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text('Газрын зураг ачаалахад алдаа гарлаа'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchLocation,
                    child: Text('Дахин оролдох'),
                  ),
                ],
              ),
            )
          else
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 15,
              ),
              onMapCreated: (controller) => mapController = controller,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'locate',
                  onPressed: _fetchLocation,
                  child: Icon(Icons.my_location),
                  backgroundColor: Colors.blue,
                ),
                SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'call',
                  onPressed: _driverCalled ? null : _callDriver,
                  child: Icon(Icons.directions_car),
                  backgroundColor: _driverCalled ? Colors.grey : Colors.green,
                ),
              ],
            ),
          ),
          _buildDriverCard(),
        ],
      ),
    );
  }
}
