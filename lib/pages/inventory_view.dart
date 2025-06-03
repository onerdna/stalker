// ignore_for_file: use_build_context_synchronously

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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stalker/app.dart';
import 'package:stalker/confirm_button.dart';
import 'package:stalker/enchantment.dart';
import 'package:stalker/equipment.dart';
import 'package:stalker/equipment_type.dart';
import 'package:stalker/item_database.dart';
import 'package:stalker/records_manager.dart';

class InventoryView extends StatefulWidget {
  final EquipmentType type;

  const InventoryView(this.type, {super.key});
  @override
  State<InventoryView> createState() => _InventoryViewState();

  static void save() {
    RecordsManager.saveRecordWithToast(RecordsManager.activeRecord!);
  }
}

class _InventoryViewState extends State<InventoryView> {
  List<Equipment> allEquipment = [];
  List<Equipment> currentEquipment = [];

  @override
  void initState() {
    super.initState();
    allEquipment = RecordsManager.activeRecord!.equipment[widget.type]!;
    currentEquipment = allEquipment;
  }

  @override
  Widget build(BuildContext context) {
    final entries = _generateEntries();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 64.0),
        child: Scrollbar(
          interactive: true,
          thickness: 10,
          child: ListView(
            padding: const EdgeInsets.all(4),
            children: [
              Padding(
                  padding:
                      const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: EquipmentSearchBar(
                          onChanged: (text) {
                            text = text.toLowerCase();
                            setState(() {
                              currentEquipment = allEquipment
                                  .where((e) =>
                                      e.id.toLowerCase().contains(text) ||
                                      e.name.toLowerCase().contains(text) ||
                                      ItemDatabase.getTraits(e.id)
                                          .where((t) =>
                                              t.display
                                                  .toLowerCase()
                                                  .contains(text) ||
                                              t.name
                                                  .toLowerCase()
                                                  .contains(text))
                                          .isNotEmpty ||
                                      ("equipped".contains(text) &&
                                          RecordsManager.activeRecord!
                                              .isEquipped(e)))
                                  .toList();
                            });
                          },
                          onCleared: () {
                            setState(() {
                              currentEquipment = allEquipment;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: "RANGED_SUPER_MINE - Search by ID\nReaver - Search by name\nUnobtainable - Search by traits\nEquipped - Find currently equipped item",
                        decoration: BoxDecoration(
                          border: Border.all(width: 1),
                          borderRadius: BorderRadius.circular(16),
                          color: Theme.of(context).canvasColor
                        ),
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 14
                        ),
                        showDuration: const Duration(seconds: 8),
                        child: const Icon(Icons.info_outline),
                      ),
                    ],
                  )),
              ...entries,
              ListTile(
                title: FilledButton(
                  onPressed: () => showNewEquipmentDialog(),
                  child: const Text("Add..."),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const FloatingActionButton(
        onPressed: InventoryView.save,
        child: Icon(Icons.save),
      ),
    );
  }

  Iterable<Widget> _generateEntries() {
    return currentEquipment.asMap().entries.map((entry) {
      final item = entry.value;
      final isEquipped = RecordsManager.activeRecord!.isEquipped(item);

      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
              border: Border.all(
                  color: isEquipped
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                  width: isEquipped ? 2 : 1),
              borderRadius: const BorderRadius.all(Radius.circular(16))),
          child: ExpansionTile(
            title: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => showConfirmationDialog(
                      const Text("Are you sure"),
                      const Text(
                        "This item will be deleted from your inventory",
                        style: TextStyle(fontSize: 16),
                      ),
                      context, (ctx) {
                    Navigator.of(ctx).pop();
                    setState(() {
                      currentEquipment.remove(item);
                    });
                  }),
                ),
                Expanded(child: Text(item.name)),
                isEquipped
                    ? const Text(
                        "Equipped",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      )
                    : ConfirmButton(
                        onConfirmed: () {
                          setState(() {
                            RecordsManager.activeRecord!.setEquipped(item);
                          });
                        },
                        child: const Text("Equip"),
                      )
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                children: [
                  Align(alignment: Alignment.centerLeft, child: Text(item.id)),
                  const SizedBox(
                    height: 12,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ItemDatabase.getTraits(item.id)
                          .map((trait) => Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color:
                                            Color((0xFF << 24) | trait.color),
                                        width: 2),
                                    borderRadius: BorderRadius.circular(16)),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, top: 4, bottom: 4),
                                  child: Text(
                                    trait.display,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  )
                ],
              ),
            ),
            children: [
              item.description == ""
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(
                          bottom: 16, left: 16, right: 16),
                      child: Text(
                        item.description,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  title: const Text("Enchantments"),
                  children: [
                    ...item.enchantments.map((applied) => Padding(
                          padding: const EdgeInsets.only(left: 24.0),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Row(
                              children: [
                                Expanded(child: Text(applied.enchantment.name)),
                                const Spacer(),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      item.enchantments.remove(applied);
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                  ),
                                ),
                                const SizedBox(width: 20),
                              ],
                            ),
                            subtitle: applied.aspect == null
                                ? null
                                : Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Row(
                                      children: [
                                        Text("Aspect: ${applied.aspect}"),
                                        Expanded(
                                          child: Slider(
                                            value: applied.aspect!.toDouble(),
                                            onChanged: (v) {
                                              setState(() {
                                                applied.aspect = v.toInt();
                                              });
                                            },
                                            min: 0,
                                            max: AppliedEnchantment.maxAspect
                                                .toDouble(),
                                            divisions:
                                                AppliedEnchantment.maxAspect,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: ListTile(
                        title: OutlinedButton(
                          onPressed: () {
                            showAddEnchantmentDialog(widget.type)
                                .future
                                .then((selected) {
                              if (selected != null) {
                                setState(() {
                                  item.enchantments.add(
                                    AppliedEnchantment(
                                      selected,
                                      selected.tier == EnchantmentTier.mythical
                                          ? null
                                          : 0,
                                    ),
                                  );
                                });
                                Navigator.of(context).pop();
                              }
                            });
                          },
                          child: const Text("Add..."),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: ListTile(
                  title: Row(
                    children: [
                      Text("Level: ${item.level}"),
                      Slider(
                        value: item.level.toDouble(),
                        onChanged: (n) {
                          setState(() => item.level = n.toInt());
                        },
                        min: 1,
                        max: 52,
                        divisions: 51,
                      ),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                          "Upgrade level: ${item.upgrade == 0 ? "Not upgraded" : item.upgrade}"),
                      Expanded(
                        child: Slider(
                          value: item.upgrade.toDouble(),
                          onChanged: (n) {
                            setState(() => item.upgrade = n.toInt());
                          },
                          min: 0,
                          max: 4,
                          divisions: 4,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  Completer<Enchantment?> showAddEnchantmentDialog(EquipmentType type) {
    Completer<Enchantment?> selected = Completer();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text("Add an enchantment")),
        content: SizedBox(
          width: double.maxFinite,
          height: double.maxFinite,
          child: ListView(
            children: [
              const Center(
                child: Text(
                  "Simple Enchantments",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ...enchantments
                  .where((e) =>
                      e.idFor(type) != null && e.tier == EnchantmentTier.simple)
                  .map((e) => FilledButton(
                      onPressed: () {
                        selected.complete(e);
                      },
                      child: Text(e.name))),
              const Center(
                child: Text(
                  "Medium Enchantments",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ...enchantments
                  .where((e) =>
                      e.idFor(type) != null && e.tier == EnchantmentTier.medium)
                  .map((e) => FilledButton(
                      onPressed: () {
                        selected.complete(e);
                      },
                      child: Text(e.name))),
              const Center(
                child: Text(
                  "Mythical Enchantments",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ...enchantments
                  .where((e) =>
                      e.idFor(type) != null &&
                      e.tier == EnchantmentTier.mythical)
                  .map((e) => FilledButton(
                      onPressed: () {
                        selected.complete(e);
                      },
                      child: Text(e.name))),
            ],
          ),
        ),
      ),
    ).then((_) {
      if (!selected.isCompleted) {
        selected.complete(null);
      }
    });

    return selected;
  }

  Future<void> showNewEquipmentDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add a new item"),
        content: TextField(
          autocorrect: false,
          autofocus: true,
          maxLines: 1,
          decoration: const InputDecoration(
            hintText: "Enter item ID...",
            errorText: null,
          ),
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  RecordsManager.activeRecord!.equipment[widget.type]!
                      .add(Equipment(widget.type, controller.text, 1, 0));
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.dispose();
    });
  }
}

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
