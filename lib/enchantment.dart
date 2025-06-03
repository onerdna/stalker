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
import 'package:toml/toml.dart';
import 'package:xml/xml.dart';

enum EnchantmentTier { simple, medium, mythical }

class Enchantment {
  final String name;
  final EnchantmentTier tier;
  final Map<EquipmentType, String> ids;

  const Enchantment(this.name, this.tier, this.ids);

  factory Enchantment.fromToml(MapEntry<String, Map<String, String>> entry, EnchantmentTier tier) {
    return Enchantment(entry.key, tier, entry.value.map((k, v) => MapEntry(EquipmentType.values.byName(k), v)));
  }

  String? idFor(EquipmentType type) => ids[type];
}

List<Enchantment> enchantments = [];

Future<void> loadEnchantments() async {
  enchantments.clear();
  for (final tier in EnchantmentTier.values) {
    final Map tomlMap = TomlDocument.parse(await rootBundle
            .loadString("assets/enchantments/${_mapFileNames(tier)}.toml"))
        .toMap();
    enchantments.addAll(tomlMap.entries.map((e) => Enchantment.fromToml(MapEntry(e.key as String, (e.value as Map).cast<String, String>()), tier)));
  }
}

Enchantment? findById(EquipmentType type, String id) {
  return enchantments.where((e) => e.idFor(type) == id).firstOrNull;
}

String _mapFileNames(EnchantmentTier tier) {
  switch (tier) {
    case EnchantmentTier.simple:
      return "simple";
    case EnchantmentTier.medium:
      return "medium";
    case EnchantmentTier.mythical:
      return "mythical";
  }
}

Enchantment? enchantmentFromId(String id) {
  return enchantments.where((e) => e.ids.values.contains(id)).firstOrNull;
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
