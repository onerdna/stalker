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


import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stalker/record.dart';
import 'package:stalker/records_manager.dart';

class GeneralPage extends StatefulWidget {
  const GeneralPage({super.key});

  @override
  State<GeneralPage> createState() => _GeneralPageState();
}

class Field {
  final String iconPath;
  final String name;
  final TextEditingController controller;
  final void Function(String) callback;

  Field(this.iconPath, this.name, this.controller, this.callback);
}

class _GeneralPageState extends State<GeneralPage> {
  late final List<Field> currencies;
  late final List<Field> progression;
  late final List<List<Field>> sections;

  @override
  void initState() {
    super.initState();
    currencies = [
      Field(
          "assets/images/coin.png",
          "Coins",
          TextEditingController(
              text: RecordsManager.activeRecord!
                  .getCurrency(Currency.coins)
                  .toString()), (value) {
        RecordsManager.activeRecord!
            .setCurrency(Currency.coins, int.tryParse(value) ?? 0);
      }),
      Field(
          "assets/images/ruby.png",
          "Gems",
          TextEditingController(
              text: RecordsManager.activeRecord!
                  .getCurrency(Currency.gems)
                  .toString()), (value) {
        RecordsManager.activeRecord!
            .setCurrency(Currency.gems, int.tryParse(value) ?? 0);
      }),
      Field(
          "assets/images/forge_green.png",
          "Green orbs",
          TextEditingController(
              text: RecordsManager.activeRecord!
                  .getCurrency(Currency.greenOrbs)
                  .toString()), (value) {
        RecordsManager.activeRecord!
            .setCurrency(Currency.greenOrbs, int.tryParse(value) ?? 0);
      }),
      Field(
          "assets/images/forge_red.png",
          "Red orbs",
          TextEditingController(
              text: RecordsManager.activeRecord!
                  .getCurrency(Currency.redOrbs)
                  .toString()), (value) {
        RecordsManager.activeRecord!
            .setCurrency(Currency.redOrbs, int.tryParse(value) ?? 0);
      }),
      Field(
          "assets/images/forge_purple.png",
          "Purple orbs",
          TextEditingController(
              text: RecordsManager.activeRecord!
                  .getCurrency(Currency.purpleOrbs)
                  .toString()), (value) {
        RecordsManager.activeRecord!
            .setCurrency(Currency.purpleOrbs, int.tryParse(value) ?? 0);
      }),
    ];

    progression = [
      Field(
          "assets/images/shuriken.png",
          "Level",
          TextEditingController(
              text: RecordsManager.activeRecord!.level.toString()), (value) {
        RecordsManager.activeRecord!.level = int.tryParse(value) ?? 1;
      }),
      Field(
          "assets/images/shuriken.png",
          "Experience",
          TextEditingController(
              text: RecordsManager.activeRecord!.experience.toString()),
          (value) {
        RecordsManager.activeRecord!.experience = int.tryParse(value) ?? 0;
      })
    ];

    sections = [currencies, progression];
  }

  Row _generateCheckbox(String name, String imagePath, bool value,
      void Function(bool?) onChanged) {
    return Row(
      children: [
        Image.asset(imagePath, width: 40, height: 40),
        const SizedBox(width: 20),
        Text(name),
        Checkbox(value: value, onChanged: onChanged)
      ],
    );
  }

  ExpansionTile _generateSection(
      String title, String description, List<Field> fields) {
    return ExpansionTile(
        title: Text(title),
        subtitle: Text(description),
        childrenPadding: const EdgeInsets.only(left: 32),
        children: fields.map((field) {
          return Row(
            children: [
              Image.asset(field.iconPath, width: 24, height: 24),
              const SizedBox(width: 5),
              Text(field.name),
              const SizedBox(width: 10),
              SizedBox(
                height: 50,
                width: 150,
                child: TextField(
                  controller: field.controller,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(top: 16, bottom: 0),
                    border: UnderlineInputBorder(),
                    isDense: true,
                  ),
                ),
              )
            ],
          );
        }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(children: [
              _generateSection(
                  "Currencies", "Coins, Gems and Forge Materials", currencies),
              _generateSection(
                  "Progression", "Levels and experience", progression),
              const SizedBox(height: 20),
              _generateCheckbox("Dojo Disciple", "assets/images/dojo.png",
                  RecordsManager.activeRecord!.isDiscipleEnabled, (value) {
                setState(() {
                  RecordsManager.activeRecord!.isDiscipleEnabled =
                      value ?? false;
                });
              }),
              const SizedBox(height: 6),
              _generateCheckbox(
                  "Unlimited Energy",
                  "assets/images/lighting.png",
                  RecordsManager.activeRecord!.isEnergyUnlimited, (value) {
                setState(() {
                  RecordsManager.activeRecord!.isEnergyUnlimited =
                      value ?? false;
                });
              }),
              const SizedBox(height: 6),
              _generateCheckbox("Show Forge", "assets/images/anvil.png",
                  RecordsManager.activeRecord!.showForge, (value) {
                setState(() {
                  RecordsManager.activeRecord!.showForge = value ?? false;
                });
              })
            ]),
          ),
        ),
      ),
      floatingActionButton:
          FloatingActionButton(onPressed: save, child: const Icon(Icons.save)),
    );
  }

  void save() {
    for (var section in sections) {
      for (var field in section) {
        field.callback(field.controller.text);
      }
    }

    RecordsManager.saveRecord(RecordsManager.activeRecord!).then((_) {
      Fluttertoast.showToast(msg: "Saved successfully");
    });
  }
}
