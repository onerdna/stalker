package com.dojocommunity.stalker

import android.annotation.SuppressLint
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import rikka.shizuku.Shizuku
import rikka.shizuku.ShizukuRemoteProcess
import java.io.BufferedReader
import java.io.InputStreamReader


class MainActivity : FlutterActivity() {
    private val shizukuChannel = "com.dojocommunity.stalker/shizuku"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, shizukuChannel).setMethodCallHandler {
                call, result ->
            when (call.method) {
                "pingBinder" -> {
                    result.success(Shizuku.pingBinder())
                }

                "checkPermission" -> {
                    result.success(Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED)
                }

                "requestPermission" -> {
                    val requestCode: Int = call.argument("requestCode")!!
                    requestPermission(requestCode, result)
                }

                "runCommand" -> {
                    val command = call.argument<String>("command")
                        ?: throw IllegalArgumentException("Invalid command argument")
                    result.success(runCommand(command))
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun runCommand(command: String): String {
        val outputBuilder = StringBuilder()
        var process: ShizukuRemoteProcess? = null
        try {
            require(command.isNotEmpty()) { "Command cannot be null or empty" }

            process = Shizuku.newProcess(arrayOf("sh", "-c", command), null, "/")
            val input = BufferedReader(InputStreamReader(process.getInputStream()))
            val error = BufferedReader(InputStreamReader(process.errorStream))

            var line: String?
            while ((input.readLine().also { line = it }) != null) {
                outputBuilder.append(line).append("\n")
            }

            while ((error.readLine().also { line = it }) != null) {
                outputBuilder.append(line).append("\n")
            }

            process.waitFor()
        } catch (e: java.lang.IllegalArgumentException) {
            outputBuilder.append("Error: ").append(e.message)
        } catch (e: Exception) {
            outputBuilder.append("Unexpected error: ").append(e.message)
            e.printStackTrace()
        } finally {
            process?.destroy()
        }
        return outputBuilder.toString().trim { it <= ' ' }
    }

    private fun requestPermission(code: Int, result: MethodChannel.Result) {
        if (Shizuku.isPreV11()) {
            result.success(false)
            return
        }

        if (Shizuku.checkSelfPermission() == PackageManager.PERMISSION_GRANTED) {
            result.success(true)
            return
        }

        if (Shizuku.shouldShowRequestPermissionRationale()) {
            result.success(false)
            return
        }

        Shizuku.addRequestPermissionResultListener(object :
            Shizuku.OnRequestPermissionResultListener {
            override fun onRequestPermissionResult(requestCode: Int, grantResult: Int) {
                if (requestCode == code) {
                    Shizuku.removeRequestPermissionResultListener(this)
                    val isGranted = grantResult == PackageManager.PERMISSION_GRANTED
                    result.success(isGranted)
                }
            }
        })

        Shizuku.requestPermission(code)
    }
}
