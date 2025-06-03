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

enum ItemTrait {
  boss,
  unobtainable,
  specialEdition,
  nintendoSwitchEdition,
  challenger,
  specialEvent,
  offer,
  setMonk,
  setSentinel,
  setWarlock,
  setForestGuardian,
  setSkanda,
  setCreatorsOfTheWind,
  setDirector,
  setChronos,
  setNeoWanderer,
  setSporeSoul,
  setVolcano,
  setKarcer,
}

extension ItemTraitExtension on ItemTrait {
  String get display {
    switch (this) {
      case ItemTrait.boss:
        return "Boss Weapon";
      case ItemTrait.unobtainable:
        return "Unobtainable";
      case ItemTrait.specialEdition:
        return "Special Edition";
      case ItemTrait.nintendoSwitchEdition:
        return "Nintendo Switch Edition";
      case ItemTrait.challenger:
        return "Challenger Weapon";
      case ItemTrait.specialEvent:
        return "Special Event Item";
      case ItemTrait.offer:
        return "Offer Exclusive Item";
      case ItemTrait.setMonk:
        return "Monk Set";
      case ItemTrait.setSentinel:
        return "Sentinel Set";
      case ItemTrait.setWarlock:
        return "Warlock Set";
      case ItemTrait.setForestGuardian:
        return "Forest Guardian Set";
      case ItemTrait.setSkanda:
        return "Skanda Set";
      case ItemTrait.setCreatorsOfTheWind:
        return "Creator of the Winds Set";
      case ItemTrait.setDirector:
        return "Director Set";
      case ItemTrait.setChronos:
        return "Chronos Set";
      case ItemTrait.setNeoWanderer:
        return "Neo-Wanderer Set";
      case ItemTrait.setSporeSoul:
        return "Spore Soul Set";
      case ItemTrait.setVolcano:
        return "Volcano Set";
      case ItemTrait.setKarcer:
        return "Karcer Set";
    }
  }

  int get color {
    switch (this) {
      case ItemTrait.boss:
        return 0xFFD66B;
      case ItemTrait.unobtainable:
        return 0xFF3F33;
      case ItemTrait.specialEdition:
        return 0xE7EFC7;
      case ItemTrait.nintendoSwitchEdition:
        return 0x00CAFF;
      case ItemTrait.challenger:
        return 0xFFAAAA;
      case ItemTrait.specialEvent:
        return 0x5409DA;
      case ItemTrait.offer:
        return 0xDC8BE0;
      case ItemTrait.setMonk:
        return 0x3CB371;

      case ItemTrait.setSentinel:
        return 0xCD5C5C;

      case ItemTrait.setWarlock:
        return 0x8B0000;

      case ItemTrait.setForestGuardian:
        return 0x4B0082;

      case ItemTrait.setSkanda:
        return 0xFFD700;

      case ItemTrait.setCreatorsOfTheWind:
        return 0x708090;

      case ItemTrait.setDirector:
        return 0x808080;

      case ItemTrait.setChronos:
        return 0x1E90FF;

      case ItemTrait.setNeoWanderer:
        return 0x00FFFF;

      case ItemTrait.setSporeSoul:
        return 0xFFFF00;

      case ItemTrait.setVolcano:
        return 0xFF4500;

      case ItemTrait.setKarcer:
        return 0xFFFFFF;
    }
  }
}

class ItemDatabase {
  static var dictionary = {};
  static String resolveName(String id) {
    var name = dictionary[id]?["name"];
    if (name == "") {
      name = id;
    }
    return name ?? id;
  }

  static String resolveDescription(String id) =>
      dictionary[id]?["description"] ?? "";

  static Iterable<ItemTrait> getTraits(String id) {
    List<String> traits = (dictionary[id]?["traits"] ?? []).cast<String>();
    return traits.map((e) => ItemTrait.values.byName(e));
  }
}
