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

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stalker/logic/record.dart';
import 'package:stalker/shizuku_api.dart';
import 'package:stalker/shizuku_file.dart';
import 'package:toml/toml.dart';
import 'package:xml/xml.dart';

class RecordsManager {
  static List<Record> records = [];
  static String userid = "";
  static const userdataPath =
      "/sdcard/Android/data/com.nekki.shadowfight/files/userdata";

  static Record? get activeRecord =>
      records.where((e) => e.metadata.isActive == true).firstOrNull;

  static set activeRecord(Record? record) {
    for (var e in records) {
      e.metadata.isActive = false;
    }
    record?.metadata.isActive = true;
    _updateRecordsMetadata();
  }

  static Future<void> saveRecord(Record record) async {
    final recordsDirectory = await _getRecordsDirectory();

    final metadataFile =
        File("${recordsDirectory.path}/${record.metadata.uuid}/metadata.toml");
    await metadataFile.create(recursive: true);

    metadataFile.writeAsString(
        TomlDocument.fromMap(record.metadata.toMap()).toString());

    final dataFile =
        File("${recordsDirectory.path}/${record.metadata.uuid}/data.xml");
    final xml = record.xml;

    dataFile.create();
    dataFile.writeAsString(xml);

    if (activeRecord == record) {
      final hash = _computeHash(xml);
      await writeFile("$userdataPath/users.xml", xml);
      await writeFile("$userdataPath/users_backup.xml", xml);
      await writeFile("$userdataPath/users.xml.hash", hash);
      await writeFile("$userdataPath/users_backup.xml.hash", hash);
    }
  }

  static void saveRecordWithToast(Record record) {
    saveRecord(record).then((result) {
      Fluttertoast.showToast(msg: "Saved successfully");
    }).onError((e, _) {
      Fluttertoast.showToast(msg: "Error occured while saving: $e");
    });
  }

  static String formatXml(String xml) {
    final reNewlines = RegExp(r'\n\s*');
    final noNewlines = xml.replaceAll(reNewlines, '');

    final reXmlDecl = RegExp(r'(<\?xml[^>]+\?>)\s*');
    final formatted =
        noNewlines.replaceAllMapped(reXmlDecl, (match) => match.group(1)!);

    return formatted;
  }

  static String _computeHash(String xml) {
    final formatted = formatXml(xml);

    final magicString = '${RecordsManager.userid}'
        'com.nekki.shadowfightwqO+Qchj|r*QXg7o_KNmLYvpGHdSwqxwlQI2vy618KaD^Pwt-h3H8*uJ';

    final innerHashBytes = md5.convert(utf8.encode(formatted)).bytes;
    final innerHash = innerHashBytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join();

    final fullInput = '$innerHash$magicString';

    final finalHashBytes = md5.convert(utf8.encode(fullInput)).bytes;
    final finalHash = finalHashBytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join();

    return finalHash;
  }

  static Future<Directory> _getRecordsDirectory() async {
    final externalStorage = (await getExternalStorageDirectory())!;
    final recordsDirectory = Directory("${externalStorage.path}/records");

    await recordsDirectory.create(recursive: true);
    return recordsDirectory;
  }

  static Future<List<Record>> loadRecords() async {
    final recordsDirectory = await _getRecordsDirectory();

    List<Record> records = [];

    for (final folder in recordsDirectory.listSync().whereType<Directory>()) {
      final record = await loadRecord(folder.path);
      records.add(record);
    }

    return records;
  }

  static Future<RecordMetadata> _loadRecordMetadata(String path) async {
    final metadataFile = File("$path/metadata.toml");

    return RecordMetadata.fromMap(
        TomlDocument.parse(await metadataFile.readAsString()).toMap());
  }

  static Future<Record> loadRecord(String path) async {
    final metadata = await _loadRecordMetadata(path);

    final dataPath =
        metadata.isActive ? "$userdataPath/users.xml" : "$path/data.xml";
    if (metadata.isActive) {
      ShizukuApi.runCommand("cp $userdataPath/users.xml $path/data.xml");
    }

    final tree = XmlDocument.parse(await readFile(dataPath));
    return Record(tree, metadata);
  }

  static Future<void> _updateRecordsMetadata() async {
    final directory = await _getRecordsDirectory();

    for (final record in records) {
      final metadataFile =
          File("${directory.path}/${record.metadata.uuid}/metadata.toml");
      await metadataFile.create();
      await metadataFile.writeAsString(
          TomlDocument.fromMap(record.metadata.toMap()).toString());
    }
  }

  static Future<void> deleteRecord(Record record) async {
    final directory = await _getRecordsDirectory();
    await Directory("${directory.path}/${record.metadata.uuid}")
        .delete(recursive: true);
  }
}
