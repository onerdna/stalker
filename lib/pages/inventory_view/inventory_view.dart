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

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stalker/app.dart';
import 'package:stalker/click_tooltip.dart';
import 'package:stalker/confirm_button.dart';
import 'package:stalker/enchantment.dart';
import 'package:stalker/equipment.dart';
import 'package:stalker/equipment_type.dart';
import 'package:stalker/item_database.dart';
import 'package:stalker/pages/inventory_view/equipment_search_bar.dart';
import 'package:stalker/pages/inventory_view/new_enchantment.dart';
import 'package:stalker/pages/inventory_view/new_item.dart';
import 'package:stalker/records_manager.dart';

class InventoryView extends StatefulWidget {
  final EquipmentType equipmentType;

  const InventoryView(this.equipmentType, {super.key});
  @override
  State<InventoryView> createState() => _InventoryViewState();

  static void save() {
    RecordsManager.saveRecordWithToast(RecordsManager.activeRecord!);
  }
}

class _InventoryViewState extends State<InventoryView> {
  List<Equipment> ownedEquipment = [];
  List<Equipment> foundEquipment = [];
  Iterable<String> suggestedEquipment = [];
  Iterable<String> existingEquipment = [];
  String query = "";

  @override
  void initState() {
    super.initState();
    ownedEquipment =
        RecordsManager.activeRecord!.equipment[widget.equipmentType]!;
    foundEquipment = ownedEquipment;
    existingEquipment = ItemDatabase.getEquipment(widget.equipmentType);
    _searchEquipment(query);
  }

