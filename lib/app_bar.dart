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
import 'package:stalker/app.dart';
import 'package:stalker/pages/about_page.dart';

class StalkerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StalkerAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 90,
      title: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: package.value?.version == null
                      ? null
                      : Text(
                          "v${package.value?.version}",
                          style: const TextStyle(fontSize: 16),
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
          const Center(
            child: Text(
              "© 2025 Andreno. All rights reserved.",
              style: TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
