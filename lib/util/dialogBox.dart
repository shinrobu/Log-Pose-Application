import 'package:flutter/material.dart';
import 'package:log_pose/util/buttons.dart';

// Reusable dialog box widget to handle alerts with text
class DialogBox extends StatelessWidget {
  final controller;
  VoidCallback onSave;
  VoidCallback onCancel;
  String? textOfHint;

  DialogBox({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
    required this.textOfHint
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.orangeAccent,
      content: Container(
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
          // User input
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: textOfHint,
            ),
          ),

          // Save & cancel buttons
          Row(
            children: [
              // Save button
              ActivityButtons(text: "Save", onPressed: onSave),

              const SizedBox(width: 8),

              // Cancel button
              ActivityButtons(text: "Cancel", onPressed: onCancel),
            ]
          )
        ])
      ),
    );
  }
}