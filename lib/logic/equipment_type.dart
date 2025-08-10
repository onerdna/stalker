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

enum EquipmentType { weapon, ranged, magic, armor, helm }

extension EquipmentTypeExtension on EquipmentType {
  static EquipmentType? fromId(String prefix) {
    if (prefix.contains("WEAPON")) {
      return EquipmentType.weapon;
    } else if (prefix.contains("RANGED")) {
      return EquipmentType.ranged;
    } else if (prefix.contains("MAGIC")) {
      return EquipmentType.magic;
    } else if (prefix.contains("ARMOR") || prefix.contains("BODY")) {
      return EquipmentType.armor;
    } else if (prefix.contains("HELM") || prefix.contains("HEAD")) {
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
