import 'package:flutter/material.dart';

// Reusable task tile widget
class ToDoTile extends StatelessWidget {
  final String taskName;
  final bool taskComplete;
  Function(bool?)? onChanged;
  Function() onPressedEdit;
  Function() onPressedDelete;

  ToDoTile({
    super.key,
    required this.taskName,
    required this.taskComplete,
    required this.onChanged,
    required this.onPressedEdit,
    required this.onPressedDelete
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top:12),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xFFE8C78E),
            borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Adding a checkbox
            Checkbox(
              value: taskComplete,
              onChanged: onChanged,
              activeColor: const Color(0xFFBAA889),
            ),

            // Task name
            Text(
              taskName,
              style: TextStyle(
                decoration: taskComplete
                  ? TextDecoration.lineThrough
                  : TextDecoration.none)
            ),
            const Spacer(),
            // Edit button
            IconButton(
              onPressed: onPressedEdit,
              icon: const Icon(Icons.edit)
            ),
            IconButton(
              onPressed: onPressedDelete,
              icon: const Icon(Icons.delete)
            ),
          ],
        ),
      ),
    );
  }
}