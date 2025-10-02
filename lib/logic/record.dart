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

import 'package:stalker/logic/enchantment.dart';
import 'package:stalker/logic/equipment_type.dart';
import 'package:stalker/logic/equipment.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

enum Currency { coins, gems, greenOrbs, redOrbs, purpleOrbs }

class RecordMetadata {
  String name;
  String uuid;
  bool isActive;

  RecordMetadata(this.name, this.uuid, this.isActive);
  static RecordMetadata fromMap(Map map) {
    return RecordMetadata(map["name"], map["uuid"], map["is_active"]);
  }

  Map toMap() => {"name": name, "uuid": uuid, "is_active": isActive};
}

class Record {
  XmlDocument tree;
  late XmlElement root;
  final RecordMetadata metadata;
  Map<EquipmentType, List<Equipment>> equipment = {};
  Map<EquipmentType, String> equippedEquipment = {};

  static const String _warriorPath = "/Root/Warriors/Warrior[@FirstName][1]";
  static const String _disciplePath =
      "$_warriorPath/SessionSettings/ShowDojoDisciple/@Value";
  static const String _experiencePath = "$_warriorPath/@Experience";
  static const String _unlimitedEnergyPath =
      "$_warriorPath/Items/Item[@Name=\"Unlimited_Energy\"]";
  static final XmlElement _unlimitedEnergyElement = XmlElement(
    XmlName('Item'),
    [
      XmlAttribute(XmlName('Name'), 'Unlimited_Energy'),
      XmlAttribute(XmlName('Equipped'), '0'),
      XmlAttribute(XmlName('Count'), '1'),
      XmlAttribute(XmlName('UpgradeLevel'), '0'),
      XmlAttribute(XmlName('DeliveryTime'), '0'),
      XmlAttribute(XmlName('AcquireType'), 'Item'),
      XmlAttribute(XmlName('DeliveryUpgradeLevel'), '-1'),
    ],
  );

