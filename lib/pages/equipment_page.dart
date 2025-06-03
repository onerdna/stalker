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
import 'package:stalker/equipment_type.dart';
import 'package:stalker/equipment.dart';
import 'package:stalker/pages/inventory_view.dart';
import 'package:stalker/records_manager.dart';

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

  void _becomeTitan(BuildContext context) {
    for (var e in [
      (EquipmentType.weapon, "WEAPON_TITAN_GIANT_SWORD"),
      (EquipmentType.ranged, "RANGED_TITANS_HARPOON"),
      (EquipmentType.magic, "MAGIC_MIND_THROW"),
      (EquipmentType.armor, "BODY_TITAN"),
      (EquipmentType.helm, "HEAD_TITAN")
    ]) {
      var equipment = RecordsManager.activeRecord!.equipment[e.$1]
          ?.where((i) => i.id == e.$2)
          .firstOrNull;
      if (equipment == null) {
        equipment = Equipment(e.$1, e.$2, 52, 4);
        RecordsManager.activeRecord!.equipment[e.$1]!.add(equipment);
      }
      RecordsManager.activeRecord!.setEquipped(equipment);
    }

    RecordsManager.saveRecord(RecordsManager.activeRecord!)
        .then((_) => Fluttertoast.showToast(msg: "Became Titan!"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1,
      padding: EdgeInsets.zero,
      shrinkWrap: false,
      children: [
        (
          "Weapon",
          "assets/images/katana.png",
          () => {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const InventoryView(EquipmentType.weapon)))
              }
        ),
        (
          "Ranged",
          "assets/images/shuriken.png",
          () => {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const InventoryView(EquipmentType.ranged)))
              }
        ),
        (
          "Magic",
          "assets/images/amulet.png",
          () => {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const InventoryView(EquipmentType.magic)))
              }
        ),
        (
          "Armor",
          "assets/images/armor.png",
          () => {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const InventoryView(EquipmentType.armor)))
              }
        ),
        (
          "Helm",
          "assets/images/helm.png",
          () => {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const InventoryView(EquipmentType.helm)))
              }
        ),
        (
          "Become Titan",
          "assets/images/robot-assistant.png",
          () => _becomeTitan(context)
        ),
      ].map((entry) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceTint
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16)),
              child: TextButton(
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    shape: const ContinuousRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)))),
                onPressed: () => entry.$3(),
                child: Image.asset(entry.$2, width: 64, height: 64),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              entry.$1,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        );
      }).toList(),
    ));
  }
}
