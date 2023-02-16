import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    // for (var device in devices) {
    //   _devices.add({
    //     "name": device,
    //   });
    //   debugdebugPrint(device.toString());
    // }
    // setState(() {

    // });
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
              return Text(snapshot.data as String);
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
