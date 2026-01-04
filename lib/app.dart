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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';
import 'package:stalker/github.dart';
import 'package:stalker/pages/debug.dart';
import 'package:stalker/ui/app_bar.dart';
import 'package:stalker/logic/enchantment.dart';
import 'package:stalker/main.dart';
import 'package:stalker/pages/edit_xml/edit_xml.dart';
import 'package:stalker/pages/equipment.dart';
import 'package:stalker/pages/general.dart';
import 'package:stalker/pages/records/records.dart';
import 'package:stalker/logic/record.dart';
import 'package:stalker/logic/records_manager.dart';
import 'package:signals/signals.dart' as signals_core;
import 'package:stalker/shizuku_api.dart';
import 'package:stalker/shizuku_file.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

final Signal<bool> initialized = signals_core.signal(false);
final Signal<int> currentPageIndex = signals_core.signal(0);
Signal<PackageInfo?> package = signal(null);

var isSetupServiceRunning = false;

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

Future<void> showConfirmationDialog(Widget title, Widget content,
    BuildContext context, void Function(BuildContext) onConfirm) async {
  showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            title: title,
            content: content,
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () => onConfirm(ctx), child: const Text("Confirm"))
            ],
          ));
}

class _AppState extends State<App> {
  static final List<Widget> pages = [
    const RecordsPage(),
    const EditXmlPage(),
    const GeneralPage(),
    const EquipmentPage()
  ];

  Future<bool> _tryToConnectToShizuku(BuildContext context) async {
    if (!(await BridgeApi.pingBinder() ?? false)) {
      return false;
    }

    if (!(await BridgeApi.checkPermission() ?? false)) {
      await BridgeApi.requestPermission(0);
      return await BridgeApi.checkPermission() ?? false;
    }

    return true;
  }

