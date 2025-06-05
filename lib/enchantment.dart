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

import 'package:flutter/services.dart';
import 'package:stalker/equipment_type.dart';
import 'package:stalker/main.dart';
import 'package:toml/toml.dart';
import 'package:xml/xml.dart';

enum EnchantmentTier { simple, medium, mythical }

extension EnchantmentTierExtension on EnchantmentTier {
  String get fileName {
    switch (this) {
      case EnchantmentTier.simple:
        return "simple";
      case EnchantmentTier.medium:
        return "medium";
      case EnchantmentTier.mythical:
        return "mythical";
    }
  }

  int get color {
    switch (this) {
      case EnchantmentTier.simple:
        return 0xFF254D70;
      case EnchantmentTier.medium:
        return 0xFFE6521F;
      case EnchantmentTier.mythical:
        return 0xFF441752;
    }
  }
}

class Enchantment {
  final String name;
  final String id;
  final EnchantmentTier tier;
  final Map<EquipmentType, String> ids;

  const Enchantment(this.name, this.id, this.tier, this.ids);

  factory Enchantment.fromToml(
      MapEntry<String, dynamic> entry, EnchantmentTier tier) {
    if (tier != EnchantmentTier.mythical) {
      logger.i('entry.key=${entry.key}');
    }

    if (tier == EnchantmentTier.mythical) {
      final id = entry.value["id"] as String;
      return Enchantment(
        entry.value["name"] as String,
        entry.key,
        tier,
        {
          EquipmentType.weapon: id,
          EquipmentType.ranged: id,
          EquipmentType.magic: id,
          EquipmentType.armor: id,
          EquipmentType.helm: id,
        },
      );
    } else {
      final equipmentIdsRaw =
          entry.value["equipment_ids"] as Map<String, dynamic>;
      final equipmentIds = equipmentIdsRaw.map(
        (k, v) => MapEntry(EquipmentType.values.byName(k), v as String),
      );

      return Enchantment(
        entry.value["name"] as String,
        entry.key,
        tier,
        equipmentIds,
      );
    }
  }

  String? idFor(EquipmentType type) => ids[type];
}

class EnchantmentsManager {
  static List<Enchantment> enchantments = [];

  static Future<void> loadFromFiles() async {
    enchantments.clear();
    for (final tier in EnchantmentTier.values) {
      final tomlString = await rootBundle
          .loadString("assets/enchantments/${tier.fileName}.toml");
      final tomlMap = TomlDocument.parse(tomlString).toMap();
      enchantments.addAll(tomlMap.entries.map((e) {
        final id = e.key;
        final data = e.value as Map<String, dynamic>;
        return Enchantment.fromToml(MapEntry(id, data), tier);
      }));
    }
  }

  static Enchantment? findByEquipmentTypeId(EquipmentType type, String id) {
    return enchantments.where((e) => e.idFor(type) == id).firstOrNull;
  }

  static Enchantment? findByAnyEquipmentTypeId(String id) {
    return enchantments.where((e) => e.ids.values.contains(id)).firstOrNull;
  }

  static Enchantment? findById(String id) {
    return enchantments.where((e) => e.id == id).firstOrNull;
  }
}

class AppliedEnchantment {
  final Enchantment enchantment;
  int? aspect;
  static const int maxAspect = 2001;

  AppliedEnchantment(this.enchantment, this.aspect);

  XmlElement toXml(EquipmentType type) {
    final id = enchantment.idFor(type);
    if (id == null) {
      throw ArgumentError('Enchantment not applicable to $type');
    }

    return XmlElement(
      XmlName("Perk"),
      [XmlAttribute(XmlName("Name"), id)],
      aspect == null
          ? []
          : [
              XmlElement(XmlName("Set"),
                  [XmlAttribute(XmlName("Aspect"), aspect.toString())])
            ],
    );
  }
}
