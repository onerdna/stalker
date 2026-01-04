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
import 'package:url_launcher/url_launcher_string.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  void initState() {
    super.initState();
  }

  Widget _makeHyperlink(String link) {
    return TextButton(
        onPressed: () {
          launchUrlString(link);
        },
        child: Text(link));
  }

  @override
  Widget build(BuildContext context) {
    return Watch(
      (_) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Stalker",
                      style: TextStyle(fontSize: 32),
                    ),
                    const Text("© 2025 Andreno. All rights reserved."),
                    const SizedBox(
                      height: 40,
                    ),
                    const Text(
                        "This app allows you to view and, optionally, edit save files for the game Shadow Fight 2, owned by Nekki Limited. Editing is not recommended and is done at your own risk. As stated in the EULA, I am not responsible for any consequences resulting from such actions.",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const Text("⚠️ Disclaimer",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const Text(
                        "This project is not affiliated with, endorsed by, or in any way officially connected to Nekki, Banzai Games, or the developers of Shadow Fight 2. All trademarks, registered trademarks, product names, and company names or logos mentioned herein are the property of their respective owners.",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const Divider(),
                    const Text("Original author: Andreno",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        const Text("Reddit: ",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: _makeHyperlink(
                              "https://www.reddit.com/user/XAndrenoX/"),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text("GitHub: ",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Expanded(
                            child:
                                _makeHyperlink("https://github.com/onerdna")),
                      ],
                    ),
                    const Divider(),
                    const Text("Contributors",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text("sametaor",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        const Text("GitHub: ",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Flexible(
                            child:
                                _makeHyperlink("https://github.com/sametaor/")),
                      ],
                    ),
                    const Divider(),
                    const Text("Icons used: ",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    ...[
                      (
                        "Sword icons created by Iconic Panda - Flaticon",
                        "https://www.flaticon.com/free-icons/sword"
                      ),
                      (
                        "Home icons created by Vectors Market - Flaticon",
                        "https://www.flaticon.com/free-icons/home"
                      ),
                      (
                        "Document icons created by Roman Káčerek - Flaticon",
                        "https://www.flaticon.com/free-icons/document"
                      ),
                      (
                        "Wrench icons created by juicy_fish - Flaticon",
                        "https://www.flaticon.com/free-icons/wrench"
                      ),
                      (
                        "Katana icons created by Good Ware - Flaticon",
                        "https://www.flaticon.com/free-icons/katana"
                      ),
                      (
                        "Shuriken icons created by Freepik - Flaticon",
                        "https://www.flaticon.com/free-icons/shuriken"
                      ),
                      (
                        "Amulet icons created by Freepik - Flaticon",
                        "https://www.flaticon.com/free-icons/amulet"
                      ),
                      (
                        "Armor icons created by Nikita Golubev - Flaticon",
                        "https://www.flaticon.com/free-icons/armor"
                      ),
                      (
                        "Knight icons created by Freepik - Flaticon",
                        "https://www.flaticon.com/free-icons/knight"
                      ),
                      (
                        "Dojo icons created by juicy_fish - Flaticon",
                        "https://www.flaticon.com/free-icons/dojo"
                      ),
                      (
                        "Forge icons created by Freepik - Flaticon",
                        "https://www.flaticon.com/free-icons/forge"
                      ),
                      (
                        "Virus icons created by Freepik - Flaticon",
                        "https://www.flaticon.com/free-icons/virus"
                      ),
                      (
                        "Treasure icons created by kliwir art - Flaticon",
                        "https://www.flaticon.com/free-icons/treasure"
                      ),
                      (
                        "Weapon icons created by Smashicons - Flaticon",
                        "https://www.flaticon.com/free-icons/weapon"
                      )
                    ].map(
                      (e) => Column(
                        children: [
                          Text(e.$1,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: _makeHyperlink(e.$2),
                          ),
                        ],
                      ),
                    )
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
