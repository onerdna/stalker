import 'package:flutter/material.dart';

class TextSearchBar extends StatefulWidget {
  final void Function(String) onSubmitted;
  final VoidCallback onCleared;

  const TextSearchBar(
      {super.key, required this.onSubmitted, required this.onCleared});

  @override
  State<TextSearchBar> createState() => _TextSearchBarState();
}

class _TextSearchBarState extends State<TextSearchBar> {
  final controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchBar(
        hintText: "Search...",
        onSubmitted: widget.onSubmitted,
        controller: controller,
        focusNode: focusNode,
        trailing: [
          IconButton(
              onPressed: () {
                controller.clear();
                focusNode.unfocus();
                widget.onCleared();
              },
              icon: const Icon(Icons.clear))
        ]);
  }
}
