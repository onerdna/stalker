import "package:flutter/material.dart";
import 'package:stalker/equipment_type.dart';

class NewItem extends StatefulWidget {
  final EquipmentType equipmentType;
  final void Function(String) onPressed;

  const NewItem(
      {required this.onPressed, required this.equipmentType, super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add by ID"),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: "Type ID here..."),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel")),
        TextButton(
          onPressed: () {
            widget.onPressed(controller.text);
            Navigator.of(context).pop();
          },
          child: const Text("Add to the inventory"),
        )
      ],
    );
  }
}