  Future<void> _showSetupDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Additional setup required",
                  style: TextStyle(fontSize: 24)),
              content: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: const [
                    TextSpan(
                        text:
                            "This application requires additional setup to run. Tap 'Start the service', "),
                    TextSpan(
                      text: 'minimize',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: " this window and open the game "),
                    TextSpan(
                      text: 'until it fully loads',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                        text:
                            ". Then close the game, return to the app and tap 'Reinitialize'."),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      _runSetupService();
                      Navigator.of(context, rootNavigator: true).pop();
                      Fluttertoast.showToast(msg: "Started the service");
                    },
                    child: const Text("Start the service"))
              ],
            ));
  }

  Future<String> _getArchitecture() async {
    final abis = (await (DeviceInfoPlugin()).androidInfo).supportedAbis;
    if (abis.contains("x86_64")) {
      return "_x86_64";
    } else if (abis.contains("arm64-v8a")) {
      return "64";
    } else {
      return "32";
    }
  }

  Future<void> _runSetupService() async {
    final architecture = await _getArchitecture();
    logger.i("Detected architecture $architecture");
    final fileName = "setup_service$architecture";
    final directory = (await getExternalStorageDirectory())!;
    final byteData = await rootBundle.load("assets/binaries/$fileName");

    final file = File('${directory.path}/setup_service');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    logger.i(
        "cp output: ${await BridgeApi.runCommand("sh -c \"cp ${directory.path}/setup_service /data/local/tmp/._stalker_setup_service\"")}");
    logger.i(
        "chmod output: ${await BridgeApi.runCommand("chmod +x /data/local/tmp/._stalker_setup_service")}");
    logger.i(
        "Service output: ${await BridgeApi.runCommand("/data/local/tmp/._stalker_setup_service >/dev/null 2>&1 &")}");
  }

  Future<bool> _tryToLoadUserID(BuildContext context) async {
    final directory = (await getExternalStorageDirectory())!;
    final file = File("${directory.path}/.userid");

    if (await file.exists()) {
      final id = await file.readAsString();
      RecordsManager.userid = id;
    } else {
      if (!isSetupServiceRunning) {
        await _showSetupDialog(context);
      }
      return false;
    }
    return true;
  }

  Future<void> _tryToInitializeApp(BuildContext context) async {
    logger = constructLogger();
    await getExternalStorageDirectory(); // to create the data folder
    package.value = await PackageInfo.fromPlatform();
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('ignoreUpdates') ?? false) {
      logger.i("Ignoring updates");
    } else {
      _isUpdateAvailable().then((updateAvailable) {
        if (updateAvailable) {
          logger.i("New update is available");
          _showUpdateDialog();
        }
      });
    }

    await _tryToShowNotice();

    if (await _tryToConnectToShizuku(context)) {
      logger.i("Shizuku is available");
    } else {
      logger.e("Shizuku is not available");
      return;
    }

    var startResult = await BridgeApi.startBinderService();
    if (startResult.isNotEmpty) {
      logger.e("Error while starting binder service: $startResult");
      return;
    }
    var serviceAvailable = await BridgeApi.isBinderServiceAvailable();
    var tries = 0;
    while (!serviceAvailable && tries < 10) {
      setState(() {
        logger.i("Waiting for binder service...");
      });
      await Future.delayed(const Duration(milliseconds: 500));
      serviceAvailable = await BridgeApi.isBinderServiceAvailable();
      tries++;
    }
    if (serviceAvailable) {
      setState(() {
        logger.i("Binder service available");
      });
    } else {
      setState(() {
        logger.e("Timed out! Can't connect to the binder service");
      });
      return;
    }

    if (await _tryToLoadUserID(context)) {
      if (RecordsManager.userid.length != 16) {
        setState(() {
          logger.e("Invalid userid: ${RecordsManager.userid}");
        });
        return;
      }
      setState(() {
        logger.i("Read userid: ${RecordsManager.userid}");
      });
    } else {
      setState(() {
        logger.e("Unable to read userid");
      });
      return;
    }

    EnchantmentsManager.loadFromFiles().then((_) async {
      logger.i("Loaded enchantments");
      try {
        await _tryToLoadRecords();
        logger.i("Loaded ${RecordsManager.records.length} record(s)");
        setState(() {
          initialized.value = true;
        });
      } catch (e, s) {
        setState(() {
          logger.e("Unable to load the save file");
          logger.e("$e\n$s");
        });
      }
    }).onError((e, s) {
      setState(() {
        logger.e("Unable to load enchantments");
        logger.e("$e\n$s");
      });
    });
  }

  Future<void> _tryToLoadRecords() async {
    RecordsManager.records = await RecordsManager.loadRecords();
    if (RecordsManager.activeRecord == null) {
      logger.i("There are no records to load, creating a new one...");
      const path = "${RecordsManager.userdataPath}/users.xml";
      final tree = XmlDocument.parse(await readFile(path));
      final record =
          Record(tree, RecordMetadata("Save #1", const Uuid().v8(), true));
      RecordsManager.records.add(record);
      RecordsManager.activeRecord = record;
      RecordsManager.saveRecord(record);
    }
  }

  Future<void> _tryToShowNotice() async {
    final instance = await SharedPreferences.getInstance();
    if (instance.getBool("notifiedAboutFreedom") ?? false) {
      return;
    }

    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Read Me"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      "This app is FOSS (free), but this build includes three (3) proprietary binaries (see README). Download only from the official GitHub repository: "),
                  TextButton(
                      onPressed: () => launchUrlString(GitHub.repoUrl),
                      child: const Text(GitHub.repoUrl))
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    child: const Text("Understood"))
              ],
            ));
    instance.setBool("notifiedAboutFreedom", true);
  }

  Future<bool> _isUpdateAvailable() async {
    final url = Uri.parse(
        'https://api.github.com/repos/${GitHub.repoUser}/${GitHub.repoName}/releases/latest');
    final client = HttpClient();

    try {
      final request = await client.getUrl(url);
      HttpClientResponse? response;

      response = await request.close().timeout(const Duration(seconds: 10));
      final responseBody = await response.transform(utf8.decoder).join();

      final releaseData = jsonDecode(responseBody);
      final tagName = releaseData['tag_name'] as String?;
      logger.i("Fetched latest version: $tagName");

      return Version.parse(tagName ?? '') >
          Version.parse(package.value!.version);
    } catch (e) {
      logger.e("An error ocurred while checking for updates: $e");
      return false;
    } finally {
      client.close();
    }
  }

  Future<void> _showUpdateDialog() async {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text("New version available"),
              content: const Text(
                  "In order for the app to function correctlty, please update it to the latest version."),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () {
                          launchUrlString(GitHub.latestRelease);
                        },
                        child: const Text("Update")),
                    TextButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setBool('ignoreUpdates', true);
                          Navigator.of(context).pop();
                        },
                        child: const Text("Do not show again"))
                  ],
                )
              ],
            ));
  }

  @override
  void initState() {
    super.initState();
    if (!initialized.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryToInitializeApp(context).then((_) {
          setState(() {});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final logs = logger.getStoredLogs();
    return Scaffold(
      appBar: const StalkerAppBar(),
      bottomNavigationBar: Watch((_) => initialized.value
          ? ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28), topRight: Radius.circular(28)),
              child: NavigationBar(
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .surfaceTint
                    .withValues(alpha: 0.1),
                destinations: [
                  NavigationDestination(
                      icon: Image.asset('assets/images/house.png',
                          width: 24, height: 24),
                      label: "Home"),
                  NavigationDestination(
                      icon: Image.asset('assets/images/file.png',
                          width: 24, height: 24),
                      label: "Edit XML"),
                  NavigationDestination(
                      icon: Image.asset('assets/images/wrench.png',
                          width: 24, height: 24),
                      label: "General"),
                  NavigationDestination(
                      icon: Image.asset('assets/images/sword.png',
                          width: 24, height: 24),
                      label: "Equipment")
                ],
                selectedIndex: currentPageIndex.value,
                onDestinationSelected: (int index) {
                  setState(() {
                    currentPageIndex.value = index;
                  });
                },
              ),
            )
          : const SizedBox.shrink()),
      body: Watch(
        (_) => initialized.value
            ? pages.elementAt(currentPageIndex.value)
            : Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(value: false, onChanged: null),
                      Text("Not initialized"),
                    ],
                  ),
                  const Text("This app requires Shizuku to run"),
                  TextButton(
                    child: const Text("Not working? Check README"),
                    onPressed: () {
                      launchUrlString(
                          "${GitHub.repoUrl}/blob/master/README.md#-troubleshooting");
                    },
                  ),
                  TextButton(
                      onPressed: () {
                        launchUrlString(
                            "${GitHub.repoUrl}/issues/new?title=${Uri.encodeComponent("Additional setup not working")}&body=${Uri.encodeComponent("--- APP LOGS, DO NOT DELETE! ---\n${logger.getStoredLogs().map((e) => formatLogEntry(e)).join("\n")}\n--- LOGS END ---\nAndroid version: [fill here]\nPhone model (or emulator): [fill here]\nAny additional information: [fill here]\nI acknowledge that I've followed the instruction steps and read the README's troubleshooting section.")}");
                      },
                      child: const Text(
                          textAlign: TextAlign.center,
                          "If it's still not working, tap here")),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (ctx, constraints) {
                        final theme = Theme.of(ctx);
                        return Center(
                            child: Container(
                          width: constraints.maxWidth * 0.9 - 32,
                          height: constraints.maxHeight,
                          color: theme.brightness == Brightness.light
                              ? theme.colorScheme.surfaceContainerLowest
                              : theme.colorScheme.surfaceTint
                                  .withValues(alpha: 0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListView.builder(
                              itemBuilder: (ctx, i) {
                                return Text(formatLogEntry(logs[i]));
                              },
                              itemCount: logs.length,
                            ),
                          ),
                        ));
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      await _tryToInitializeApp(context);
                      setState(() {});
                    },
                    label: const Text("Reinitialize"),
                    icon: const Icon(Icons.restart_alt),
                  ),
                  const SizedBox(
                    height: 64,
                  ),
                ],
              ),
      ),
    );
  }
}
