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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stalker/logcat.dart';
import 'package:uuid/uuid.dart';

class LogcatStreamPage extends StatefulWidget {
  const LogcatStreamPage({super.key});

  @override
  LogcatStreamPageState createState() => LogcatStreamPageState();
}

class LogcatStreamPageState extends State<LogcatStreamPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logs Viewer')),
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FilledButton(
          onPressed: () => _exportLogs(),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(0),
            minimumSize: const Size(48, 48),
          ),
          child: const Icon(Icons.share),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 400),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: Logcat.logs
                    .map((e) => Text(
                          e,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _exportLogs() async {
    final temp = await getTemporaryDirectory();
    final fileName = "log-${const Uuid().v8()}.txt";
    final file = File("${temp.path}/$fileName");
    file.writeAsString(Logcat.logs.join("\n"));
    await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, name: fileName, mimeType: "text/plain")]));
  }
}
