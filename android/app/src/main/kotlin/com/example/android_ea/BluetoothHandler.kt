package com.example.android_ea

import io.flutter.plugin.common.EventChannel
import java.util.logging.Handler

class BluetoothHandler: EventChannel.StreamHandler {



    fun connectToDevice() {

    }

    //This is to check if the bluetooth adapter exists and check for permissions
    fun setup() {

    }

    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {

    }

    override fun onCancel(arguments: Any?) {
        TODO("Not yet implemented")
    }
}
