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
import 'package:stalker/app_bar.dart';
import 'package:stalker/enchantment.dart';
import 'package:stalker/main.dart';
import 'package:stalker/pages/edit_xml/edit_xml.dart';
import 'package:stalker/pages/equipment_page.dart';
import 'package:stalker/pages/general_page.dart';
import 'package:stalker/pages/records/records.dart';
import 'package:stalker/pages/report_page.dart';
import 'package:stalker/record.dart';
import 'package:stalker/records_manager.dart';
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

void showFatalErrorDialog(
    BuildContext context, String title, String description,
    [List<Widget> actions = const []]) {
  showDialog(
      context: context,
      builder: (_) => AlertDialog(
            title: Text(title),
            content: Text(description),
            actions: [
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: const Text("Exit"),
              ),
              ...actions
            ],
          )).then((_) {
    exit(0);
  });
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
    const EquipmentPage(),
    const ReportPage()
  ];

  Future<bool> _tryToConnectToShizuku(BuildContext context) async {
    if (!(await ShizukuApi.pingBinder() ?? false)) {
      return false;
    }
    bool hasPermission = await ShizukuApi.checkPermission() ?? false;

    if (!hasPermission) {
      await ShizukuApi.requestPermission(0);
      hasPermission = await ShizukuApi.checkPermission() ?? false;
      if (!hasPermission) {
        return false;
      }
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
      return "x86_64";
    } else if (abis.contains("x86")) {
      return "x86";
    } else if (abis.contains("arm64-v8a")) {
      return "arm64";
    } else {
      return "arm";
    }
  }

  Future<void> _runSetupService() async {
    final architecture = await _getArchitecture();
    logger.i("Detected architecture $architecture");
    final fileName = "setup_service_$architecture";
    final directory = (await getExternalStorageDirectory())!;
    final byteData = await rootBundle.load("assets/binaries/$fileName");

    final file = File('${directory.path}/setup_service');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    logger.i(
        "cp output: ${await ShizukuApi.runCommand("sh -c \"cp ${directory.path}/setup_service /data/local/tmp/._stalker_setup_service\"")}");
    logger.i(
        "chmod output: ${await ShizukuApi.runCommand("chmod +x /data/local/tmp/._stalker_setup_service")}");
    logger.i(
        "Service output: ${await ShizukuApi.runCommand("/data/local/tmp/._stalker_setup_service >/dev/null 2>&1 &")}");
  }

  Future<bool> _tryToLoadUserID(BuildContext context) async {
    final directory = (await getExternalStorageDirectory())!;
    final file = File("${directory.path}/.userid");

    if (await file.exists()) {
      final id = await file.readAsString();
      if (id.length != 16) {
        showFatalErrorDialog(context, "Invalid User ID", "");
      }
      logger.i("Loaded userid $id");
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
    await getExternalStorageDirectory(); // to create the data folder
    package.value = await PackageInfo.fromPlatform();
    _isUpdateAvailable().then((updateAvailable) {
      if (updateAvailable) {
        logger.i("New update is available");
        _showUpdateDialog();
      }
    });
    await _tryToShowNotice();
    if (await _tryToConnectToShizuku(context)) {
      logger.i("Shizuku is available");
      if (await _tryToLoadUserID(context)) {
        EnchantmentsManager.loadFromFiles().then((_) async {
          logger.i("Loaded the enchantments");
          try {
            await _tryToLoadRecords();
            logger.i("Loaded ${RecordsManager.records.length} record(s)");
            setState(() {
              initialized.value = true;
            });
          } catch (e, s) {
            logger.e("Unable to load the save file");
            logger.e("$e\n$s");
            showFatalErrorDialog(context, "Unable to load the save file",
                "Stalker can't load your save. If you've just installed the game, open it once.\n$e}");
          }
        }).onError((e, s) {
          logger.e("Unable to load enchantments");
          logger.e("$e\n$s");
          Fluttertoast.showToast(msg: "Unable to load enchantments");
        });
      }
    } else {
      logger.e("Shizuku is not available");
      Fluttertoast.showToast(msg: "Shizuku is not available");
    }
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

    String link = "https://github.com/onerdna/stalker";

    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Read Me"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      "This app is completely free and always will be. If you paid for it, you were scammed. Download only from the official source:"),
                  TextButton(
                      onPressed: () => launchUrlString(link), child: Text(link))
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
        'https://api.github.com/repos/onerdna/stalker/releases/latest');
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
    const link = "https://github.com/onerdna/stalker/releases/latest";
    showFatalErrorDialog(
        context,
        "New version available",
        "In order for the app to function correctlty, please update it to the latest version.",
        [
          TextButton(
              onPressed: () {
                launchUrlString(link);
              },
              child: const Text("Update"))
        ]);
  }

  @override
  void initState() {
    super.initState();
    if (!initialized.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryToInitializeApp(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      label: "Equipment"),
                  NavigationDestination(
                      icon: Image.asset('assets/images/bug.png',
                          width: 24, height: 24),
                      label: "Bug Reports"),
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
                  TextButton.icon(
                    onPressed: () async {
                      await _tryToInitializeApp(context);
                      setState(() {});
                    },
                    label: const Text("Reinitialize"),
                    icon: const Icon(Icons.restart_alt),
                  ),
                  const CircularProgressIndicator()
                ],
              ),
      ),
    );
  }
}
