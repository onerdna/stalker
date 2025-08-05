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
import 'package:stalker/pages/edit_xml/text_search_bar.dart';
import 'package:stalker/record.dart';
import 'package:stalker/records_manager.dart';
import 'package:xml/xml.dart';

class EditXmlPage extends StatefulWidget {
  const EditXmlPage({super.key});

  @override
  State<EditXmlPage> createState() => _EditXmlPageState();
}

class _EditXmlPageState extends State<EditXmlPage> {
  final textController = TextEditingController();
  final focusNode = FocusNode();
  final scrollController = ScrollController();
  bool searchCaseSensitivity = false;

  List<TextRange> searchMatches = [];
  int currentMatchIndex = 0;

  @override
  void initState() {
    super.initState();
    textController.text = RecordsManager.activeRecord!.xml;
  }

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    focusNode.dispose();
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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => save(),
        child: const Icon(Icons.save),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: TextSearchBar(
                    onSubmitted: (query) {
                      if (query.trim().isEmpty) return;
                      setState(() {
                        _updateMatches(query.trim());
                        _jumpToMatch(currentMatchIndex);
                      });
                    },
                    onCleared: () {
                      setState(() {
                        currentMatchIndex = 0;
                        searchMatches.clear();
                      });
                      focusNode.unfocus();
                    },
                  ),
                ),
                Column(children: [
                  Row(children: [
                    IconButton.filled(
                        onPressed: () {
                          setState(() {
                            currentMatchIndex = _wrapIndex(
                                currentMatchIndex - 1,
                                0,
                                searchMatches.length - 1);
                          });
                          _jumpToMatch(currentMatchIndex);
                        },
                        icon: const Icon(Icons.arrow_upward)),
                    IconButton.filled(
                        onPressed: () {
                          setState(() {
                            currentMatchIndex = _wrapIndex(
                                currentMatchIndex + 1,
                                0,
                                searchMatches.length - 1);
                          });
                          _jumpToMatch(currentMatchIndex);
                        },
                        icon: const Icon(Icons.arrow_downward))
                  ]),
                  if (searchMatches.isNotEmpty)
                    Text(
                        "Current match: ${currentMatchIndex + 1}/${searchMatches.length}",
                        style: Theme.of(context).textTheme.bodySmall)
                ])
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Case sensitivity"),
              Checkbox(
                  value: searchCaseSensitivity,
                  onChanged: (value) {
                    setState(() {
                      searchCaseSensitivity = value ?? false;
                    });
                  }),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              child: Scrollbar(
                controller: scrollController,
                thumbVisibility: true,
                thickness: 8,
                interactive: true,
                child: TextField(
                  controller: textController,
                  focusNode: focusNode,
                  maxLines: null,
                  scrollController: scrollController, // Connect to TextField
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
        ],
      ),
    );
  }

  void _jumpToMatch(int index) {
    if (searchMatches.isEmpty || index >= searchMatches.length) return;

    final match = searchMatches[index];
    textController.selection = TextSelection(
      baseOffset: match.start,
      extentOffset: match.end,
    );

    focusNode.requestFocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final editableTextState =
          focusNode.context?.findAncestorStateOfType<EditableTextState>();
      editableTextState?.bringIntoView(TextPosition(offset: match.start));
    });
  }

  void _updateMatches(String query) {
    final text = textController.text;

    searchMatches.clear();
    if (query.isEmpty) return;

    final regExp =
        RegExp(RegExp.escape(query), caseSensitive: searchCaseSensitivity);
    searchMatches = regExp
        .allMatches(text)
        .map((m) => TextRange(start: m.start, end: m.end))
        .toList();

    currentMatchIndex = 0;
  }

  int _wrapIndex(int value, int min, int max) {
    final range = max - min + 1;
    return ((value - min) % range + range) % range + min;
  }
}
