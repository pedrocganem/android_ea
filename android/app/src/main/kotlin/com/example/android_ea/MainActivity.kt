package com.example.android_ea

import android.annotation.SuppressLint
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.BufferedReader
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
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
    private val sch: ScheduledExecutorService = Executors.newSingleThreadScheduledExecutor()



    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {

        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "bluetooth_setup" -> setupBluetooth(result)
                "discoverSupportedDevice" -> discoverSupportedDevice(result)
                "connectToDevice" -> connectToDevice(result)
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, eventChannel).setStreamHandler(this)
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
            if(device.name.contains("Arrow")) {
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
    private fun fetchBluetoothSocket(result: MethodChannel.Result): BluetoothSocket? {
        if (supportedDevice == null) return null
        val uuid = supportedDevice!!.uuids.first().uuid
        bluetoothManager.adapter.cancelDiscovery()
        val socket: BluetoothSocket by lazy(LazyThreadSafetyMode.NONE) {
            supportedDevice!!.createInsecureRfcommSocketToServiceRecord(uuid)
        }

        return socket
    }

    @SuppressLint("MissingPermission")
    private fun connectToDevice(result: MethodChannel.Result) {
        val socket = fetchBluetoothSocket(result)
        socket!!.connect()
        connectedThread = ConnectedThread(socket!!)
        connectedThread!!.start()
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private inner class ConnectedThread(val socket: BluetoothSocket): Thread() {

        val inputStream: InputStream = socket.inputStream
        val outputSteam: OutputStream = socket.outputStream
        val mmBuffer: ByteArray = ByteArray(1024)

        var reader = BufferedReader(inputStream.reader())
        var numBytes: Int? = null
        var currentMessage: String = ""

        override fun run() {
            var pingFuture: ScheduledFuture<*>? = null
            pingFuture = sch.scheduleAtFixedRate(pingTask, 2000, 500, TimeUnit.MILLISECONDS);

            while(true) {
                try {
                    numBytes = inputStream.read(mmBuffer)

                    mmBuffer.forEach {
                        var currentChar = it.toInt().toChar().toString()
                        // Clean garbage data
                        if(it < 0x20 || it > 0x7e) {
                            return
                        }

                        currentMessage += currentChar
                        if(it.toInt() == 0x0a) {
                            val copy = String(currentMessage.toByteArray())
                            runOnUiThread {
                                println("sending..." + copy)
                                eventSink!!.success(copy)
                            }
                            currentMessage = ""
                        }
                    }
                } catch (e: IOException) {
                    println("deu ruim")
                } finally {
                    if(socket != null) {
                        try {
                            socket.close()
                        } catch (e: IOException) {
                            // Since we don't need the socket we can just ignore this exception.
                        }
                    }
                }
            }
        }

        private val pingTask = Runnable {
            try {
                val byteArray =  "/r/n".toByteArray()
                outputSteam.write(byteArray)  // send data to Bad Elf Device
            } catch (e: IOException) {
                    eventSink!!.error("400", e.message, "")
                try {
                    outputSteam.close();
                } catch (e: IOException) {
                    eventSink!!.error("400", e.message, "")e
                }
            }
        }
    }
}




