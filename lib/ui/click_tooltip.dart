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

class ClickTooltip extends StatefulWidget {
  final String? message;
  final BoxDecoration? decoration;
  final TextStyle? textStyle;
  final Widget child;
  const ClickTooltip(
      {this.message,
      this.decoration,
      this.textStyle,
      required this.child,
      super.key});

  @override
  ClickTooltipState createState() => ClickTooltipState();
}

class ClickTooltipState extends State<ClickTooltip> {
  final GlobalKey _key = GlobalKey();

  void _showTooltip() {
    final dynamic tooltip = _key.currentState;
    tooltip.ensureTooltipVisible();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      key: _key,
      message: widget.message,
      decoration: widget.decoration,
      textStyle: widget.textStyle,
      child: GestureDetector(
        onTap: _showTooltip,
        child: widget.child,
      ),
    );
  }
}
