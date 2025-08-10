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
import 'package:stalker/logic/enchantment.dart';
import 'package:stalker/logic/equipment_type.dart';
import 'package:toml/toml.dart';

class ItemTrait {
  final String display;
  final String id;
  final int color;

  @override
  bool operator ==(Object other) => other is ItemTrait && other.id == id;

  const ItemTrait(this.id, this.display, this.color);
}

class ItemDatabase {
  static var dictionary = {};
  static List<ItemTrait> traits = [];

  static Future<Iterable<ItemTrait>> loadTraits() async {
    final tomlContent = await rootBundle.loadString("assets/traits.toml");
    final tomlMap = TomlDocument.parse(tomlContent).toMap();

    return tomlMap.entries.map((e) =>
        ItemTrait(e.key, e.value["display"], int.parse(e.value["color"])));
  }

  static String getName(String id) {
    var name = dictionary[id]?["name"];
    if (name == "") {
      name = id;
    }
    return name ?? id;
  }

  static String getDescription(String id) =>
      dictionary[id]?["description"] ?? "";

  static Iterable<ItemTrait> getTraits(String id) {
    List<String> itemTraits = (dictionary[id]?["traits"] ?? []).cast<String>();
    return itemTraits.map((e) => traits.where((t) => t.id == e).first);
  }

  static Iterable<String> getEquipmentByType(EquipmentType type) =>
      dictionary.entries
          .where((e) => EquipmentTypeExtension.fromId(e.key) == type)
          .map((e) => e.key);

  static Iterable<String> getAllEquipment() =>
      dictionary.entries.map((e) => e.key);

  static Iterable<Enchantment> getEnchantments(String id) {
    final enchantments =
        (dictionary[id]?["enchantments"] ?? []) as List<dynamic>;
    return enchantments.map((e) => EnchantmentsManager.findById(e)!);
  }
}
