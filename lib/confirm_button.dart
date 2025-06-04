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
