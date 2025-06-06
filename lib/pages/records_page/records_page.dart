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

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stalker/app.dart';
import 'package:stalker/pages/records_page/new_record.dart';
import 'package:stalker/record.dart';
import 'package:stalker/records_manager.dart';
import 'package:xml/xml.dart';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  Map<String, TextEditingController> controllers = {};

  @override
  void dispose() {
    super.dispose();
    for (var e in controllers.values) {
      e.dispose();
    }
  }

  List<Widget> _generateSaveEntries(BuildContext context) {
    return RecordsManager.records.map((record) {
      controllers["${record.metadata.uuid}_name"] =
          TextEditingController(text: record.metadata.name);
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            border: Border.all(
                width: 1,
                color: record.metadata.isActive
                    ? Theme.of(context).colorScheme.primary
                    : (Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white)),
          ),
          child: ExpansionTile(
            initiallyExpanded: true,
            title: Row(
              children: [
                IconButton(
                    onPressed: () {
                      if (record.metadata.isActive) {
                        Fluttertoast.showToast(
                            msg:
                                "You can’t delete a save slot while it’s set as active");
                      } else {
                        _showRecordDeletionDialog(context, record);
                      }
                    },
                    icon: const Icon(Icons.delete)),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: controllers["${record.metadata.uuid}_name"],
                    style: const TextStyle(fontSize: 19),
                    decoration:
                        const InputDecoration.collapsed(hintText: "Name..."),
                    onSubmitted: (value) {
                      record.metadata.name = value;
                      RecordsManager.saveRecord(record);
                    },
                  ),
                ),
                const Spacer(),
                record.metadata.isActive
                    ? const Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Active",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    : const Text(""),
              ],
            ),
            subtitle: TextButton(
              child: Text(
                record.metadata.uuid,
                style: const TextStyle(fontSize: 13.8),
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: record.metadata.uuid));
              },
            ),
            childrenPadding: const EdgeInsets.only(left: 20),
            children: [
              _statTile(
                  "assets/images/shuriken.png", "Level", "${record.level}"),
              _statTile("assets/images/coin.png", "Coins",
                  "${record.getCurrency(Currency.coins)}"),
              _statTile("assets/images/ruby.png", "Gems",
                  "${record.getCurrency(Currency.gems)}"),
              _statTile("assets/images/forge_green.png", "Green orbs",
                  "${record.getCurrency(Currency.greenOrbs)}"),
              _statTile("assets/images/forge_red.png", "Red orbs",
                  "${record.getCurrency(Currency.redOrbs)}"),
              _statTile("assets/images/forge_purple.png", "Purple orbs",
                  "${record.getCurrency(Currency.purpleOrbs)}"),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filled(
                        onPressed: () {
                          setState(() {
                            import(record);
                          });
                        },
                        icon: const Icon(Icons.download)),
                    const SizedBox(
                      width: 4,
                    ),
                    record.metadata.isActive
                        ? FilledButton(
                            onPressed: () {
                              RecordsManager.saveRecordWithToast(
                                  RecordsManager.activeRecord!);
                            },
                            child: const Text("Regenerate hash file"))
                        : FilledButton(
                            onPressed: () {
                              setState(() {
                                RecordsManager.activeRecord = record;
                                RecordsManager.saveRecord(record);
                              });
                            },
                            child: const Text("Set as active")),
                    const SizedBox(
                      width: 4,
                    ),
                    IconButton.filled(
                        onPressed: () => export(record),
                        icon: const Icon(Icons.upload)),
                  ],
                ),
              ),
              const SizedBox(height: 16)
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _statTile(String iconPath, String label, String value) {
    return ListTile(
      title: Row(
        children: [
          Image.asset(iconPath, width: 24, height: 24),
          const SizedBox(width: 5),
          Text(
            "$label: $value",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> export(Record save) async {
    final temp = await getTemporaryDirectory();
    final file = File("${temp.path}/users.xml");
    file.writeAsString(save.xml);
    await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, name: "users.xml", mimeType: "text/plain")]));
  }

  void import(Record record) {
    showConfirmationDialog(
        const Text("Are you sure?"),
        const Text(
          "This will overwrite your save file with a new one!",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        context, (ctx) async {
      Navigator.of(ctx).pop();
      final result = await FilePicker.platform.pickFiles(
          dialogTitle: "Pick a save file",
          type: FileType.custom,
          allowedExtensions: ["xml"]);
      if (result != null &&
          result.files.isNotEmpty &&
          result.files.first.path != null) {
        final file = File(result.files.first.path!);
        final content = await file.readAsString();

        try {
          final newSave = Record(XmlDocument.parse(content), record.metadata);
          setState(() {
            RecordsManager.records[RecordsManager.records.indexOf(record)] =
                newSave;
          });
          RecordsManager.saveRecord(newSave);
          Fluttertoast.showToast(msg: "Successfully imported the save file");
        } catch (e) {
          Fluttertoast.showToast(msg: e.toString());
          return;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          ..._generateSaveEntries(context),
          FilledButton.icon(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (ctx) => NewRecord(onCreated: () {
                          setState(() {});
                        }));
              },
              label: const Icon(Icons.add))
        ],
      ),
    );
  }

  Future<void> _showRecordDeletionDialog(
      BuildContext context, Record record) async {
    await showConfirmationDialog(
        const Text("Are you sure?"),
        const Text(
          "This will forever delete this save slot with all of the contents!",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        context, (ctx) async {
      Navigator.of(ctx).pop();
      setState(() {
        RecordsManager.records.remove(record);
      });
      await RecordsManager.deleteRecord(record);
    });
  }
}
