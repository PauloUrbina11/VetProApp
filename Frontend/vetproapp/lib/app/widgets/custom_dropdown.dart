import 'package:flutter/material.dart';
import '../config/theme.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;

  const CustomDropdown({
    Key? key,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: softGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          iconEnabledColor: Colors.white,
          dropdownColor: softGreen,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
