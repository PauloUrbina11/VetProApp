import 'package:flutter/material.dart';
import '../../../app/config/theme.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      body: const Center(child: Text('Pantalla de agenda')));
  }
}
