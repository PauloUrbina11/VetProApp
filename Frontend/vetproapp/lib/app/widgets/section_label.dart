import 'package:flutter/material.dart';
import '../config/theme.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  final Color? color;
  final double fontSize;

  const SectionLabel({
    Key? key,
    required this.text,
    this.color,
    this.fontSize = 14,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: color ?? darkGreen,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
