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

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:stalker/app.dart';
import 'package:stalker/item_database.dart';
import 'package:stalker/logcat.dart';
import 'package:toml/toml.dart';

class AlwaysLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => true;
}

final logger = Logger(printer: SimplePrinter(colors: false), filter: AlwaysLogFilter());

void main() {
  runApp(const RootApp());
}

class RootApp extends StatefulWidget {
  const RootApp({super.key});

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  @override
  void initState() {
    super.initState();
    Logcat.init();
    logger.i("Initialized logcat stream");
    rootBundle.loadString("assets/item_database.toml").then((names) {
      ItemDatabase.dictionary = TomlDocument.parse(names).toMap();
    });
    ItemDatabase.loadTraits().then((traits) {
      ItemDatabase.traits = traits.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      ColorScheme lightColorScheme = lightDynamic ??
          ColorScheme.fromSeed(
            seedColor: Colors.blue,
          );
      ColorScheme darkColorScheme = darkDynamic ??
          ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          );
      return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme:
              ThemeData.from(useMaterial3: true, colorScheme: lightColorScheme),
          darkTheme:
              ThemeData.from(useMaterial3: true, colorScheme: darkColorScheme),
          themeMode: ThemeMode.system,
          title: "Stalker",
          home: const App());
    });
  }
}
