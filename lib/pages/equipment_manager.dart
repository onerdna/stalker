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
import 'package:stalker/logic/enchantment.dart';
import 'package:stalker/logic/equipment.dart';
import 'package:stalker/logic/equipment_type.dart';
import 'package:stalker/logic/item_database.dart';
import 'package:stalker/logic/records_manager.dart';
import 'package:stalker/ui/split_filled_button.dart';

class EquipmentManager extends StatefulWidget {
  final Iterable<String> existingEquipment;
  final List<Equipment> ownedEquipment;

  const EquipmentManager(
      {super.key,
      required this.existingEquipment,
      required this.ownedEquipment});

  @override
  State<EquipmentManager> createState() => _EquipmentManagerState();
}

class TraitItem {
  bool enabled = false;
  final ItemTrait trait;

  TraitItem(this.trait) {
    enabled = enabledByDefault();
  }

  bool enabledByDefault() {
    return !["unobtainable", "defunct", "deceased", "set_dragon"].contains(trait.id);
  }
}

class EquipmentItem {
  bool enabled = true;
  final EquipmentType type;

  EquipmentItem(this.type);
}

class _EquipmentManagerState extends State<EquipmentManager> {
  List<TraitItem> traits =
      ItemDatabase.traits.map((e) => TraitItem(e)).toList();
  List<EquipmentItem> equipmentTypes =
      EquipmentType.values.map((e) => EquipmentItem(e)).toList();
  bool selectAllTraits = false;
  bool equipmentWithoutTraits = true;
  int equipmentLevel = Equipment.maxLevel;
  int equipmentUpgrade = Equipment.maxUpgrade;
  bool shouldSaveRecord = true;
  String status = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      equipmentLevel = RecordsManager.activeRecord!.level;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                        value: selectAllTraits,
                        onChanged: (v) => {
                              setState(() {
                                selectAllTraits = v ?? false;
                                for (var e in traits) {
                                  e.enabled = v ?? false;
                                }
                              })
                            }),
                    const Text("Select All")
                  ],
                ),
                Row(
                  children: [
                    Switch(
                        value: equipmentWithoutTraits,
                        onChanged: (v) => {
                              setState(() {
                                equipmentWithoutTraits = v;
                              })
                            }),
                    const Flexible(child: Text("Equipment without traits"))
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, i) => Row(
                      children: [
                        Switch(
                            value: traits[i].enabled,
                            onChanged: (v) => {
                                  setState(() {
                                    traits[i].enabled = v;
                                  })
                                }),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(traits[i].trait.display,
                              softWrap: true, overflow: TextOverflow.visible),
                        ),
                      ],
                    ),
                    itemCount: traits.length,
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(
            width: 16,
            thickness: 2,
            color: Colors.grey,
            indent: 8,
            endIndent: 8,
          ),
          Expanded(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, i) => Row(
                    children: [
                      Checkbox(
                          value: equipmentTypes[i].enabled,
                          onChanged: (v) {
                            setState(() {
                              equipmentTypes[i].enabled = v ?? false;
                            });
                          }),
                      Text(equipmentTypes[i].type.display)
                    ],
                  ),
                  itemCount: equipmentTypes.length,
                ),
                Text("Equipment level: $equipmentLevel"),
                Slider(
                    value: equipmentLevel.toDouble(),
                    onChanged: (v) =>
                        setState(() => equipmentLevel = v.toInt()),
                    min: Equipment.minLevel.toDouble(),
                    max: Equipment.maxLevel.toDouble(),
                    divisions: Equipment.maxUpgrade - Equipment.minUpgrade),
                Text("Upgrade level: $equipmentUpgrade"),
                Slider(
                    value: equipmentUpgrade.toDouble(),
                    onChanged: (v) =>
                        setState(() => equipmentUpgrade = v.toInt()),
                    min: Equipment.minUpgrade.toDouble(),
                    max: Equipment.maxUpgrade.toDouble(),
                    divisions: Equipment.maxUpgrade - Equipment.minUpgrade),
                Row(children: [
                  Checkbox(
                      value: shouldSaveRecord,
                      onChanged: (v) => setState(() {
                            shouldSaveRecord = v ?? false;
                          })),
                  const Text("Save changes")
                ]),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: SplitFilledButton(
                      onLeftPressed: () {
                        // Add
                        final enabledTraits =
                            traits.where((e) => e.enabled).map((e) => e.trait);
                        final equipmentToAdd = widget.existingEquipment
                            .where((e) => equipmentTypes
                                .where((t) => t.enabled)
                                .map((t) => t.type)
                                .contains(EquipmentTypeExtension.fromId(e)!))
                            .where((e) {
                              final itemTraits = ItemDatabase.getTraits(e);
                              return itemTraits
                                      .any((t) => enabledTraits.contains(t)) ||
                                  equipmentWithoutTraits && itemTraits.isEmpty;
                            })
                            .toSet()
                            .difference(
                                widget.ownedEquipment.map((e) => e.id).toSet());
                        for (var equipmentId in equipmentToAdd) {
                          final equipmentType =
                              EquipmentTypeExtension.fromId(equipmentId)!;
                          final equipment = Equipment(equipmentType,
                              equipmentId, equipmentLevel, equipmentUpgrade);
                          equipment.enchantments =
                              ItemDatabase.getEnchantments(equipmentId)
                                  .map((ench) => AppliedEnchantment(
                                      ench,
                                      ench.tier == EnchantmentTier.mythical
                                          ? null
                                          : AppliedEnchantment.maxAspect))
                                  .toList();
                          RecordsManager.activeRecord!.equipment[equipmentType]!
                              .add(equipment);
                          widget.ownedEquipment.add(equipment);
                        }
                        if (shouldSaveRecord) {
                          RecordsManager.saveRecord(
                                  RecordsManager.activeRecord!)
                              .then((_) {
                            setState(() => status =
                                "Added ${equipmentToAdd.length} items");
                          });
                        } else {
                          setState(() {
                            status = "Added ${equipmentToAdd.length} items";
                          });
                        }
                      },
                      onRightPressed: () {
                        final enabledTraits =
                            traits.where((e) => e.enabled).map((e) => e.trait);
                        final equipmentToRemove =
                            widget.ownedEquipment.where((e) {
                          var itemTraits = ItemDatabase.getTraits(e.id);
                          return itemTraits
                                  .any((t) => enabledTraits.contains(t)) ||
                              equipmentWithoutTraits && itemTraits.isEmpty;
                        }).toList();
                        for (var equipment in equipmentToRemove) {
                          RecordsManager.activeRecord!.equipment[equipment.type]
                              ?.remove(equipment);
                          widget.ownedEquipment.remove(equipment);
                        }
                        if (shouldSaveRecord) {
                          RecordsManager.saveRecord(
                                  RecordsManager.activeRecord!)
                              .then((_) {
                            setState(() => status =
                                "Removed ${equipmentToRemove.length} items");
                          });
                        } else {
                          setState(() {
                            status =
                                "Removed ${equipmentToRemove.length} items";
                          });
                        }
                      },
                      leftChild: const Text("Add"),
                      rightChild: const Text("Remove")),
                ),
                Text(status)
              ],
            ),
          )
        ],
      ),
    ));
  }
}
