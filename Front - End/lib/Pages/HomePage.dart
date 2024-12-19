import 'package:flutter/material.dart';
import 'dart:math' as math;
// import 'package:libserialport/libserialport.dart';
import '../models/Sensor.dart';
import '../Services/Arduino.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _cardController;
  final ArduinoService _arduinoService = ArduinoService();
  SensorData _sensorData = SensorData();
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeArduino();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  Future<void> _initializeArduino() async {
    try {
      final connected = await _arduinoService.connect();
      setState(() => _isConnected = connected);
      
      if (connected) {
        _arduinoService.getDataStream()?.listen(
          (data) {
            setState(() => _sensorData = data);
          },
          onError: (error) {
            print('Stream error: $error');
            setState(() => _isConnected = false);
          }
        );
      }
    } catch (e) {
      print('Initialization error: $e');
      setState(() => _isConnected = false);
      
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Connection Error'),
          content: const Text('Please ensure Visual C++ Redistributable is installed'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    _cardController.reset();
    _cardController.forward();
    _arduinoService.dispose();
    await _initializeArduino();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF64B5F6), Color(0xFF42A5F5), Colors.white],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              ...List.generate(20, (index) => _buildParticle(index)),
              _buildMainContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Weather Dashboard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: constraints.maxWidth > 600 ? 1.3 : 1.1,
                children: [
                  _buildWeatherCard('Temperature', Icons.thermostat, Colors.orange, 0.2),
                  _buildWeatherCard('Humidity', Icons.water_drop, Colors.blue, 0.3),
                  _buildWeatherCard('Rainfall', Icons.umbrella, Colors.indigo, 0.4),
                  _buildWeatherCard('Light', Icons.light_mode, Colors.amber, 0.5),
                  _buildWeatherCard('Pressure', Icons.speed, Colors.green, 0.6),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeatherCard(String title, IconData icon, Color color, double delay) {
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
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              if (!_isConnected)
                const Text('Connecting...', style: TextStyle(color: Colors.grey))
              else
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

  String _getDisplayValue(String type) {
    switch (type) {
      case 'Temperature': return _sensorData.temperature;
      case 'Humidity': return _sensorData.humidity;
      case 'Rainfall': return _sensorData.rainfall;
      case 'Light': return _sensorData.light;
      case 'Pressure': return _sensorData.pressure;
      default: return '--';
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _cardController.dispose();
    _arduinoService.dispose();
    super.dispose();
  }
}