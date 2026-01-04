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
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stalker/app.dart';
import 'package:stalker/ui/click_tooltip.dart';
import 'package:stalker/ui/confirm_button.dart';
import 'package:stalker/logic/enchantment.dart';
import 'package:stalker/logic/equipment.dart';
import 'package:stalker/logic/equipment_type.dart';
import 'package:stalker/logic/item_database.dart';
import 'package:stalker/pages/inventory_view/equipment_search_bar.dart';
import 'package:stalker/pages/inventory_view/new_enchantment.dart';
import 'package:stalker/pages/inventory_view/new_item.dart';
import 'package:stalker/logic/records_manager.dart';

class InventoryTile extends StatelessWidget {
  final Widget title;
  final Widget subtitle;
  final List<Widget> children;
  const InventoryTile(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
        color: theme.brightness == Brightness.light
            ? theme.colorScheme.surfaceContainerLowest
            : theme.colorScheme.surfaceTint.withValues(alpha: 0.1),
        child: ExpansionTile(
          collapsedShape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.transparent, width: 0),
          ),
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.transparent, width: 0),
          ),
          title: Padding(padding: const EdgeInsets.only(top: 8), child: title),
          subtitle: Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: subtitle,
          ),
          children: [
            Divider(
              color: theme.colorScheme.surfaceContainer,
              thickness: 1,
            ),
            ...children
          ],
        ));
  }
}

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
    existingEquipment = ItemDatabase.getEquipmentByType(widget.equipmentType);
    _searchEquipment(query);
  }

  @override
  Widget build(BuildContext context) {
    final suggested = _generateSuggestedEntries().toList();
    final owned = _generateOwnedEntries().toList();
    const foundOffset = 1;
    final suggestedOffset = foundOffset + owned.length + 1;
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
                textStyle: Theme.of(context).textTheme.bodyMedium,
                child: const Icon(Icons.info_outline),
              ),
            ],
          )),
      ...owned,
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
        height: 80,
      )
    ];
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 32.0, left: 8, right: 8),
        child: Scrollbar(
            interactive: true,
            thickness: 10,
            child: ListView.separated(
                itemBuilder: (context, index) {
                  if ((index >= foundOffset &&
                          index < foundOffset + owned.length) ||
                      (index >= suggestedOffset &&
                          index < suggestedOffset + suggested.length)) {
                    final borderRadius = BorderRadius.vertical(
                        top: Radius.circular(
                            (index == foundOffset || index == suggestedOffset)
                                ? 24
                                : 4),
                        bottom: Radius.circular(
                            (index == owned.length - foundOffset + 1) ||
                                    (index ==
                                        suggestedOffset + suggested.length - 1)
                                ? 24
                                : 4));
                    return ClipRRect(
                        borderRadius: borderRadius, child: children[index]);
                  } else {
                    return children[index];
                  }
                },
                separatorBuilder: (_, __) => const SizedBox(height: 2.5),
                itemCount: children.length,
                shrinkWrap: true)),
      ),
      floatingActionButton: const FloatingActionButton(
        onPressed: InventoryView.save,
        child: Icon(Icons.save),
      ),
    );
  }

  Iterable<Widget> _generateOwnedEntries() {
    final theme = Theme.of(context);
    return foundEquipment.asMap().entries.map((entry) {
      final item = entry.value;
      final isEquipped = RecordsManager.activeRecord!.isEquipped(item);

      return InventoryTile(
        title: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkResponse(
                  onTap: () {
                    showConfirmationDialog(
                      const Text("Are you sure?"),
                      const Text(
                        "This item will be deleted from your inventory",
                        style: TextStyle(fontSize: 16),
                      ),
                      context,
                      (ctx) {
                        Navigator.of(ctx).pop();
                        setState(() {
                          foundEquipment.remove(item);
                          ownedEquipment.remove(item);
                          _searchEquipment(query);
                        });
                      },
                    );
                  },
                  radius: 16,
                  containedInkWell: true,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(Icons.delete),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 70),
                        child: Text(
                          item.name,
                          softWrap: true,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: isEquipped
                            ? const Text(
                                "Equipped",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              )
                            : ConfirmButton(
                                onConfirmed: () {
                                  setState(() {
                                    RecordsManager.activeRecord!
                                        .setEquipped(item);
                                  });
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text("Equip"),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        subtitle: Column(
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Text(item.id, style: const TextStyle(fontSize: 13))),
            const SizedBox(
              height: 12,
            ),
            _generateTraitsFor(item.id)
          ],
        ),
        children: [
          if (item.description.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4)),
                child: Container(
                    color: theme.colorScheme.surfaceContainerLow,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(item.description),
                    )),
              ),
            ),
            Divider(
              color: theme.colorScheme.surfaceContainer,
              thickness: 1,
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: theme.colorScheme.surfaceContainerLow,
                child: ExpansionTile(
                  initiallyExpanded: true,
                  collapsedShape: const RoundedRectangleBorder(
                    side: BorderSide(color: Colors.transparent, width: 0),
                  ),
                  shape: const RoundedRectangleBorder(
                    side: BorderSide(color: Colors.transparent, width: 0),
                  ),
                  title: Row(
                    children: [
                      if (item.enchantments.isNotEmpty)
                        IconButton(
                          onPressed: () {
                            showConfirmationDialog(
                                const Text("Are you sure?"),
                                const Text(
                                    "This will discard all enchantments from this item"),
                                context, (ctx) {
                              Navigator.of(ctx).pop();
                              setState(() {
                                item.enchantments.clear();
                              });
                            });
                          },
                          icon: const Icon(
                            Icons.close,
                            size: 16,
                          ),
                        ),
                      const Text("Enchantments"),
                    ],
                  ),
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
                                    onPressed: (selected, amount) {
                                      setState(() {
                                        for (var i = 0; i < amount; i++) {
                                          item.enchantments.add(
                                            AppliedEnchantment(
                                              selected,
                                              selected.group.hasAspect
                                                  ? AppliedEnchantment.maxAspect
                                                  : null,
                                            ),
                                          );
                                        }
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
            ),
          ),
          if (item.recipeDelivery != null) ...[
            Divider(
              color: theme.colorScheme.surfaceContainer,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: theme.colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(spacing: 8, children: [
                      Row(
                        spacing: 16,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  item.recipeDelivery = null;
                                });
                              },
                              icon: const Icon(Icons.delete)),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Recipe in progress",
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      Text("Recipe: ${item.recipeDelivery!.tier.name}",
                          style: theme.textTheme.bodyLarge),
                      Text(
                        "Finishes: ${item.recipeDelivery!.time.toString()}",
                        style: theme.textTheme.bodyLarge,
                      ),
                      if (item.recipeDelivery!.time
                          .isAfter(DateTime.now())) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                "Time left: ${item.recipeDelivery!.time.difference(DateTime.now())}",
                                style: theme.textTheme.bodyLarge),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: IconButton(
                                  onPressed: () {
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.replay)),
                            )
                          ],
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            setState(() {
                              item.recipeDelivery!.time = DateTime.now();
                              Fluttertoast.showToast(msg: "Meido In Hebun!");
                            });
                          },
                          label: const Text("Skip"),
                          icon: const Icon(Icons.fast_forward),
                        )
                      ] else
                        Row(
                          spacing: 4,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check, color: Colors.green),
                            Text("Already Done",
                                style: theme.textTheme.titleMedium),
                          ],
                        )
                    ]),
                  ),
                ),
              ),
            )
          ],
          if (item.upgradeDelivery != null) ...[
            Divider(
              color: theme.colorScheme.surfaceContainer,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: theme.colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(spacing: 8, children: [
                      Row(
                        spacing: 16,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  item.upgradeDelivery = null;
                                });
                              },
                              icon: const Icon(Icons.delete)),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Upgrade in progress",
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      if (item.upgradeDelivery!.level != item.level)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 4,
                          children: [
                            Text("Level: ${item.level}",
                                style: theme.textTheme.bodyLarge),
                            const Icon(Icons.arrow_right_alt),
                            Text("${item.upgradeDelivery!.level}",
                                style: theme.textTheme.bodyLarge)
                          ],
                        ),
                      if (item.upgradeDelivery!.upgrade != item.upgrade &&
                          item.upgrade != 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 4,
                          children: [
                            Text("Upgrade level: ${item.upgrade}",
                                style: theme.textTheme.bodyLarge),
                            const Icon(Icons.arrow_right_alt),
                            Text("${item.upgradeDelivery!.upgrade}",
                                style: theme.textTheme.bodyLarge)
                          ],
                        ),
                      Text(
                        "Finishes: ${item.upgradeDelivery!.time.toString()}",
                        style: theme.textTheme.bodyLarge,
                      ),
                      if (item.upgradeDelivery!.time
                          .isAfter(DateTime.now())) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                "Time left: ${item.upgradeDelivery!.time.difference(DateTime.now())}",
                                style: theme.textTheme.bodyLarge),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: IconButton(
                                  onPressed: () {
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.replay)),
                            )
                          ],
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            setState(() {
                              item.upgradeDelivery!.time = DateTime.now();
                              Fluttertoast.showToast(msg: "Meido In Hebun!");
                            });
                          },
                          label: const Text("Skip"),
                          icon: const Icon(Icons.fast_forward),
                        )
                      ] else
                        Row(
                          spacing: 4,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check, color: Colors.green),
                            Text("Already Done",
                                style: theme.textTheme.titleMedium),
                          ],
                        )
                    ]),
                  ),
                ),
              ),
            )
          ],
          Divider(
            color: theme.colorScheme.surfaceContainer,
            thickness: 1,
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
                    min: Equipment.minLevel.toDouble(),
                    max: Equipment.maxLevel.toDouble(),
                    divisions: Equipment.maxLevel - Equipment.minLevel,
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
                      min: Equipment.minUpgrade.toDouble(),
                      max: Equipment.maxUpgrade.toDouble(),
                      divisions: Equipment.maxUpgrade - Equipment.minUpgrade,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          )
        ],
      );
    });
  }

  Iterable<Widget> _generateSuggestedEntries() {
    return suggestedEquipment.map((e) {
      final enchantments = ItemDatabase.getEnchantments(e).map((ench) =>
          DecoratedBox(
              decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Color(ench.group.color)),
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

      return InventoryTile(
        title: Row(
          spacing: 8,
          children: [
            InkResponse(
              onTap: () {
                final record = RecordsManager.activeRecord!;
                final equipment =
                    Equipment(widget.equipmentType, e, record.level, 0);
                equipment.enchantments = ItemDatabase.getEnchantments(e)
                    .map((ench) =>
                        AppliedEnchantment(ench, AppliedEnchantment.maxAspect))
                    .toList();
                setState(() {
                  record.equipment[widget.equipmentType]!.add(equipment);
                  _searchEquipment(query);
                });
              },
              radius: 16,
              containedInkWell: true,
              child: const Icon(Icons.add, size: 32),
            ),
            Text(ItemDatabase.getName(e)),
          ],
        ),
        subtitle: Column(
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Text(e, style: const TextStyle(fontSize: 13))),
            const SizedBox(
              height: 12,
            ),
            _generateTraitsFor(e)
          ],
        ),
        children: [
          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                  top: 8, bottom: 16, left: 16, right: 16),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4)),
                child: Container(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(description),
                    )),
              ),
            ),
          if (enchantments.isNotEmpty) ...[
            const Align(
              alignment: Alignment.center,
              child: Text(
                "Enchantments: ",
                style: TextStyle(fontSize: 17),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(top: 8, bottom: 24, left: 8, right: 8),
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
                    t.id.toLowerCase().contains(text))
                .isNotEmpty ||
            ("equipped".contains(text) &&
                RecordsManager.activeRecord!.isEquipped(e)))
        .toList();

    final equipped = foundEquipment
        .indexWhere((item) => RecordsManager.activeRecord!.isEquipped(item));

    if (equipped != -1) {
      final equippedItem = foundEquipment.removeAt(equipped);
      foundEquipment.insert(0, equippedItem);
    }

    suggestedEquipment = existingEquipment
        .where((e) =>
            e.toLowerCase().contains(text) ||
            ItemDatabase.getName(e).toLowerCase().contains(text) ||
            ItemDatabase.getDescription(e).toLowerCase().contains(text) ||
            ItemDatabase.getTraits(e)
                .where((t) =>
                    t.display.toLowerCase().contains(text) ||
                    t.id.toLowerCase().contains(text))
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
