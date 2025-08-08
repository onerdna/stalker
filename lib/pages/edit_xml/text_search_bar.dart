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

class TextSearchBar extends StatefulWidget {
  final void Function(String) onSubmitted;
  final VoidCallback onCleared;

  const TextSearchBar(
      {super.key, required this.onSubmitted, required this.onCleared});

  @override
  State<TextSearchBar> createState() => _TextSearchBarState();
}

class _TextSearchBarState extends State<TextSearchBar> {
  final controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
        hintText: "Search...",
        onSubmitted: widget.onSubmitted,
        controller: controller,
        focusNode: focusNode,
        trailing: [
          IconButton(
              onPressed: () {
                controller.clear();
                focusNode.unfocus();
                widget.onCleared();
              },
              icon: const Icon(Icons.clear))
        ]);
  }
}
