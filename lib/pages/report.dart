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


// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  static const issuesUrl = "https://github.com/onerdna/stalker/issues";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              const Text(
                "Submit a bug report here",
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              const Text(
                "⚠️ Do NOT remove device information in your issue's body or it won't be reviewed",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "After device information, explain your problem briefly",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                  onPressed: () async {
                    launchUrl(await _getIssuesUrl());
                  },
                  child: const Text("Create a new issue"))
            ],
          ),
        ),
      ),
    );
  }

  Future<Uri> _getIssuesUrl() async {
    final info = await DeviceInfoPlugin().androidInfo;
    final infoMap = {
      'model': info.model,
      'brand': info.brand,
      'device': info.device,
      'product': info.product,
      'hardware': info.hardware,
      'manufacturer': info.manufacturer,
      'version': info.version.sdkInt,
      'release': info.version.release,
      'security_patch': info.version.securityPatch,
      'board': info.board,
      'bootloader': info.bootloader,
      'display': info.display,
      'fingerprint': info.fingerprint,
      'host': info.host,
      'id': info.id,
      'tags': info.tags,
      'device_type': info.type,
      'is_physical_device': info.isPhysicalDevice
    };
    return Uri.parse(
        '$issuesUrl/new?&body=${Uri.encodeComponent(jsonEncode(infoMap))}');
  }
}
