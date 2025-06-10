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

import 'dart:async';

import 'package:flutter/services.dart';

class Logcat {
  static const _logcatChannel = EventChannel("logcat_channel");
  static StreamSubscription? _logSubscription;
  static final List<String> logs = [];

  static void init() {
    _logSubscription ??=
        _logcatChannel.receiveBroadcastStream().listen((event) {
      logs.add(event);
    }, onError: (error) {
      logs.add("Logcat Subscription Error: $error");
    });
  }
}
