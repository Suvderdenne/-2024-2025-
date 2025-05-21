import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:light/light.dart';

class LightMeterScreen extends StatefulWidget {
  const LightMeterScreen({super.key});

  @override
  State<LightMeterScreen> createState() => _LightMeterScreenState();
}

class _LightMeterScreenState extends State<LightMeterScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  double _lux = 0;
  String _lightDescription = 'Loading...';
  StreamSubscription<int>? _lightSubscription;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && Platform.isAndroid) {
      _initializeCamera();
      _startLightSensor();
    } else {
      setState(() {
        _lightDescription = 'Not supported on Web';
        _lux = 0;
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(camera, ResolutionPreset.medium);
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Camera error: $e');
    }
  }

  void _startLightSensor() {
    final light = Light();
    _lightSubscription = light.lightSensorStream.listen((luxValue) {
      setState(() {
        _lux = luxValue.toDouble();
        _lightDescription = _getLightCondition(_lux);
      });
    }, onError: (err) {
      print('Light sensor error: $err');
    });
  }

  String _getLightCondition(double lux) {
    if (lux < 100) {
      return 'Dark\nLow light';
    } else if (lux < 1000) {
      return 'Indirect sunlight\nBright, no direct sun';
    } else {
      return 'Full Sun\nDirect sunlight';
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _lightSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasTwoLines = _lightDescription.contains('\n');
    final title =
        hasTwoLines ? _lightDescription.split('\n')[0] : _lightDescription;
    final subtitle = hasTwoLines ? _lightDescription.split('\n')[1] : '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 8),
            kIsWeb
                ? const Icon(Icons.cloud_off, size: 100, color: Colors.grey)
                : (_isCameraInitialized
                    ? ClipOval(
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: CameraPreview(_cameraController!),
                        ),
                      )
                    : const CircularProgressIndicator()),
            const SizedBox(height: 24),
            Text(
              'Light Level: ${_lux.toStringAsFixed(0)} lux',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ]
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
