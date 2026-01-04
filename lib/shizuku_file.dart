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
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:stalker/shizuku_api.dart';

Future<String> readFile(String path) async {
  final Directory directory = (await getExternalStorageDirectory())!;

  final file = makeTempFile(directory.path);

  validateCpOutput(
      file.path, await BridgeApi.runCommand("cp $path ${file.path}"));

  final contents = await file.readAsString();
  await BridgeApi.runCommand("rm ${file.path}");

  return contents;
}

String validateCpOutput(String path, String? output) {
  if (output == null) {
    throw FileSystemException('Unable to read file: unknown error', path);
  }

  if (output == 'cp: $path: No such file or directory') {
    throw FileSystemException('File does not exist', path);
  } else if (output == 'cp: $path: Permission denied') {
    throw FileSystemException('Permission denied', path);
  } else if (output == 'cp: $path: Is a directory') {
    throw FileSystemException('Path is a directory, not a file', path);
  }

  return output;
}

File makeTempFile(String path) {
  final rnd = List.generate(
      10,
      (_) => 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'[
          Random().nextInt(62)]).join();
  return File("$path/.temp$rnd");
}

Future<void> writeFile(String targetPath, String contents) async {
  final directory = (await getExternalStorageDirectory())!;
  final file = makeTempFile(directory.path);
  await file.writeAsString(contents);
  validateCpOutput(
      targetPath, await BridgeApi.runCommand("cp ${file.path} $targetPath"));
  await BridgeApi.runCommand("rm ${file.path}");
}