  @override
  Widget build(BuildContext context) {
    final suggested = _generateSuggestedEntries();
    final children = [
      Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
          child: Row(
            children: [
              Expanded(
                child: EquipmentSearchBar(
                  onChanged: (text) {
                    setState(() {
                      query = text.toLowerCase();
                      _searchEquipment(query);
                    });
                  },
                  onCleared: () {
                    setState(() {
                      foundEquipment = ownedEquipment;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              ClickTooltip(
                message:
                    "RANGED_SUPER_MINE - Search by ID\nReaver - Search by name\nUnobtainable - Search by traits\nBecomes immobile - Search by description\nEquipped - Find currently equipped item",
                decoration: BoxDecoration(
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).canvasColor),
                textStyle: const TextStyle(color: Colors.white, fontSize: 14),
                child: const Icon(Icons.info_outline),
              ),
            ],
          )),
      ..._generateFoundEntries(),
      if (suggested.isNotEmpty)
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.only(left: 8.0, right: 8),
              child: Text(
                "Add new items",
                style: TextStyle(fontSize: 12),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
      ...suggested,
      SizedBox(
        width: double.maxFinite,
        child: FilledButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (ctx) => NewItem(
                    equipmentType: widget.equipmentType,
                    onPressed: (text) {
                      RecordsManager
                          .activeRecord!.equipment[widget.equipmentType]!
                          .add(Equipment(widget.equipmentType, text, 1, 0));
                      setState(() {
                        _searchEquipment(query);
                      });
                    }));
          },
          child: const Text("Add by ID"),
        ),
      ),
      const SizedBox(
        height: 90,
      )
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 64.0),
        child: Scrollbar(
          interactive: true,
          thickness: 10,
          child: ListView.separated(
            itemCount: children.length,
            padding: const EdgeInsets.all(4),
            separatorBuilder: (_, __) => const SizedBox(
              height: 10,
            ),
            itemBuilder: (_, index) => children.elementAt(index),
          ),
        ),
      ),
      floatingActionButton: const FloatingActionButton(
        onPressed: InventoryView.save,
        child: Icon(Icons.save),
      ),
    );
  }

  Iterable<Widget> _generateFoundEntries() {
    return foundEquipment.asMap().entries.map((entry) {
      final item = entry.value;
      final isEquipped = RecordsManager.activeRecord!.isEquipped(item);

      return DecoratedBox(
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
                    const Text("Are you sure?"),
                    const Text(
                      "This item will be deleted from your inventory",
                      style: TextStyle(fontSize: 16),
                    ),
                    context, (ctx) {
                  Navigator.of(ctx).pop();
                  setState(() {
                    foundEquipment.remove(item);
                    ownedEquipment.remove(item);
                    _searchEquipment(query);
                  });
                }),
              ),
              Expanded(child: Text(item.name)),
              isEquipped
                  ? const Text(
                      "Equipped",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                _generateTraitsFor(item.id)
              ],
            ),
          ),
          children: [
            if (item.description.isNotEmpty) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(
                    top: 8, bottom: 16, left: 16, right: 16),
                child: Text(
                  item.description,
                  style: const TextStyle(fontSize: 14),
                ),
              )
            ],
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
                          showDialog(
                              context: context,
                              builder: (ctx) => NewEnchantmentDialog(
                                  enchantments:
                                      EnchantmentsManager.enchantments,
                                  type: widget.equipmentType,
                                  onPressed: (selected) {
                                    setState(() {
                                      item.enchantments.add(
                                        AppliedEnchantment(
                                          selected,
                                          selected.tier ==
                                                  EnchantmentTier.mythical
                                              ? null
                                              : 0,
                                        ),
                                      );
                                    });
                                    Navigator.of(ctx).pop();
                                  }));
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
      );
    });
  }

  Iterable<Widget> _generateSuggestedEntries() {
    return suggestedEquipment.map((e) {
      final enchantments = ItemDatabase.getEnchantments(e).map((ench) =>
          DecoratedBox(
              decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Color(ench.tier.color)),
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 4.0, bottom: 4, right: 12, left: 12),
                child: Text(
                  ench.name,
                  style: const TextStyle(fontSize: 15),
                ),
              )));
      final description = ItemDatabase.getDescription(e);

      return DecoratedBox(
        decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(16)),
        child: ExpansionTile(
          title: Row(
            children: [
              IconButton(
                onPressed: () {
                  final equipment = Equipment(widget.equipmentType, e, 1, 0);
                  equipment.enchantments = ItemDatabase.getEnchantments(e)
                      .map((ench) => AppliedEnchantment(
                          ench,
                          ench.tier == EnchantmentTier.mythical
                              ? null
                              : AppliedEnchantment.maxAspect))
                      .toList();
                  setState(() {
                    RecordsManager
                        .activeRecord!.equipment[widget.equipmentType]!
                        .add(equipment);
                    _searchEquipment(query);
                  });
                  Fluttertoast.showToast(msg: "Added to the inventory");
                },
                icon: const Icon(Icons.add, size: 32),
              ),
              Text(ItemDatabase.getName(e)),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              children: [
                Align(alignment: Alignment.centerLeft, child: Text(e)),
                const SizedBox(
                  height: 12,
                ),
                _generateTraitsFor(e)
              ],
            ),
          ),
          children: [
            if (description.isNotEmpty) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 8, bottom: 16),
                child: Text(description),
              )
            ],
            if (enchantments.isNotEmpty) ...[
              const Divider(),
              const Align(
                alignment: Alignment.center,
                child: Text(
                  "Enchantments: ",
                  style: TextStyle(fontSize: 17),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 8, bottom: 24, left: 8, right: 8),
                child: Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: enchantments.toList(),
                  ),
                ),
              )
            ],
          ],
        ),
      );
    });
  }

  void _searchEquipment(String text) {
    foundEquipment = ownedEquipment
        .where((e) =>
            e.id.toLowerCase().contains(text) ||
            e.name.toLowerCase().contains(text) ||
            ItemDatabase.getDescription(e.id).toLowerCase().contains(text) ||
            ItemDatabase.getTraits(e.id)
                .where((t) =>
                    t.display.toLowerCase().contains(text) ||
                    t.name.toLowerCase().contains(text))
                .isNotEmpty ||
            ("equipped".contains(text) &&
                RecordsManager.activeRecord!.isEquipped(e)))
        .toList();

    suggestedEquipment = existingEquipment
        .where((e) =>
            e.toLowerCase().contains(text) ||
            ItemDatabase.getName(e).toLowerCase().contains(text) ||
            ItemDatabase.getDescription(e).toLowerCase().contains(text) ||
            ItemDatabase.getTraits(e)
                .where((t) =>
                    t.display.toLowerCase().contains(text) ||
                    t.name.toLowerCase().contains(text))
                .isNotEmpty)
        .toSet()
        .difference(foundEquipment.map((e) => e.id).toSet());
  }

  Padding _generateTraitsFor(String id) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ItemDatabase.getTraits(id)
              .map((trait) => Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Color(trait.color), width: 2),
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 4, bottom: 4),
                      child: Text(
                        trait.display,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
