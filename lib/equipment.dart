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

class UpgradeDelivery {
  DateTime time = DateTime.fromMillisecondsSinceEpoch(0);
  int level = 0;
  int upgrade = 0;

  String get upgradeLevel {
    return "$level${upgrade == 0 ? "00" : upgrade * 10}";
  }

  UpgradeDelivery(this.time, this.level, this.upgrade);
  UpgradeDelivery.fromXml(String upgradeLevel, String deliveryTime) {
    time = DateTime.fromMillisecondsSinceEpoch(int.parse(deliveryTime) * 1000);
    level = int.parse(upgradeLevel.substring(0, upgradeLevel.length - 2));
    upgrade = int.parse(upgradeLevel.substring(
        upgradeLevel.length - 2, upgradeLevel.length - 1));
  }
}

class RecipeDelivery {
  DateTime time = DateTime.fromMillisecondsSinceEpoch(0);
  late EnchantmentTier tier;
  int itemLevel = 0;
  int playerLevel = 0;

  RecipeDelivery(this.tier, this.time, this.itemLevel, this.playerLevel);
  RecipeDelivery.fromXml(
      String tier, String deliveryTime, String itemLevel, String playerLevel) {
    time = DateTime.fromMillisecondsSinceEpoch(int.parse(deliveryTime) * 1000);
    this.itemLevel = int.parse(itemLevel);
    this.playerLevel = int.parse(playerLevel);
    this.tier = EnchantmentTierExtension.tierFromRecipeName(tier)!;
  }
}

class Equipment {
  final EquipmentType type;
  final String id;
  late final String name;
  late final String description;
  final String? acquireType;
  int level = 0;
  int upgrade = 0;
  UpgradeDelivery? upgradeDelivery;
  RecipeDelivery? recipeDelivery;
  static const minLevel = 1;
  static const maxLevel = 52;
  static const minUpgrade = 0;
  static const maxUpgrade = 4;

  List<AppliedEnchantment> enchantments = [];

  Equipment.fromUpgradeString(this.type, this.id, String upgradeLevel,
      {this.acquireType, this.upgradeDelivery, this.recipeDelivery}) {
    if (int.parse(upgradeLevel) < 0 ||
        int.parse(upgradeLevel) > maxLevel * 100 + maxUpgrade * 100) {
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
    List<XmlElement> children = [
      if (enchantments.isNotEmpty)
        XmlElement(XmlName("Enchantments"), [],
            enchantments.map((e) => e.toXml(type))),
      if (recipeDelivery != null)
        XmlElement(XmlName("RecipeDelivery"), [
          XmlAttribute(
              XmlName("Name"), recipeDelivery!.tier.recipeDeliveryName),
          XmlAttribute(
              XmlName("ItemLevel"), recipeDelivery!.itemLevel.toString()),
          XmlAttribute(
              XmlName("PlayerLevel"), recipeDelivery!.playerLevel.toString()),
          XmlAttribute(
              XmlName("DeliveryTime"),
              (recipeDelivery!.time.millisecondsSinceEpoch / 1000)
                  .toInt()
                  .toString()),
        ], [])
    ];
    return XmlElement(
        XmlName("Item"),
        [
          XmlAttribute(XmlName("Name"), id),
          XmlAttribute(
              XmlName("Equipped"), record.isEquipped(this) ? "1" : "0"),
          XmlAttribute(XmlName("Count"), "1"),
          XmlAttribute(XmlName("UpgradeLevel"), _upgradeLevel),
          XmlAttribute(
              XmlName("DeliveryTime"),
              upgradeDelivery == null
                  ? "-1"
                  : (upgradeDelivery!.time.millisecondsSinceEpoch / 1000)
                      .toInt()
                      .toString()),
          XmlAttribute(XmlName("DeliveryUpgradeLevel"),
              upgradeDelivery == null ? "-1" : upgradeDelivery!.upgradeLevel),
          XmlAttribute(XmlName("AcquireType"), acquireType ?? "Upgrade"),
        ],
        children);
  }
}
