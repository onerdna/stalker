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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals.dart';

Signal<ThemeMode> brightness = signal(ThemeMode.system);
Signal<Color> primaryColor = signal(Colors.lightBlue);
Signal<bool> useSystemColors = signal(true);
Signal<bool> supportsDynamicColors = signal(false);

const colors = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.yellow,
  Colors.purple,
  Colors.cyan,
  Colors.redAccent,
  Colors.lightGreen,
  Colors.lightBlue,
  Colors.amber,
  Colors.deepPurple,
  Colors.teal,
  Color(0xffb33791),
  Color(0xff328e6e),
  Color(0xff00809d),
  Color(0xfffbdb93),
  Color(0xff511d43),
  Color(0xff222831)
];

Future<void> loadThemeFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  int colorValue = prefs.getInt('primaryColor') ?? Colors.blue.toARGB32();
  brightness.value = ThemeMode.values
          .where((e) => prefs.getString("brightness") == e.toString())
          .firstOrNull ??
      ThemeMode.system;
  primaryColor.value = Color(colorValue);
  useSystemColors.value = prefs.getBool("useSystemColors") ?? true;
}

void setPrimaryColor(Color color) async {
  primaryColor.value = color;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('primaryColor', primaryColor.value.toARGB32());
}

void setBrightness(ThemeMode value) async {
  brightness.value = value;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('brightness', brightness.value.toString());
}

void setUseSystemColors(bool value) async {
  useSystemColors.value = value;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('useSystemColors', useSystemColors.value);
}
