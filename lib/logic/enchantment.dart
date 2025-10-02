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

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:stalker/logic/equipment_type.dart';
import 'package:toml/toml.dart';
import 'package:xml/xml.dart';

class EnchantmentGroup {
  final String id;
  final String displayName;
  final int color;
  final int order;
  final bool hasAspect;

  EnchantmentGroup(this.id, this.displayName, this.color, this.order, this.hasAspect);

  factory EnchantmentGroup.fromToml(Map<String, dynamic> tomlMap) {
    return EnchantmentGroup(tomlMap["id"], tomlMap["displayName"],
        int.parse(tomlMap["color"]), tomlMap["order"], tomlMap["hasAspect"] ?? true);
  }
}

class Enchantment {
  final String name;
  final String id;
  final String? description;
  final Map<EquipmentType, String> ids;
  final EnchantmentGroup group;

  const Enchantment(this.name, this.id, this.description, this.ids, this.group);

  factory Enchantment.fromToml(
      MapEntry<String, dynamic> entry, EnchantmentGroup group) {
    if (entry.value.containsKey("id")) {
      final id = entry.value["id"] as String;
      return Enchantment(
          entry.value["name"] as String,
          entry.key,
          entry.value["description"] as String?,
          {
            EquipmentType.weapon: id,
            EquipmentType.ranged: id,
            EquipmentType.magic: id,
            EquipmentType.armor: id,
            EquipmentType.helm: id,
          },
          group);
    } else {
      final equipmentIdsRaw =
          entry.value["equipment_ids"] as Map<String, dynamic>;
      final equipmentIds = equipmentIdsRaw.map(
        (k, v) => MapEntry(EquipmentType.values.byName(k), v as String),
      );

      return Enchantment(entry.value["name"] as String, entry.key,
          entry.value["description"] as String?, equipmentIds, group);
    }
  }

  String? idFor(EquipmentType type) => ids[type];
}

class EnchantmentsManager {
  static List<Enchantment> enchantments = [];
  static List<EnchantmentGroup> groups = [];

  static Future<void> loadFromFiles() async {
    enchantments.clear();
    groups.clear();
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    for (final file in manifestMap.keys
        .where((key) => key.startsWith("assets/enchantments"))
        .toList()) {
      final tomlString = await rootBundle.loadString(file);
      final tomlMap = TomlDocument.parse(tomlString).toMap();
      final group = EnchantmentGroup.fromToml(tomlMap["group"]);
      tomlMap.remove("group");
      groups.add(group);
      enchantments.addAll(tomlMap.entries.map((e) {
        final data = e.value as Map<String, dynamic>;
        return Enchantment.fromToml(MapEntry(e.key, data), group);
      }));
      groups.sort((a, b) => a.order.compareTo(b.order));
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
