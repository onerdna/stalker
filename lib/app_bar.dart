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
import 'package:stalker/pages/logcat_stream_page.dart';
import 'package:stalker/pages/about_page.dart';

class StalkerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StalkerAppBar({super.key});

  @override
  Widget build(BuildContext _) {
    return Watch((context) => AppBar(
          toolbarHeight: 200,
          title: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.bug_report),
                            onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const LogcatStreamPage())),
                          )),
                      if (package.value?.version != null)
                        Text(
                          "v${package.value?.version}",
                          style: const TextStyle(fontSize: 16),
                        ),
                    ],
                  )),
              const Center(child: Text("Stalker")),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AboutPage())),
                  icon: const Icon(Icons.info_outline),
                ),
              ),
            ],
          ),
        ));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
