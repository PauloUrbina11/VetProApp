import 'package:flutter/material.dart';
import '../../../app/config/theme.dart';

class ServiceCheckboxList extends StatelessWidget {
  final List<dynamic> services;
  final List<int> selectedServices;
  final Function(int, bool) onToggleService;

  const ServiceCheckboxList({
    Key? key,
    required this.services,
    required this.selectedServices,
    required this.onToggleService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: lightGreen.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'No hay servicios disponibles',
          textAlign: TextAlign.center,
          style: TextStyle(color: darkGreen),
        ),
      );
    }

    return Column(
      children: services.map((service) {
        final serviceId = service['id'] as int;
        final isSelected = selectedServices.contains(serviceId);

        return CheckboxListTile(
          title: Text(
            service['nombre'] ?? 'Servicio',
            style: const TextStyle(
              color: darkGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: service['descripcion'] != null
              ? Text(
                  service['descripcion'],
                  style: TextStyle(
                    color: darkGreen.withOpacity(0.7),
                    fontSize: 12,
                  ),
                )
              : null,
          value: isSelected,
          activeColor: softGreen,
          checkColor: white,
          onChanged: (bool? value) {
            onToggleService(serviceId, value ?? false);
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        );
      }).toList(),
    );
  }
}
