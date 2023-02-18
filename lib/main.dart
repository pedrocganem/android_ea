import 'package:android_ea/gnss_location.dart';
import 'package:android_ea/location_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

import 'nmea_manager.dart';

//00001101-0000-1000-8000-00805f9b34fb -> Bad elf

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  static const channel = 'ecobot.bluetooth.channel';
  static const eventChannelPath = 'ecobot.bluetooth.event-channel';
  static const methodChannel = MethodChannel(channel);
  static const eventChannel = EventChannel(eventChannelPath);
  static const bluetoothSetup = "bluetooth_setup";

  final nmeaParser = NMEAManager();
  GNSSLocation gnssLocation = GNSSLocation();
  final location = Location();

  Future<void> initBluetooth() async {
    final permission = Permission.bluetooth.request();
    if (await permission.isGranted) {
      final result = await methodChannel.invokeMethod(bluetoothSetup);
      debugPrint(result);
    }
  }

  Stream<String> setupEventChannel() async* {
    eventChannel.receiveBroadcastStream().listen((event) {});
  }

  Future<void> getBondedDevices() async {
    var devices = await methodChannel.invokeMethod("discoverSupportedDevice");
    debugPrint(devices);
  }

  Future<void> connectToDevice() async {
    final result = await methodChannel.invokeMethod<String>("connectToDevice");
    debugPrint(result);
  }

  @override
  Widget build(BuildContext context) {
    location.onLocationChanged.listen(
      (event) => print(event.accuracy),
    );
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: StreamBuilder(
          stream: eventChannel.receiveBroadcastStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // final locationData = snapshot.data as LocationData;
              // print(locationData);
              print(snapshot.data);
              print("-------------//-----------------");

              final newData = nmeaParser.formatMessage(snapshot.data);
              if (newData != null) {
                gnssLocation = gnssLocation.merge(newData);
                gnssLocation = gnssLocation.formatValues(gnssLocation);
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Type: ${gnssLocation.receiverType}",
                      style: const TextStyle(fontSize: 22),
                    ),
                    Text(
                      "Latitute: ${gnssLocation.latitude! / 100}",
                      style: const TextStyle(fontSize: 22),
                    ),
                    Text(
                      "Longitude: ${gnssLocation.longitude! / 100}",
                      style: const TextStyle(fontSize: 22),
                    ),
                    Text(
                      "Altitude: ${gnssLocation.altitude}",
                      style: const TextStyle(fontSize: 22),
                    ),
                    Text(
                      "Accuracy: ${gnssLocation.accuracy}m",
                      style: const TextStyle(fontSize: 22),
                    ),
                    Text(
                      "Fix Quality: ${gnssLocation.fixQuality}",
                      style: const TextStyle(fontSize: 22),
                    ),
                    Text(
                      "PDOP: ${gnssLocation.pdop}",
                      style: const TextStyle(fontSize: 22),
                    ),
                    Text(
                      "Number of Satellites: ${gnssLocation.numberOfSatellites}",
                      style: const TextStyle(fontSize: 22),
                    ),
                  ],
                ),
              );
            }
            return const Text("No data");
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // final loc = await location.requestPermission();
          // print(loc);
          // final serv = await location.requestService();
          // print(serv);
          await initBluetooth();
          await getBondedDevices();
          await connectToDevice();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
