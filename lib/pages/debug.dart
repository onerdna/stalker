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
import 'package:stalker/github.dart';
import 'package:stalker/main.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  DebugPageState createState() => DebugPageState();
}

String formatLogEntry(e) =>
    "[${e['level'].toString().toUpperCase()}] ${e['message']}";

class DebugPageState extends State<DebugPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs Viewer'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            left: 40,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Share"),
                FloatingActionButton(
                  onPressed: () => _exportLogs(),
                  tooltip: "Share",
                  heroTag: "btn-share",
                  child: const Icon(Icons.share),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Report a bug"),
                FloatingActionButton(
                  heroTag: "btn-report",
                  onPressed: () {
                    launchUrlString(GitHub.issueGeneral);
                  },
                  child: const Icon(Icons.report),
                ),
              ],
            ),
          )
        ],
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
                children: logger
                    .getStoredLogs()
                    .map((e) => Text(
                          formatLogEntry(e),
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
    await file.writeAsString(
        logger.getStoredLogs().map((e) => formatLogEntry(e)).join("\n"));
    await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, name: fileName, mimeType: "text/plain")]));
  }
}