  Record(this.tree, this.metadata) {
    root = tree.findAllElements("Root").first;

    if (tree
        .xpath(
            "//Currencies[@ForgeMaterial1 and @ForgeMaterial2 and @ForgeMaterial3]")
        .isEmpty) {
      tree.xpath("//Currencies").first.attributes.addAll([
        XmlAttribute(XmlName("ForgeMaterial1"), "0"),
        XmlAttribute(XmlName("ForgeMaterial2"), "0"),
        XmlAttribute(XmlName("ForgeMaterial3"), "0")
      ]);
    }
    equipment = {for (var e in EquipmentType.values) e: _parseEquipment(e)};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Record &&
          runtimeType == other.runtimeType &&
          metadata.uuid == other.metadata.uuid;

  @override
  int get hashCode => metadata.uuid.hashCode;

  String? _getAttribute(String xpath) {
    return tree.xpath(xpath).whereType<XmlAttribute>().firstOrNull?.value;
  }

  void setAttribute(String xpath, String value) {
    tree.xpath(xpath).whereType<XmlAttribute>().first.value = value;
  }

  XmlElement _getWarrior() {
    return tree
        .findAllElements("Warrior")
        .firstWhere((e) => e.getAttribute("FirstName") != null);
  }

  int getCurrency(Currency currency) {
    return int.parse(_getAttribute(_getCurrencyPath(currency)) ?? "0");
  }

  String _getCurrencyPath(Currency currency) {
    switch (currency) {
      case Currency.coins:
        return "$_warriorPath/@Money";
      case Currency.gems:
        return "$_warriorPath/@Bonus";
      case Currency.greenOrbs:
        return "$_warriorPath/Currencies/@ForgeMaterial1";
      case Currency.redOrbs:
        return "$_warriorPath/Currencies/@ForgeMaterial2";
      case Currency.purpleOrbs:
        return "$_warriorPath/Currencies/@ForgeMaterial3";
    }
  }

  void setCurrency(Currency currency, int amount) {
    setAttribute(_getCurrencyPath(currency), amount.toString());
  }

  int get level {
    return int.parse(_getWarrior().getAttribute("Level") ?? "0");
  }

  set level(int level) {
    _getWarrior().setAttribute("Level", level.toString());
  }

  bool get isDiscipleEnabled {
    return _getAttribute(_disciplePath) == "1";
  }

  set isDiscipleEnabled(bool value) {
    setAttribute(_disciplePath, value ? "1" : "0");
  }

  int get experience {
    return int.tryParse(_getAttribute(_experiencePath) ?? "0") ?? 0;
  }

  set experience(int value) {
    setAttribute(_experiencePath, value.toString());
  }

  bool get isEnergyUnlimited {
    return tree.xpath(_unlimitedEnergyPath).isNotEmpty;
  }

  set isEnergyUnlimited(bool value) {
    final element = tree.xpath(_unlimitedEnergyPath);
    switch (value) {
      case true:
        if (!isEnergyUnlimited) {
          tree
              .xpath("$_warriorPath/Items")
              .whereType<XmlElement>()
              .first
              .children
              .add(_unlimitedEnergyElement);
        }
      case false:
        if (isEnergyUnlimited) {
          element.first.parent?.children.remove(element.first);
        }
    }
  }

  bool get showForge {
    return (_getAttribute("$_warriorPath/@ShowForge") ?? "0") == "1";
  }

  set showForge(bool value) {
    _getWarrior().setAttribute("ShowForge", value ? "1" : "0");
  }

  XmlElement get items {
    return (tree
            .xpath("$_warriorPath/Items")
            .whereType<XmlElement>()
            .firstOrNull ??
        XmlElement(XmlName("Items")));
  }

  List<Equipment> _parseEquipment(EquipmentType type) {
    final selectedId = _getWarrior().getAttribute(type.slot)!;

    return items.children
        .where((e) =>
            EquipmentTypeExtension.fromId(e.getAttribute("Name") ?? "") ==
                type &&
            e.getAttribute("UpgradeLevel") != null)
        .map((element) {
      final enchantments = element
          .findAllElements("Enchantments")
          .expand((n) => n.findElements("Perk"))
          .where((ench) =>
              EnchantmentsManager.findByEquipmentTypeId(
                  type, ench.getAttribute("Name") ?? "") !=
              null)
          .map((ench) {
        final enchantment = EnchantmentsManager.findByEquipmentTypeId(
            type, ench.getAttribute("Name")!)!;
        final aspect = enchantment.group.hasAspect
            ? int.tryParse(
                    (ench.getElement("Set") ?? XmlElement(XmlName("Set")))
                            .getAttribute("Aspect") ??
                        "0") ??
                0
            : null;
        return AppliedEnchantment(
            enchantment, aspect?.clamp(0, AppliedEnchantment.maxAspect));
      }).toList();
      final upgradeLevel = element.getAttribute("UpgradeLevel")!;
      final id = element.getAttribute("Name")!;
      final acquireType = element.getAttribute("AcquireType")!;
      UpgradeDelivery? upgradeDelivery = int.parse(
                      element.getAttribute("DeliveryTime") ?? "0") >
                  0 &&
              int.parse(element.getAttribute("DeliveryUpgradeLevel") ?? "0") > 0
          ? UpgradeDelivery.fromXml(
              element.getAttribute("DeliveryUpgradeLevel")!,
              element.getAttribute("DeliveryTime") ?? "0")
          : null;
      XmlElement? recipeDeliveryElement = element.getElement("RecipeDelivery");
      RecipeDelivery? recipeDelivery = recipeDeliveryElement == null
          ? null
          : RecipeDelivery.fromXml(
              recipeDeliveryElement.getAttribute("Name")!,
              recipeDeliveryElement.getAttribute("DeliveryTime")!,
              recipeDeliveryElement.getAttribute("ItemLevel")!,
              recipeDeliveryElement.getAttribute("PlayerLevel")!);
      final item = Equipment.fromUpgradeString(
          type, id, upgradeLevel == "0" ? "100" : upgradeLevel,
          acquireType: acquireType,
          upgradeDelivery: upgradeDelivery,
          recipeDelivery: recipeDelivery);
      item.enchantments = enchantments;
      if (id == selectedId) {
        setEquipped(item);
      }
      return item;
    }).toList();
  }

  Future<void> _saveEquipment() async {
    for (var k in EquipmentType.values) {
      items.children.removeWhere((e) =>
          EquipmentTypeExtension.fromId(e.getAttribute("Name") ?? "") == k &&
          e.getAttribute("UpgradeLevel") != null);
    }
    for (var v in equipment.values) {
      for (var item in v) {
        items.children.add(item.toXml(this));
      }
    }
  }

  Equipment? getEquipped(EquipmentType type) => equipment[type]
      ?.where((e) => e.id == equippedEquipment[type])
      .firstOrNull;
  void setEquipped(Equipment equipment) {
    _getWarrior().setAttribute(equipment.type.slot, equipment.id);
    equippedEquipment[equipment.type] = equipment.id;
  }

  bool isEquipped(Equipment equipment) =>
      equippedEquipment[equipment.type] == equipment.id;

  String get gameVersion =>
      _getAttribute("/Root/Versions/Version/@Value") ?? "1.0.0";
  String get dataVersion =>
      _getAttribute("/Root/Versions/DataVersion/@Value") ?? "1.0.0";
  int get launchIndex =>
      int.parse(_getAttribute("/Root/GameLaunchIndex/@Value") ?? "0");

  String get xml {
    _saveEquipment();
    return tree.toXmlString(pretty: true).replaceAllMapped(
          RegExp(r'(<[^>]+)(/>)'),
          (match) => match.group(1)!.endsWith(' ')
              ? match.group(0)!
              : '${match.group(1)} />',
        );
  }
}
