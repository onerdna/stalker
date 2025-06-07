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
      showDuration: const Duration(seconds: 2),
      child: GestureDetector(
        onTap: _showTooltip,
        child: widget.child,
      ),
    );
  }
}
