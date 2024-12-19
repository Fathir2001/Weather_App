import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'SignUp.dart';
import 'SignIn.dart';
import 'HomePage.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _buttonController;
  late AnimationController _parallaxController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _parallaxController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _buttonController.dispose();
    _parallaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              // Animated particles
              ...List.generate(20, (index) => _buildParticle(index)),

              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Section with Weather Icons
                  Expanded(
                    flex: 2,
                    child: Stack(
                      children: [
                        _buildAnimatedIcon(
                            Icons.wb_sunny_outlined, 0.2, 0.2, Colors.amber),
                        _buildAnimatedIcon(
                            Icons.cloud_outlined, 0.7, 0.3, Colors.white),
                        _buildAnimatedIcon(Icons.water_drop_outlined, 0.4, 0.6,
                            Colors.lightBlue),
                      ],
                    ),
                  ),

                  // Middle Section
                  Expanded(
                    flex: 3,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: const Offset(0, 0),
                      ).animate(_fadeController),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.5)
                              ],
                            ).createShader(bounds),
                            child: const Icon(Icons.cloud, size: 120),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'ECOROUTE',
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.1),
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Your Personal Weather Companion',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Section
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScaleTransition(
                          scale: Tween(begin: 0.95, end: 1.0)
                              .animate(_buttonController),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                colors: [Colors.blue[700]!, Colors.blue[400]!],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignInPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15),
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Get Started',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Find the Bottom Section Column children and add after ElevatedButton:
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  );
                },
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(
      IconData icon, double left, double top, Color color) {
    return AnimatedBuilder(
      animation: _parallaxController,
      builder: (context, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * left +
              (math.sin(_parallaxController.value * math.pi * 2) * 10),
          top: MediaQuery.of(context).size.height * top +
              (math.cos(_parallaxController.value * math.pi * 2) * 10),
          child: FadeTransition(
            opacity: _fadeController,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 35,
                color: color,
              ),
            ),
          ),
        );
      },
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
