import 'package:libserialport/libserialport.dart';
import '../models/Sensor.dart';
import 'dart:io';

class ArduinoService {
  static const int BAUD_RATE = 9600;
  SerialPort? _port;
  SerialPortReader? _reader;
  
  Future<bool> connect() async {
    try {
      // Check DLL exists
      final dllPath = 'D:/Projects/Weather_App/Front - End/windows/flutter/ephemeral/serialport.dll';
      if (!File(dllPath).existsSync()) {
        throw Exception('serialport.dll not found. Please install Visual C++ Redistributable.');
      }
      
      dispose();
      
      final devices = SerialPort.availablePorts;
      print('Available ports: $devices');
      if (devices.isEmpty) return false;
      
      _port = SerialPort('COM5'); // Use specific port
      _port!.config = SerialPortConfig()
        ..baudRate = BAUD_RATE
        ..bits = 8
        ..stopBits = 1
        ..parity = SerialPortParity.none;
      
      final opened = _port!.openReadWrite();
      if (opened) {
        _reader = SerialPortReader(_port!);
        print('Connected to COM5');
      }
      return opened;
    } catch (e) {
      print('Connection error: $e');
      return false;
    }
  }

  Stream<SensorData>? getDataStream() {
    if (_reader == null) return null;
    
    return _reader!.stream.map((data) {
      final stringData = String.fromCharCodes(data).trim();
      print('Raw data: $stringData');
      
      if (stringData.isEmpty) return SensorData();
      return SensorData.fromString(stringData);
    }).where((data) => 
      data.temperature != '--' && 
      data.humidity != '--'
    );
  }

  void dispose() {
    _reader?.close();
    if (_port != null && _port!.isOpen) {
      _port!.close();
    }
    _port = null;
  }
}