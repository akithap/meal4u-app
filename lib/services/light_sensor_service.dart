import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:light_sensor/light_sensor.dart';

class LightSensorService {
  final StreamController<double> _luxStreamController =
      StreamController<double>.broadcast();
  StreamSubscription? _subscription;

  LightSensorService() {
    _initSensor();
  }

  Stream<double> get luxStream => _luxStreamController.stream;

  void _initSensor() {
    if (kIsWeb) {
      // Web support removed to avoid dart:html conflicts on mobile
      debugPrint(
        "LightSensorService: Web not supported in this mobile-optimized version.",
      );
      return;
    }
    _initMobileSensor();
  }

  void _initMobileSensor() {
    try {
      // Using light_sensor package (version 3.0.2)
      // Lux is typically an int from this package
      LightSensor.hasSensor().then((hasSensor) {
        if (hasSensor) {
          _subscription = LightSensor.luxStream().listen((lux) {
            _luxStreamController.add(lux.toDouble());
          });
        } else {
          debugPrint("LightSensorService: No sensor found on device");
        }
      });
    } catch (e) {
      debugPrint('Mobile Light Sensor Error: $e');
    }
  }

  void dispose() {
    _subscription?.cancel();
    _luxStreamController.close();
  }
}
