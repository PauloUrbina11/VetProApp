import 'package:flutter/material.dart';
import '../../../app/config/theme.dart';

class TimeSlotGrid extends StatelessWidget {
  final List<dynamic> availableSlots;
  final String? selectedTime;
  final Function(String) onSelectTime;

  const TimeSlotGrid({
    Key? key,
    required this.availableSlots,
    required this.selectedTime,
    required this.onSelectTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (availableSlots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: lightGreen.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No hay horarios disponibles para esta fecha',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkGreen,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableSlots.map((slot) {
        final hora = slot['hora'] as String;
        final isSelected = selectedTime == hora;

        return GestureDetector(
          onTap: () => onSelectTime(hora),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? softGreen : white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? softGreen : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Text(
              hora.substring(0, 5),
              style: TextStyle(
                color: isSelected ? white : darkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
