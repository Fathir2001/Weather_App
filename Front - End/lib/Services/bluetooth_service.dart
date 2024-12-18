import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:convert';
import '../Models/sensor_data.dart';

class BluetoothService {
  BluetoothDevice? device;
  final _dataController = StreamController<SensorData>.broadcast();
  bool isConnected = false;
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _stateSubscription;

  Stream<SensorData> get dataStream => _dataController.stream;
  
  get characteristics => null;

  Future<bool> _checkPermissions() async {
    if (await Permission.location.request().isGranted &&
        await Permission.bluetooth.request().isGranted &&
        await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      return true;
    }
    return false;
  }

  Future<void> initialize() async {
    try {
      _stateSubscription = FlutterBluePlus.adapterState.listen((state) {
        if (state == BluetoothAdapterState.off) {
          disconnect();
        }
      });
    } catch (e) {
      _dataController.addError('Initialization failed: $e');
    }
  }

  Future<void> connectToDevice() async {
    try {
      if (!await _checkPermissions()) {
        throw Exception('Required permissions not granted');
      }

      if (!await FlutterBluePlus.isOn) {
        throw Exception('Bluetooth is turned off');
      }

      await FlutterBluePlus.stopScan();
      _scanSubscription?.cancel();

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          if (r.device.localName.contains('Arduino')) {
            device = r.device;
            _connectToArduino();
            break;
          }
        }
      });

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 4),
        androidUsesFineLocation: true,
      );
    } catch (e) {
      _dataController.addError('Scanning failed: $e');
    }
  }

  Future<void> _connectToArduino() async {
    if (device == null) return;

    try {
      await FlutterBluePlus.stopScan();
      _scanSubscription?.cancel();

      _connectionSubscription?.cancel();
      _connectionSubscription = device!.connectionState.listen((state) {
        isConnected = state == BluetoothConnectionState.connected;
        if (!isConnected) {
          _reconnect();
        }
      });

      await device!.connect(timeout: const Duration(seconds: 4));
      isConnected = true;
      _discoverServices();
    } catch (e) {
      isConnected = false;
      _dataController.addError('Connection failed: $e');
    }
  }

  Future<void> _reconnect() async {
    if (!isConnected && device != null) {
      try {
        await device!.connect(timeout: const Duration(seconds: 4));
      } catch (e) {
        _dataController.addError('Reconnection failed: $e');
      }
    }
  }

  Future<void> _discoverServices() async {
    if (device == null) return;

    try {
      List<BluetoothService> services = (await device!.servicesList).cast<BluetoothService>();
      for (BluetoothService service in services) {
        var characteristics = service.characteristics;
        for (BluetoothCharacteristic characteristic in characteristics) {
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            characteristic.lastValueStream.listen(_handleData);
          }
        }
      }
    } catch (e) {
      _dataController.addError('Service discovery failed: $e');
    }
  }

  void _handleData(List<int> data) {
    try {
      final decoded = utf8.decode(data);
      final json = jsonDecode(decoded);
      final sensorData = SensorData.fromJson(json);
      _dataController.add(sensorData);
    } catch (e) {
      _dataController.addError('Data parsing failed: $e');
    }
  }

  Future<void> disconnect() async {
    try {
      await FlutterBluePlus.stopScan();
      if (device != null && isConnected) {
        await device!.disconnect();
      }
      isConnected = false;
    } catch (e) {
      _dataController.addError('Disconnection failed: $e');
    }
  }

  Future<void> dispose() async {
    try {
      _scanSubscription?.cancel();
      _connectionSubscription?.cancel();
      _stateSubscription?.cancel();
      await disconnect();
      await _dataController.close();
    } catch (e) {
      print('Disposal error: $e');
    }
  }
}