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
  hw14,
  hw15,
  hw16,
  hw18,
  hw19,
  hw20,
  hw21,
  hw22,
  hw23,
  hw24,
  hw25,
  xmas14,
  xmas15,
  xmas16,
  xmas17,
  xmas18,
  xmas19,
  xmas20,
  xmas21,
  xmas22,
  xmas23,
  xmas24,
  xmas25,
  vd17,
  vd18,
  vd19,
  vd20,
  vd21,
  vd22,
  vd23,
  vd24,
  vd25,
  chny18,
  chny21,
  chny22,
  chny24,
  ramNavami21,
  independence21,
  summer21,
  offer,
  replica,
  gift,
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
  setDragon,
  anniversary10
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
      case ItemTrait.offer:
        return "Offer Exclusive Item";
      case ItemTrait.replica:
        return "Replica";
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
      case ItemTrait.setDragon:
        return "Dragon Set";
      case ItemTrait.hw14:
        return "Halloween 2014";
      case ItemTrait.hw15:
        return "Halloween 2015";
      case ItemTrait.hw16:
        return "Halloween 2016";
      case ItemTrait.hw18:
        return "Halloween 2018";
      case ItemTrait.hw19:
        return "Halloween 2019";
      case ItemTrait.hw20:
        return "Halloween 2020";
      case ItemTrait.hw21:
        return "Halloween 2021";
      case ItemTrait.hw22:
        return "Halloween 2022";
      case ItemTrait.hw23:
        return "Halloween 2023";
      case ItemTrait.hw24:
        return "Halloween 2024";
      case ItemTrait.hw25:
        return "Halloween 2025";
      case ItemTrait.xmas14:
        return "Christmas 2014";
      case ItemTrait.xmas15:
        return "Christmas 2015";
      case ItemTrait.xmas16:
        return "Christmas 2016";
      case ItemTrait.xmas17:
        return "Christmas 2017";
      case ItemTrait.xmas18:
        return "Christmas 2018";
      case ItemTrait.xmas19:
        return "Christmas 2019";
      case ItemTrait.xmas20:
        return "Christmas 2020";
      case ItemTrait.xmas21:
        return "Christmas 2021";
      case ItemTrait.xmas22:
        return "Christmas 2022";
      case ItemTrait.xmas23:
        return "Christmas 2023";
      case ItemTrait.xmas24:
        return "Christmas 2024";
      case ItemTrait.xmas25:
        return "Christmas 2025";
      case ItemTrait.vd17:
        return "Valentine's Day 2017";
      case ItemTrait.vd18:
        return "Valentine's Day 2018";
      case ItemTrait.vd19:
        return "Valentine's Day 2019";
      case ItemTrait.vd20:
        return "Valentine's Day 2020";
      case ItemTrait.vd21:
        return "Valentine's Day 2021";
      case ItemTrait.vd22:
        return "Valentine's Day 2022";
      case ItemTrait.vd23:
        return "Valentine's Day 2023";
      case ItemTrait.vd24:
        return "Valentine's Day 2024";
      case ItemTrait.vd25:
        return "Valentine's Day 2025";
      case ItemTrait.chny18:
        return "Chinese New Year 2018";
      case ItemTrait.chny21:
        return "Chinese New Year 2021";
      case ItemTrait.chny22:
        return "Chinese New Year 2022";
      case ItemTrait.chny24:
        return "Chinese New Year 2024";
      case ItemTrait.ramNavami21:
        return "Ram Navami 2021";
      case ItemTrait.independence21:
        return "Independence Day 2021";
      case ItemTrait.summer21:
        return "Summer 2021";
      case ItemTrait.gift:
        return "Gift";
      case ItemTrait.anniversary10:
        return "10th Anniversary";
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
      case ItemTrait.offer:
        return 0xDC8BE0;
      case ItemTrait.replica:
        return 0x7F8CAA;
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

      case ItemTrait.setDragon:
        return 0xFF3F33;

      case ItemTrait.hw14:
        return 0xFB9E3A;
      case ItemTrait.hw15:
        return 0xFB9E3A;
      case ItemTrait.hw16:
        return 0xFB9E3A;
      case ItemTrait.hw18:
        return 0xFB9E3A;
      case ItemTrait.hw19:
        return 0xFB9E3A;
      case ItemTrait.hw20:
        return 0xFB9E3A;
      case ItemTrait.hw21:
        return 0xFB9E3A;
      case ItemTrait.hw22:
        return 0xFB9E3A;
      case ItemTrait.hw23:
        return 0xFB9E3A;
      case ItemTrait.hw24:
        return 0xFB9E3A;
      case ItemTrait.hw25:
        return 0xFB9E3A;
      case ItemTrait.xmas14:
        return 0xA9D2F3;
      case ItemTrait.xmas15:
        return 0xA9D2F3;
      case ItemTrait.xmas16:
        return 0xA9D2F3;
      case ItemTrait.xmas17:
        return 0xA9D2F3;
      case ItemTrait.xmas18:
        return 0xA9D2F3;
      case ItemTrait.xmas19:
        return 0xA9D2F3;
      case ItemTrait.xmas20:
        return 0xA9D2F3;
      case ItemTrait.xmas21:
        return 0xA9D2F3;
      case ItemTrait.xmas22:
        return 0xA9D2F3;
      case ItemTrait.xmas23:
        return 0xA9D2F3;
      case ItemTrait.xmas24:
        return 0xA9D2F3;
      case ItemTrait.xmas25:
        return 0xA9D2F3;
      case ItemTrait.vd17:
        return 0xF7A5C1;
      case ItemTrait.vd18:
        return 0xF7A5C1;
      case ItemTrait.vd19:
        return 0xF7A5C1;
      case ItemTrait.vd20:
        return 0xF7A5C1;
      case ItemTrait.vd21:
        return 0xF7A5C1;
      case ItemTrait.vd22:
        return 0xF7A5C1;
      case ItemTrait.vd23:
        return 0xF7A5C1;
      case ItemTrait.vd24:
        return 0xF7A5C1;
      case ItemTrait.vd25:
        return 0xF7A5C1;
      case ItemTrait.chny18:
        return 0xE57373;
      case ItemTrait.chny21:
        return 0xE57373;
      case ItemTrait.chny22:
        return 0xE57373;
      case ItemTrait.chny24:
        return 0xE57373;
      case ItemTrait.ramNavami21:
        return 0xFFE082;
      case ItemTrait.independence21:
        return 0xFFE082;
      case ItemTrait.summer21:
        return 0xFFE082;
      case ItemTrait.anniversary10:
        return 0x254D70;
      case ItemTrait.gift:
        return 0x3F7D58;
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
