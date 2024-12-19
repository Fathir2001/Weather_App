import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GPS extends StatefulWidget {
  const GPS({super.key});

  @override
  State<GPS> createState() => _GPSState();
}

class _GPSState extends State<GPS> {
  final String _latitude = "6.808700";
  final String _longitude = "79.993153";
  final String _accuracy = "100.0";

Future<void> _launchMaps() async {
  final Uri url = Uri.parse('https://www.google.com/maps?q=6.808700,79.993153');
  try {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
      webViewConfiguration: const WebViewConfiguration(enableJavaScript: true),
    )) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open maps. Please check if Google Maps is installed.'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _launchMaps,
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening maps: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'GPS Tracking',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                _buildGPSCard('Latitude', _latitude),
                const SizedBox(height: 16),
                _buildGPSCard('Longitude', _longitude),
                const SizedBox(height: 16),
                _buildGPSCard('Accuracy', '$_accuracy meters'),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _launchMaps,
                    icon: const Icon(Icons.location_on),
                    label: const Text('Open in Maps'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGPSCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}