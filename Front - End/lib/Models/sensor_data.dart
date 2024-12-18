class SensorData {
  final double temperature;
  final double humidity;
  final String rainCondition;
  final String lightCondition;
  final double pressure;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.rainCondition,
    required this.lightCondition,
    required this.pressure,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: json['temperature']?.toDouble() ?? 0.0,
      humidity: json['humidity']?.toDouble() ?? 0.0,
      rainCondition: json['rainCondition'] ?? 'Unknown',
      lightCondition: json['lightCondition'] ?? 'Unknown',
      pressure: json['pressure']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'humidity': humidity,
    'rainCondition': rainCondition,
    'lightCondition': lightCondition,
    'pressure': pressure,
  };
}