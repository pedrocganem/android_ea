import 'package:android_ea/gnss_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  static const channel = 'ecobot.bluetooth.channel';
  static const eventChannelPath = 'ecobot.bluetooth.event-channel';
  static const methodChannel = MethodChannel(channel);
  static const eventChannel = EventChannel(eventChannelPath);
  static const bluetoothSetup = "bluetooth_setup";

  final nmeaParser = NmeaRawParser();
  GNSSLocation gnssLocation = GNSSLocation();

  Future<void> initBluetooth() async {
    final result = await methodChannel.invokeMethod(bluetoothSetup);
    debugPrint(result);
  }

  Stream<String> setupEventChannel() async* {
    eventChannel.receiveBroadcastStream().listen((event) {
      debugPrint(event);
    });
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
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: StreamBuilder(
          stream: eventChannel.receiveBroadcastStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data);
              final newData = nmeaParser.formatMessage(snapshot.data);
              if (newData != null) {
                gnssLocation = gnssLocation.merge(newData);
              }
              debugPrint(gnssLocation.numberOfSatellites.toString());
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Latitute: ${gnssLocation.latitude}",
                      style: TextStyle(fontSize: 22),
                    ),
                    Text(
                      "Longitude: ${gnssLocation.longitude}",
                      style: TextStyle(fontSize: 22),
                    ),
                    Text(
                      "Altitude: ${gnssLocation.altitude}",
                      style: TextStyle(fontSize: 22),
                    ),
                    Text(
                      "Accuracy: ${gnssLocation.accuracy}",
                      style: TextStyle(fontSize: 22),
                    ),
                    Text(
                      "Fix Quality: ${gnssLocation.fixQuality}",
                      style: TextStyle(fontSize: 22),
                    ),
                    Text(
                      "PDOP: ${gnssLocation.pdop}",
                      style: TextStyle(fontSize: 22),
                    ),
                    Text(
                      "Number of Satellites: ${gnssLocation.numberOfSatellites}",
                      style: TextStyle(fontSize: 22),
                    ),
                  ],
                ),
              );
            }
            return Text("No data");
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
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
