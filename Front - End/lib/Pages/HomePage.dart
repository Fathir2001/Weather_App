import 'package:flutter/material.dart';
import 'package:weather_app/Pages/Notification.dart';
import 'package:weather_app/Pages/Notification_service.dart';

import 'dart:math' as math;
import 'dart:async';
import 'gps.dart';

class WeatherData {
  final double temperature;
  final double humidity;
  final int rainVal;
  final String rainCondition;
  final String lightCondition;
  final double pressure;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.rainVal,
    required this.rainCondition,
    required this.lightCondition,
    required this.pressure,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _weatherStateIndex = 0;
  int _refreshCount = 0;
  late AnimationController _fadeController;
  late AnimationController _cardController;
  WeatherData? _currentWeather;
  bool _isLoading = false;

  final List<WeatherData> weatherStates = [
    WeatherData(
      temperature: 29.80,
      humidity: 92.00,
      rainVal: 1535,
      rainCondition: 'No Rain',
      lightCondition: 'Low Brightness',
      pressure: 1023.33,
    ),
    WeatherData(
      temperature: 29.80,
      humidity: 92.00,
      rainVal: 1535,
      rainCondition: 'No Rain',
      lightCondition: 'High Brightness',
      pressure: 1023.33,
    ),
    WeatherData(
      temperature: 29.80,
      humidity: 92.00,
      rainVal: 1535,
      rainCondition: 'Moderate Rain',
      lightCondition: 'Low Brightness',
      pressure: 1023.33,
    ),
    WeatherData(
      temperature: 29.80,
      humidity: 92.00,
      rainVal: 1535,
      rainCondition: 'Heavy Rain',
      lightCondition: 'Low Brightness',
      pressure: 1023.33,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _currentWeather = weatherStates[0];
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _updateWeatherData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _weatherStateIndex = (_weatherStateIndex + 1) % weatherStates.length;
      _currentWeather = weatherStates[_weatherStateIndex];
      _isLoading = false;
      _refreshCount++;

      if (_refreshCount == 1) {
        NotificationService.addNotification(
          'The Garbage Truck is in 500 m distance',
          'Medium',
          Icons.directions_car,
        );
      } else if (_refreshCount == 2) {
        NotificationService.addNotification(
          'The Garbage Truck is in 100 m distance',
          'High',
          Icons.directions_car,
        );
        _refreshCount = 0; // Reset counter
      }
    });
  }

  String _getDisplayValue(String type) {
    if (_currentWeather == null) return '--';

    switch (type) {
      case 'Temperature':
        return '${_currentWeather!.temperature}°C';
      case 'Humidity':
        return '${_currentWeather!.humidity}%';
      case 'Rainfall':
        return _currentWeather!.rainCondition;
      case 'Light':
        return _currentWeather!.lightCondition;
      case 'Pressure':
        return '${_currentWeather!.pressure} hPa';
      default:
        return '--';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: const Text(
          'Weather Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: NotificationService.hasNewNotifications,
            builder: (context, hasNew, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      NotificationService.hasNewNotifications.value = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificationPage()),
                      );
                    },
                  ),
                  if (hasNew)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _updateWeatherData,
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF64B5F6),
                    Color(0xFF42A5F5),
                    Colors.white,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    ...List.generate(20, (index) => _buildParticle(index)),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 30),
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio:
                                    constraints.maxWidth > 600 ? 1.3 : 1.1,
                                children: [
                                  _buildWeatherCard(
                                    'Temperature',
                                    Icons.thermostat,
                                    Colors.orange,
                                    0.2,
                                  ),
                                  _buildWeatherCard(
                                    'Humidity',
                                    Icons.water_drop,
                                    Colors.blue,
                                    0.3,
                                  ),
                                  _buildWeatherCard(
                                    'Rainfall',
                                    Icons.umbrella,
                                    Colors.indigo,
                                    0.4,
                                  ),
                                  _buildWeatherCard(
                                    'Light',
                                    Icons.light_mode,
                                    Colors.amber,
                                    0.5,
                                  ),
                                  _buildWeatherCard(
                                    'Pressure',
                                    Icons.speed,
                                    Colors.green,
                                    0.6,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          : const GPS(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Weather',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'GPS',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildWeatherCard(
    String title,
    IconData icon,
    Color color,
    double delay,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _cardController,
        curve: Interval(delay, delay + 0.2, curve: Curves.easeOut),
      )),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                _getDisplayValue(title),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black54,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticle(int index) {
    final random = math.Random(index);
    final top = random.nextDouble() * MediaQuery.of(context).size.height;
    final left = random.nextDouble() * MediaQuery.of(context).size.width;
    final opacity = random.nextDouble() * 0.6;

    return Positioned(
      top: top,
      left: left,
      child: FadeTransition(
        opacity: _fadeController,
        child: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
