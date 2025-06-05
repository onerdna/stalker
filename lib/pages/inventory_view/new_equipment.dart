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
import 'package:stalker/equipment_type.dart';
import 'package:stalker/item_database.dart';
import 'package:stalker/pages/inventory_view/equipment_search_bar.dart';

class NewEquipmentPage extends StatefulWidget {
  final EquipmentType equipmentType;
  const NewEquipmentPage({required this.equipmentType, super.key});

  @override
  State<NewEquipmentPage> createState() => _NewEquipmentPageState();
}

class _NewEquipmentPageState extends State<NewEquipmentPage> {
  final controller = TextEditingController();
  late Iterable<String> allEquipment = [];
  Iterable<String> searchResults = [];

  @override
  void initState() {
    super.initState();
    allEquipment = ItemDatabase.getEquipment(widget.equipmentType);
    searchResults = allEquipment;
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add a new equipment"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExpansionTile(
                title: const Text("Advanced"),
                subtitle: const Text("Add by ID"),
                children: [
                  TextField(
                    autocorrect: false,
                    autofocus: true,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      hintText: "Enter item ID...",
                      errorText: null,
                    ),
                    controller: controller,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: EquipmentSearchBar(
                      onChanged: (text) {
                        setState(() {
                          _searchForEquipment(text);
                        });
                      },
                      onCleared: () {
                        setState(() {
                          searchResults = allEquipment;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message:
                        "RANGED_SUPER_MINE - Search by ID\nReaver - Search by name\nUnobtainable - Search by traits\nBecomes immobile - Search by description",
                    decoration: BoxDecoration(
                        border: Border.all(width: 1),
                        borderRadius: BorderRadius.circular(16),
                        color: Theme.of(context).canvasColor),
                    textStyle:
                        const TextStyle(color: Colors.white, fontSize: 14),
                    showDuration: const Duration(seconds: 8),
                    child: const Icon(Icons.info_outline),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Flexible(
                child: EquipmentSearchResults(
                  results: searchResults,
                  equipmentType: widget.equipmentType,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _searchForEquipment(String text) {
    text = text.toLowerCase();
    searchResults = allEquipment.where((e) =>
        e.toLowerCase().contains(text) ||
        ItemDatabase.getName(e).toLowerCase().contains(text) ||
        ItemDatabase.getDescription(e).toLowerCase().contains(text) ||
        ItemDatabase.getTraits(e)
            .any((t) => t.name.toLowerCase().contains(text)));
  }
}

class EquipmentSearchResults extends StatelessWidget {
  final Iterable<String> results;
  final EquipmentType equipmentType;

  const EquipmentSearchResults(
      {required this.results, required this.equipmentType, super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
