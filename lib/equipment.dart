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

import 'package:stalker/enchantment.dart';
import 'package:stalker/equipment_type.dart';
import 'package:stalker/item_database.dart';
import 'package:stalker/record.dart';
import 'package:xml/xml.dart';

class Equipment {
  final EquipmentType type;
  final String id;
  late final String name;
  late final String description;
  final String? acquireType;
  int level = 0;
  int upgrade = 0;

  List<AppliedEnchantment> enchantments = [];

  Equipment.fromUpgradeString(this.type, this.id, String upgradeLevel,
      {this.acquireType}) {
    if (int.parse(upgradeLevel) < 0 || int.parse(upgradeLevel) > 5240) {
      upgradeLevel = "100";
    }
    level = int.parse(upgradeLevel.substring(0, upgradeLevel.length - 2));
    upgrade = int.parse(upgradeLevel.substring(
        upgradeLevel.length - 2, upgradeLevel.length - 1));
    name = ItemDatabase.getName(id);
    description = ItemDatabase.getDescription(id);
  }

  Equipment(this.type, this.id, this.level, this.upgrade, {this.acquireType}) {
    name = ItemDatabase.getName(id);
    description = ItemDatabase.getDescription(id);
  }

  String get _upgradeLevel {
    return "$level${upgrade == 0 ? "00" : upgrade * 10}";
  }

  XmlElement toXml(Record record) {
    return XmlElement(
        XmlName("Item"),
        [
          XmlAttribute(XmlName("Name"), id),
          XmlAttribute(
              XmlName("Equipped"), record.isEquipped(this) ? "1" : "0"),
          XmlAttribute(XmlName("Count"), "1"),
          XmlAttribute(XmlName("UpgradeLevel"), _upgradeLevel),
          XmlAttribute(XmlName("DeliveryTime"), "-1"),
          XmlAttribute(XmlName("DeliveryUpgradeLevel"), "-1"),
          XmlAttribute(XmlName("AcquireType"), acquireType ?? "Upgrade"),
        ],
        enchantments.isEmpty
            ? []
            : [
                XmlElement(XmlName("Enchantments"), [],
                    enchantments.map((e) => e.toXml(type)))
              ]);
  }
}
