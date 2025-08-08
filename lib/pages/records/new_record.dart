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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stalker/logic/record.dart';
import 'package:stalker/logic/records_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class NewRecord extends StatefulWidget {
  final VoidCallback onCreated;

  const NewRecord({required this.onCreated, super.key});

  @override
  State<NewRecord> createState() => _NewRecordState();
}

class _NewRecordState extends State<NewRecord> {
  final controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create a new save record"),
      content: SizedBox(
        width: 400,
        height: 80,
        child: Column(
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              decoration:
                  const InputDecoration(hintText: "Enter the name here..."),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel")),
        TextButton(
            onPressed: () async {
              final asset =
                  await rootBundle.loadString("assets/xml/defaultRecord.xml");
              final record = Record(XmlDocument.parse(asset),
                  RecordMetadata(controller.text, const Uuid().v8(), false));

              setState(() {
                RecordsManager.records.add(record);
                RecordsManager.saveRecord(record);
                Fluttertoast.showToast(msg: "Created a new save record");
              });
              Navigator.of(context).pop();
              widget.onCreated();
            },
            child: const Text("Continue"))
      ],
    );
  }
}
