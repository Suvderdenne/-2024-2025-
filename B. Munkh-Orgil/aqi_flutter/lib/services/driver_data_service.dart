import 'package:geolocator/geolocator.dart';
import 'driver_service.dart';

class DriverDataService {
  static final DriverService _driverService = DriverService();

  static Future<List<Map<String, dynamic>>> getDrivers() async {
    return await _driverService.getDrivers();
  }

  static Future<List<Map<String, dynamic>>> getDriversWithDistance(double userLat, double userLng) async {
    final drivers = await _driverService.getDrivers();
    return drivers.map((driver) {
      final distance = Geolocator.distanceBetween(
        userLat,
        userLng,
        driver['lat'],
        driver['lng'],
      );
      return Map<String, dynamic>.from(driver)..['distance'] = distance;
    }).toList();
  }

  static Future<Map<String, dynamic>?> getDriverById(String id) async {
    return await _driverService.getDriverById(id);
  }
} 