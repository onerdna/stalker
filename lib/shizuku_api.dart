/* 
 * Stalker
 * Copyright (C) 2025 Andreno
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/services.dart';

class BridgeApi {
  static const _channel = MethodChannel('com.onerdna.stalker/shizuku');

  static Future<bool?> pingBinder() async {
    return await _channel.invokeMethod("pingBinder");
  }

  static Future<void> requestPermission(int requestCode) async {
    await _channel.invokeMethod("requestPermission", {
      "requestCode": requestCode,
    });
  }

  static Future<bool?> checkPermission() async {
    return await _channel.invokeMethod("checkPermission");
  }

  static Future<String?> runCommand(String command) async {
    return await _channel.invokeMethod("runCommand", {"command": command});
  }

  static Future<bool> isBinderServiceAvailable() async {
    return await _channel.invokeMethod("isBinderServiceAvailable");
  }

  static Future<String> startBinderService() async {
    return await _channel.invokeMethod("startBinderService");
  }
}
