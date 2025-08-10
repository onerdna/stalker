import 'package:flutter/material.dart';

class SplitFilledButton extends StatelessWidget {
  final VoidCallback onLeftPressed;
  final VoidCallback onRightPressed;
  final Widget leftChild;
  final Widget rightChild;

  const SplitFilledButton({
    super.key,
    required this.onLeftPressed,
    required this.onRightPressed,
    required this.leftChild,
    required this.rightChild,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: onLeftPressed,
            style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16)))),
            child: leftChild,
          ),
        ),
        Container(
          width: 1,
          height: 8,
          color: colorScheme.onPrimary.withValues(alpha: 0.12),
        ),
        Expanded(
          child: FilledButton(
            onPressed: onRightPressed,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16))),
            ),
            child: rightChild,
          ),
        ),
      ],
    );
  }
}
