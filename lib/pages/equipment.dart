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
import 'package:stalker/logic/equipment_type.dart';
import 'package:stalker/logic/equipment.dart';
import 'package:stalker/logic/item_database.dart';
import 'package:stalker/pages/equipment_manager.dart';
import 'package:stalker/pages/inventory_view/inventory_view.dart';
import 'package:stalker/logic/records_manager.dart';

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({super.key});

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  @override
  void initState() {
    super.initState();
  }

  Row generateCheckbox(
      String name, bool value, void Function(bool?) onChanged) {
    return Row(
      children: [
        Text(name),
        const SizedBox(
          width: 50,
        ),
        Checkbox(value: value, onChanged: onChanged)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final gridItems = [
      (
        "Weapon",
        "assets/images/katana.png",
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const InventoryView(EquipmentType.weapon),
            ),
          );
        }
      ),
      (
        "Ranged",
        "assets/images/shuriken.png",
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const InventoryView(EquipmentType.ranged),
            ),
          );
        }
      ),
      (
        "Magic",
        "assets/images/amulet.png",
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const InventoryView(EquipmentType.magic),
            ),
          );
        }
      ),
      (
        "Armor",
        "assets/images/armor.png",
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const InventoryView(EquipmentType.armor),
            ),
          );
        }
      ),
      (
        "Helm",
        "assets/images/helm.png",
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const InventoryView(EquipmentType.helm),
            ),
          );
        }
      ),
      (
        "Equipment Manager",
        "assets/images/weapons.png",
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EquipmentManager(
                existingEquipment: ItemDatabase.getAllEquipment(),
                ownedEquipment: RecordsManager.activeRecord!.equipment.values
                    .expand((e) => e)
                    .toList(),
              ),
            ),
          );
        }
      ),
    ];
    return Scaffold(
        body: GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 0,
          crossAxisSpacing: 8,
          childAspectRatio: 0.88),
      itemCount: gridItems.length,
      itemBuilder: (context, index) {
        final (label, imagePath, onTap) = gridItems[index];
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceTint
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  shape: const ContinuousRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                  ),
                ),
                onPressed: onTap,
                child: Image.asset(imagePath, width: 64, height: 64),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        );
      },
    ));
  }
}
