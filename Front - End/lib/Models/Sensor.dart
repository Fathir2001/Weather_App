class SensorData {
  final String temperature;
  final String humidity;
  final String rainfall;
  final String light;
  final String pressure;

  SensorData({
    this.temperature = '--',
    this.humidity = '--',
    this.rainfall = '--',
    this.light = '--',
    this.pressure = '--',
  });

  factory SensorData.fromString(String data) {
    try {
      final values = data.trim().split(',');
      if (values.length == 5) {
        return SensorData(
          temperature: '${double.parse(values[0]).toStringAsFixed(1)}°C',
          humidity: '${double.parse(values[1]).toStringAsFixed(1)}%',
          rainfall: values[2],
          light: values[3],
          pressure: '${double.parse(values[4]).toStringAsFixed(1)} hPa',
        );
      }
    } catch (e) {
      print('Error parsing sensor data: $e');
    }
    return SensorData();
  }
}