import 'package:flutter/material.dart';

class MyPetsScreen extends StatelessWidget {
  const MyPetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis mascotas')),
      body: const Center(child: Text('Lista de mascotas (placeholder)')),
    );
  }
}
