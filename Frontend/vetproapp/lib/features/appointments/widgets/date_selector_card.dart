import 'package:flutter/material.dart';
import '../../../app/config/theme.dart';

class DateSelectorCard extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onSelectDate;

  const DateSelectorCard({
    Key? key,
    required this.selectedDate,
    required this.onSelectDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: softGreen, width: 2),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: vetproGreen, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fecha seleccionada',
                    style: TextStyle(
                      fontSize: 12,
                      color: darkGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit, color: vetproGreen, size: 20),
          ],
        ),
      ),
    );
  }
}
