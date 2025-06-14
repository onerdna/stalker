// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stalker/record.dart';
import 'package:stalker/records_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class NewRecord extends StatefulWidget {
  final VoidCallback onCreated;

  const NewRecord({required this.onCreated, super.key});

  @override
  State<NewRecord> createState() => _NewRecordState();
}

class _NewRecordState extends State<NewRecord> {
  final controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create a new save record"),
      content: SizedBox(
        width: 400,
        height: 80,
        child: Column(
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              decoration:
                  const InputDecoration(hintText: "Enter the name here..."),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel")),
        TextButton(
            onPressed: () async {
              final asset =
                  await rootBundle.loadString("assets/xml/defaultRecord.xml");
              final record = Record(XmlDocument.parse(asset),
                  RecordMetadata(controller.text, const Uuid().v8(), false));

              setState(() {
                RecordsManager.records.add(record);
                RecordsManager.saveRecord(record);
                Fluttertoast.showToast(msg: "Created a new save record");
              });
              Navigator.of(context).pop();
              widget.onCreated();
            },
            child: const Text("Continue"))
      ],
    );
  }
}
