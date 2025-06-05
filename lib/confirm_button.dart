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

import 'dart:async';
import 'package:flutter/material.dart';

class ConfirmButton extends StatefulWidget {
  final VoidCallback onConfirmed;
  final Widget child;

  const ConfirmButton({
    super.key,
    required this.onConfirmed,
    required this.child,
  });

  @override
  State<ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<ConfirmButton> {
  bool _confirming = false;
  Timer? _resetTimer;

  void _onPressed() {
    if (_confirming) {
      widget.onConfirmed();
      _resetConfirming();
    } else {
      setState(() {
        _confirming = true;
      });
      _resetTimer?.cancel();
      _resetTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _confirming = false;
          });
        }
      });
    }
  }

  void _resetConfirming() {
    _resetTimer?.cancel();
    setState(() {
      _confirming = false;
    });
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _confirming ? Colors.red : null,
      ),
      onPressed: _onPressed,
      child: _confirming ? const Text('Are you sure?') : widget.child,
    );
  }
}
