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

import 'package:stalker/logic/item_database.dart';

enum EquipmentType { weapon, ranged, magic, armor, helm }

extension EquipmentTypeExtension on EquipmentType {
  static EquipmentType? fromId(String equipmentId) {
    final overrideType = ItemDatabase.getOverrideType(equipmentId);
    if (overrideType != null) {
      return overrideType;
    }
    if (equipmentId.contains("WEAPON")) {
      return EquipmentType.weapon;
    } else if (equipmentId.contains("RANGED")) {
      return EquipmentType.ranged;
    } else if (equipmentId.contains("MAGIC")) {
      return EquipmentType.magic;
    } else if (equipmentId.contains("ARMOR") || equipmentId.contains("BODY")) {
      return EquipmentType.armor;
    } else if (equipmentId.contains("HELM") || equipmentId.contains("HEAD")) {
      return EquipmentType.helm;
    } else {
      return null;
    }
  }

  String get slot {
    switch (this) {
      case EquipmentType.weapon:
        return "Weapon";
      case EquipmentType.ranged:
        return "Ranged";
      case EquipmentType.magic:
        return "Magic";
      case EquipmentType.armor:
        return "Armor";
      case EquipmentType.helm:
        return "Helm";
    }
  }

  String get display => slot;
}
