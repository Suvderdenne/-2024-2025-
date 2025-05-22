import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String placeName;

  const MapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.placeName,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  LatLng? userLocation;
  bool isLoading = true;
  late AnimationController _animationController;
  double? distanceToDestination;
  bool isMapTypeMenu = false;
  String currentMapType = 'standard';
  final mapLayerOptions = {
    'standard': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    'cycle':
        'https://c.tile.thunderforest.com/cycle/{z}/{x}/{y}.png?apikey=your_api_key',
    'transport':
        'https://c.tile.thunderforest.com/transport/{z}/{x}/{y}.png?apikey=your_api_key',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _getUserLocation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          !serviceEnabled ||
          permission == LocationPermission.denied) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final userLatLng = LatLng(position.latitude, position.longitude);

      // Calculate distance
      const Distance distance = Distance();
      final placeLocation = LatLng(widget.latitude, widget.longitude);
      final meters = distance.as(LengthUnit.Meter, userLatLng, placeLocation);

      setState(() {
        userLocation = userLatLng;
        isLoading = false;
        distanceToDestination = meters;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _recenterMap(MapController mapController) {
    final placeLocation = LatLng(widget.latitude, widget.longitude);
    mapController.move(placeLocation, 14);
  }

  void _toggleMapTypeMenu() {
    setState(() {
      isMapTypeMenu = !isMapTypeMenu;
    });
  }

  void _changeMapType(String mapType) {
    setState(() {
      currentMapType = mapType;
      isMapTypeMenu = false;
    });
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    } else {
      return '${meters.toInt()} m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final placeLocation = LatLng(widget.latitude, widget.longitude);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.placeName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 3.0,
                color: Color.fromARGB(100, 0, 0, 0),
              ),
            ],
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.black87,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.layers),
              color: Colors.black87,
              onPressed: _toggleMapTypeMenu,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : FlutterMapWithControls(
                placeLocation: placeLocation,
                userLocation: userLocation,
                distanceToDestination: distanceToDestination,
                primaryColor: primaryColor,
                accentColor: accentColor,
                isDarkMode: isDarkMode,
                recenterMap: _recenterMap,
                animationController: _animationController,
                mapUrlTemplate: mapLayerOptions[currentMapType]!,
                formatDistance: _formatDistance,
                placeName: widget.placeName,  
              ),

          // Map type selection menu
          if (isMapTypeMenu)
            Positioned(
              top: 80,
              right: 10,
              child: Container(
                width: 160,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MapTypeButton(
                      title: 'Standard',
                      isSelected: currentMapType == 'standard',
                      onTap: () => _changeMapType('standard'),
                    ),
                    MapTypeButton(
                      title: 'Cycling',
                      isSelected: currentMapType == 'cycle',
                      onTap: () => _changeMapType('cycle'),
                    ),
                    MapTypeButton(
                      title: 'Transport',
                      isSelected: currentMapType == 'transport',
                      onTap: () => _changeMapType('transport'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton:
          isLoading
              ? null
              : FloatingActionButtonBar(
                userLocation: userLocation,
                distanceToDestination: distanceToDestination,
                formatDistance: _formatDistance,
              ),
    );
  }
}

class MapTypeButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const MapTypeButton({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        color: isSelected ? Colors.grey.withOpacity(0.2) : Colors.transparent,
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check, size: 18, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}

class FlutterMapWithControls extends StatelessWidget {
  final LatLng placeLocation;
  final LatLng? userLocation;
  final double? distanceToDestination;
  final Color primaryColor;
  final Color accentColor;
  final bool isDarkMode;
  final Function(MapController) recenterMap;
  final AnimationController animationController;
  final String mapUrlTemplate;
  final String Function(double) formatDistance;
  final String placeName;

  const FlutterMapWithControls({
    super.key,
    required this.placeLocation,
    required this.userLocation,
    required this.distanceToDestination,
    required this.primaryColor,
    required this.accentColor,
    required this.isDarkMode,
    required this.recenterMap,
    required this.animationController,
    required this.mapUrlTemplate,
    required this.formatDistance,
    required this.placeName,
  });

  @override
  Widget build(BuildContext context) {
    final mapController = MapController();

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: placeLocation,
        initialZoom: 14,
        minZoom: 3,
        maxZoom: 18,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        // Custom Tile Layer
        TileLayer(
          urlTemplate: mapUrlTemplate,
          userAgentPackageName: 'com.example.app',
          tileProvider: NetworkTileProvider(),
        ),

        // Polyline - Path from user to destination
        if (userLocation != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: [userLocation!, placeLocation],
                color: accentColor.withOpacity(0.8),
                strokeWidth: 4,
              ),
            ],
          ),

        // Circle around destination
        CircleLayer(
          circles: [
            CircleMarker(
              point: placeLocation,
              radius: 30.0,
              color: primaryColor.withOpacity(0.15),
              borderColor: primaryColor.withOpacity(0.7),
              borderStrokeWidth: 2.0,
            ),
          ],
        ),

        // Marker Layer
        MarkerLayer(
          markers: [
            // Destination location marker
            Marker(
              point: placeLocation,
              width: 60,
              height: 60,
              alignment: Alignment.bottomCenter,
              child: LocationPinWidget(
                color: Colors.red,
                label: placeName,
              ),
            ),
            // User location marker
            if (userLocation != null)
              Marker(
                point: userLocation!,
                width: 40,
                height: 40,
                child: AnimatedBuilder(
                  animation: animationController,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer animated pulse
                        Container(
                          width:
                              40 *
                              (0.6 +
                                  0.4 *
                                      math.sin(
                                        animationController.value * math.pi,
                                      )),
                          height:
                              40 *
                              (0.6 +
                                  0.4 *
                                      math.sin(
                                        animationController.value * math.pi,
                                      )),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Inner circle
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue, width: 3),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),

        // Map Controls Panel
        Positioned(
          right: 16,
          bottom: 100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    mapController.move(
                      mapController.camera.center,
                      mapController.camera.zoom + 1,
                    );
                  },
                ),
                Container(height: 1, width: 20, color: Colors.grey[300]),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    mapController.move(
                      mapController.camera.center,
                      mapController.camera.zoom - 1,
                    );
                  },
                ),
                Container(height: 1, width: 20, color: Colors.grey[300]),
                IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: () {
                    if (userLocation != null) {
                      mapController.move(userLocation!, 15);
                    }
                  },
                ),
                Container(height: 1, width: 20, color: Colors.grey[300]),
                IconButton(
                  icon: const Icon(Icons.location_searching),
                  onPressed: () => recenterMap(mapController),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class LocationPinWidget extends StatelessWidget {
  final Color color;
  final String label;

  const LocationPinWidget({
    super.key,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label.length > 20 ? '${label.substring(0, 17)}...' : label,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Icon(
          Icons.location_on,
          color: color,
          size: 36,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 3,
              offset: const Offset(1, 1),
            ),
          ],
        ),
      ],
    );
  }
}

class FloatingActionButtonBar extends StatelessWidget {
  final LatLng? userLocation;
  final double? distanceToDestination;
  final String Function(double) formatDistance;

  const FloatingActionButtonBar({
    super.key,
    required this.userLocation,
    required this.distanceToDestination,
    required this.formatDistance,
  });

  @override
  Widget build(BuildContext context) {
    // Show info panel only if we have user location and can calculate distance
    if (userLocation == null || distanceToDestination == null) {
      return FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Getting your location...')),
          );
        },
        child: const Icon(Icons.refresh),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_walk, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            formatDistance(distanceToDestination!),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Here you could launch navigation app or show directions
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Starting navigation...')),
              );
            },
            icon: const Icon(Icons.navigation),
            label: const Text('Navigate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
