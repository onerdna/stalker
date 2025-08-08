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
import 'package:stalker/ui/click_tooltip.dart';
import 'package:stalker/logic/enchantment.dart';
import 'package:stalker/logic/equipment_type.dart';

class NewEnchantmentDialog extends StatefulWidget {
  final List<Enchantment> enchantments;
  final EquipmentType type;
  final void Function(Enchantment) onPressed;

  const NewEnchantmentDialog(
      {required this.enchantments,
      required this.type,
      required this.onPressed,
      super.key});

  @override
  State<NewEnchantmentDialog> createState() => _NewEnchantmentDialogState();
}

class _NewEnchantmentDialogState extends State<NewEnchantmentDialog> {
  static const sections = [
    (EnchantmentTier.simple, "Simple Enchantments"),
    (EnchantmentTier.medium, "Medium Enchantments"),
    (EnchantmentTier.mythical, "Mythical Enchantments")
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(child: Text("Add an enchantment")),
      content: SizedBox(
        width: double.maxFinite,
        height: double.maxFinite,
        child: ListView(
            children: sections
                .map((ench) => [
                      Center(
                        child: Text(
                          ench.$2,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      ...EnchantmentsManager.enchantments
                          .where((e) =>
                              e.idFor(widget.type) != null && e.tier == ench.$1)
                          .map((e) => Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: FilledButton(
                                        onPressed: () => widget.onPressed(e),
                                        child: Text(e.name)),
                                  ),
                                  if (e.description != null) ...[
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    ClickTooltip(
                                      message: e.description,
                                      decoration: BoxDecoration(
                                          border: Border.all(width: 1),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          color: Theme.of(context).canvasColor),
                                      textStyle: Theme.of(context).textTheme.bodySmall,
                                      child: const Icon(Icons.info_outline),
                                    )
                                  ]
                                ],
                              ))
                    ])
                .expand((e) => e)
                .toList()),
      ),
    );
  }
}
