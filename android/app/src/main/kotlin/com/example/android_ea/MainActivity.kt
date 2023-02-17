package com.example.android_ea
import android.annotation.SuppressLint
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.os.SystemClock
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.*
import java.lang.reflect.Method
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.ScheduledFuture
import java.util.concurrent.TimeUnit


class MainActivity: FlutterActivity(), EventChannel.StreamHandler {

    private val channel: String = "ecobot.bluetooth.channel"
    private val eventChannel: String = "ecobot.bluetooth.event-channel"
    lateinit var bluetoothManager: BluetoothManager
    private var connectedThread: ConnectedThread? = null
    var supportedDevice: BluetoothDevice? = null
    private var eventSink: EventChannel.EventSink? = null
    private val scheduler: ScheduledExecutorService = Executors.newSingleThreadScheduledExecutor()
    private var socket: BluetoothSocket? = null

    private val handler = Handler(Looper.getMainLooper(), Handler.Callback {
        eventSink?.success(it.obj as String)
        return@Callback true
    })

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "bluetooth_setup" -> setupBluetooth(result)
                "discoverSupportedDevice" -> discoverSupportedDevice(result)
                "connectToDevice" -> connectToDevice(result)
                "checkIfDeviceIsConnected" -> checkIfDeviceIsConnected(result)
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, eventChannel).setStreamHandler(this)
    }

    private fun checkIfDeviceIsConnected(result: MethodChannel.Result) {
        return result.success(socket?.isConnected)
    }

    private fun requestBluetoothPermission(result: MethodChannel.Result) {
        
    }

    private fun setupBluetooth(result: MethodChannel.Result) {
        bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        val bluetoothAdapter = bluetoothManager.adapter
            ?: return result.error("400", "Bluetooth is Off", "")
        return result.success("Bluetooth is on")
    }



    @SuppressLint("MissingPermission")
    private fun discoverSupportedDevice(result: MethodChannel.Result) {
        val boundedDevices = bluetoothManager.adapter.bondedDevices
        for(device in boundedDevices) {
            if(device.name.contains("Bad Elf")) {
                supportedDevice = device
                break
            }
        }
        return if(supportedDevice == null) {
            result.error("400", "No Supported device", "")
        } else {
            result.success("device:" + supportedDevice!!.name+ " is bounded")
        }
    }
    @SuppressLint("MissingPermission")
    private fun fetchBluetoothSocket(result: MethodChannel.Result) {
        if (supportedDevice == null) return result.error("400", "No supported Devices found", "")
        val uuid = supportedDevice!!.uuids.first().uuid
        bluetoothManager.adapter.cancelDiscovery()
        val socket: BluetoothSocket? by lazy(LazyThreadSafetyMode.NONE) {
            supportedDevice!!.createInsecureRfcommSocketToServiceRecord(uuid)
        }
        this.socket = socket
    }

    @SuppressLint("MissingPermission")
    private fun connectToDevice(result: MethodChannel.Result) {
        fetchBluetoothSocket(result)
        if(socket == null) return result.error("400", "socket is unavailable", "")
        try {
            socket!!.connect()
        } catch (e: IOException) {
            return result.error("400", "Socket Unavailable: " + e.message, "")
        }
        connectedThread = ConnectedThread(socket!!)
        connectedThread!!.start()
        return result.success("Connection Successful")
    }

    private fun reconnect() {
        //FIXME: Figure out a way of this being up until it actually reconnect.
        if(socket==null) return
        if(connectedThread != null && connectedThread!!.isAlive) {
            connectedThread!!.interrupt()
        }

        connectedThread = ConnectedThread(socket!!)
        connectedThread!!.start()
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        if(socket != null) socket!!.close()
    }

    private inner class ConnectedThread(val socket: BluetoothSocket): Thread() {
        val inputStream: InputStream = socket.inputStream
        val outputSteam: OutputStream = socket.outputStream

        private val pingTask = Runnable {
            try {
                val byteArray =  "/r/n".toByteArray()
                outputSteam.write(byteArray)  // send data to Bad Elf Device
            } catch (e: IOException) {
                runOnUiThread {
                    eventSink!!.error("400", "Pingtask:" + e.message, "")
                }
                try {
                    outputSteam.close()
                } catch (e: IOException) {
                    runOnUiThread {
                        eventSink!!.error("400", "Pingtask2:" + e.message, "")
                    }
                }
            }
        }

        override fun run() {
            var pingFuture: ScheduledFuture<*>? = null
            pingFuture = scheduler.scheduleAtFixedRate(pingTask, 2000, 500, TimeUnit.MILLISECONDS);

            try {
                val reader = BufferedReader(InputStreamReader(inputStream, "UTF-8"))
                while (socket.isConnected && !interrupted()) {
                    if (reader.ready()) {
                        val line = reader.readLine()
                        val message = Message.obtain(handler, 0, line)
                        message.sendToTarget()
                    } else {
                        SystemClock.sleep(50)
                    }
                }
            } catch (e: IOException) {
                runOnUiThread {
                    eventSink!!.error("400", "catch on Thread", "")
                }
                println("Closing Socket")
                socket.close()
                pingFuture.cancel(true)
            } finally {
                socket.close()
                interrupt()
            }
        }
    }
}




