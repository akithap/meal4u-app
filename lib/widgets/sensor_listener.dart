import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/light_sensor_service.dart';

class SensorListener extends StatefulWidget {
  final Widget child;
  const SensorListener({super.key, required this.child});

  @override
  State<SensorListener> createState() => _SensorListenerState();
}

class _SensorListenerState extends State<SensorListener> {
  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _lightSubscription;
  final LightSensorService _lightSensorService = LightSensorService();
  DateTime _lastToggle = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initSensors();
  }

  void _initSensors() {
    // 1. Connectivity
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      if (results.contains(ConnectivityResult.none)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No Internet Connection'),
            backgroundColor: Colors.red,
            duration: Duration(days: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });

    // 2. Light Sensor (Mobile & Web via Service)
    try {
      _lightSubscription = _lightSensorService.luxStream.listen((lux) {
        if (DateTime.now().difference(_lastToggle).inSeconds > 2) {
          final themeProvider = Provider.of<ThemeProvider>(
            context,
            listen: false,
          );
          final isDark = lux < 10; // Dark mode if < 10 lux

          if (isDark && themeProvider.themeMode == ThemeMode.light) {
            themeProvider.updateThemeFromSensor(true);
            _lastToggle = DateTime.now();
          } else if (!isDark && themeProvider.themeMode == ThemeMode.dark) {
            themeProvider.updateThemeFromSensor(false);
            _lastToggle = DateTime.now();
          }
        }
      });
    } catch (e) {
      debugPrint("Light Sensor Init Failed: $e");
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _lightSubscription?.cancel();
    _lightSensorService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
