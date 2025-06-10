package com.dojocommunity.stalker

import android.content.Context
import android.os.Looper
import io.flutter.plugin.common.EventChannel
import java.io.BufferedReader
import java.io.InputStreamReader
import android.os.Handler

class LogcatReader(private val context: Context, private val eventSink: EventChannel.EventSink) {
    private var logcatThread: Thread? = null

    fun start() {
        val mainHandler = Handler(Looper.getMainLooper())

        logcatThread = Thread {
            try {
                val packageName = context.packageName
                val pidProcess = Runtime.getRuntime().exec("pidof $packageName")
                val pidReader = BufferedReader(InputStreamReader(pidProcess.inputStream))
                val pid = pidReader.readLine()?.trim()

                if (pid.isNullOrEmpty()) {
                    mainHandler.post {
                        eventSink.error("PID_ERROR", "Could not find PID for package: $packageName", null)
                    }
                    return@Thread
                }

                val logcatProcess = Runtime.getRuntime().exec("logcat -T 0 --pid=$pid")
                val logReader = BufferedReader(InputStreamReader(logcatProcess.inputStream))

                var line: String?
                while (logReader.readLine().also { line = it } != null) {
                    mainHandler.post {
                        eventSink.success(line)
                    }
                }

            } catch (e: Exception) {
                mainHandler.post {
                    eventSink.error("LOGCAT_ERROR", "Error reading logcat: ${e.localizedMessage}", null)
                }
            }
        }
        logcatThread?.start()
    }

    fun stop() {
        logcatThread?.interrupt()
    }
}
