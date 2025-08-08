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

import "package:flutter/material.dart";
import 'package:stalker/logic/equipment_type.dart';

class NewItem extends StatefulWidget {
  final EquipmentType equipmentType;
  final void Function(String) onPressed;

  const NewItem(
      {required this.onPressed, required this.equipmentType, super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add by ID"),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: "Type ID here..."),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel")),
        TextButton(
          onPressed: () {
            widget.onPressed(controller.text);
            Navigator.of(context).pop();
          },
          child: const Text("Add to the inventory"),
        )
      ],
    );
  }
}
