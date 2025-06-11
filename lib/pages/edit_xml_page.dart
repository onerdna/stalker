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

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stalker/record.dart';
import 'package:stalker/records_manager.dart';
import 'package:xml/xml.dart';

class EditXmlPage extends StatefulWidget {
  const EditXmlPage({super.key});

  @override
  State<EditXmlPage> createState() => _EditXmlPageState();
}

class _EditXmlPageState extends State<EditXmlPage> {
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textController.text = RecordsManager.activeRecord!.xml;
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void save() {
    try {
      final tree = XmlDocument.parse(textController.text);
      RecordsManager.records[
              RecordsManager.records.indexOf(RecordsManager.activeRecord!)] =
          Record(tree, RecordsManager.activeRecord!.metadata);
      RecordsManager.saveRecordWithToast(RecordsManager.activeRecord!);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        FilledButton(
            onPressed: save,
            child: const Wrap(
              spacing: 8,
              children: [
                Icon(
                  Icons.save,
                  size: 24,
                ),
                Text(
                  "Save",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            )),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Scrollbar(
              thumbVisibility: true,
              thickness: 8,
              interactive: true,
              child: SingleChildScrollView(
                child: TextField(
                  controller: textController,
                  maxLines: null,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainer,
                    border: const OutlineInputBorder(),
                    hintText: 'Type here...',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
