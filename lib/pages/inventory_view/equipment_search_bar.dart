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

class EquipmentSearchBar extends StatefulWidget {
  final void Function(String) onChanged;
  final VoidCallback onCleared;

  const EquipmentSearchBar(
      {super.key, required this.onChanged, required this.onCleared});

  @override
  State<EquipmentSearchBar> createState() => _EquipmentSearchBarState();
}

class _EquipmentSearchBarState extends State<EquipmentSearchBar> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      hintText: "Search...",
      focusNode: focusNode,
      trailing: [
        IconButton(
            onPressed: () {
              controller.clear();
              focusNode.unfocus();
              widget.onCleared();
            },
            icon: const Icon(Icons.clear))
      ],
      onChanged: (text) => widget.onChanged(text),
      controller: controller,
    );
  }
}
