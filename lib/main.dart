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
import 'package:signals/signals_flutter.dart';
import 'package:stalker/app.dart';
import 'package:stalker/logic/item_database.dart';
import 'package:stalker/logcat.dart';
import 'package:stalker/themes.dart';
import 'package:toml/toml.dart';

class AlwaysLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => true;
}

final logger =
    Logger(printer: SimplePrinter(colors: false), filter: AlwaysLogFilter());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadThemeFromPrefs();
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
      logger.i("Loaded item databse");
    });
    ItemDatabase.loadTraits().then((traits) {
      ItemDatabase.traits = traits.toList();
      logger.i("Loaded item traits");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) {
        final brightness_ = brightness.value;
        final useSystemColors_ = useSystemColors.value;
        final primaryColor_ = primaryColor.value;
        return DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          ColorScheme lightColorScheme;
          ColorScheme darkColorScheme;

          if (lightDynamic != null && darkDynamic != null && useSystemColors_) {
            lightColorScheme = ColorScheme.fromSeed(
              seedColor: lightDynamic.primary,
              brightness: Brightness.light
            );
            darkColorScheme = ColorScheme.fromSeed(
              seedColor: darkDynamic.primary,
              brightness: Brightness.dark
            );
          } else {
            lightColorScheme = ColorScheme.fromSeed(seedColor: primaryColor_);
            darkColorScheme = ColorScheme.fromSeed(
                seedColor: primaryColor_, brightness: Brightness.dark);
          }

          supportsDynamicColors.value = lightDynamic != null && darkDynamic != null;

          final lightTheme = ThemeData(
              colorScheme: lightColorScheme,
              useMaterial3: true,
              scaffoldBackgroundColor: lightColorScheme.surfaceContainer);

          final darkTheme = ThemeData(
              colorScheme: darkColorScheme,
              useMaterial3: true,
              scaffoldBackgroundColor: darkColorScheme.surfaceContainer);
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: brightness_,
              title: "Stalker",
              home: const App());
        });
      },
    );
  }
}
