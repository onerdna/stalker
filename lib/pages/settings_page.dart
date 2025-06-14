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
import 'package:signals/signals_flutter.dart';
import 'package:stalker/app.dart';
import 'package:stalker/pages/about_page.dart';
import 'package:stalker/records_manager.dart';
import 'package:stalker/themes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext _) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surfaceContainer,
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: Watch((context) => Padding(
            padding:
                const EdgeInsets.only(top: 16, bottom: 32, left: 16, right: 16),
            child: Column(
              spacing: 16,
              children: [
                ListTile(
                  title: Text("Theme", style: theme.textTheme.titleLarge),
                  subtitle: const Text("Select desired application theme"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    Text("Theme: ", style: theme.textTheme.bodyLarge,),
                    DropdownButton<ThemeMode>(
                      value: brightness.value,
                      onChanged: (ThemeMode? value) =>
                          setState(() {
                            setBrightness(value!);
                          }),
                      items: ThemeMode.values
                          .map<DropdownMenuItem<ThemeMode>>((ThemeMode value) {
                        return DropdownMenuItem<ThemeMode>(
                          value: value,
                          child: Text(
                              "${value.name[0].toUpperCase()}${value.name.substring(1)}"),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                if (supportsDynamicColors.value)
                  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    Text("Use system color scheme", style: theme.textTheme.bodyLarge),
                    Switch(value: useSystemColors.value, onChanged: (value) => setUseSystemColors(value)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: colors
                        .map((color) => GestureDetector(
                              onTap: () => setState(() {
                                setPrimaryColor(color);
                              }),
                              child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: color == primaryColor.value
                                        ? Border.all(
                                            width: 3,
                                            color: theme.colorScheme.primary)
                                        : Border.all(
                                            width: 1.5,
                                            color: theme.colorScheme.outline),
                                  )),
                            ))
                        .toList(),
                  ),
                ),
                const Divider(),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AboutPage()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "About",
                        style: theme.textTheme.titleLarge,
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        size: 32,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Center(
                    child: Text(
                  "${package.value!.packageName} ${package.value!.version}",
                  style: theme.textTheme.labelSmall,
                )),
                Center(
                    child: Text(
                  "userid: ${RecordsManager.userid}",
                  style: theme.textTheme.labelSmall,
                )),
              ],
            ),
          )),
    );
  }
}
