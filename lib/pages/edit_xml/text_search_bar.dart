import 'package:flutter/material.dart';

class TextSearchBar extends StatefulWidget {
  final void Function(String) onSubmitted;

  const TextSearchBar({super.key, required this.onSubmitted});

  @override
  State<TextSearchBar> createState() => _TextSearchBarState();
}

class _TextSearchBarState extends State<TextSearchBar> {
  final controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
        hintText: "Search...",
        onSubmitted: widget.onSubmitted,
        controller: controller);
  }
}
