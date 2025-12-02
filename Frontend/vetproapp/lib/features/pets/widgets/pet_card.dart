import 'package:flutter/material.dart';
import '../../../app/config/theme.dart';

class PetCard extends StatelessWidget {
  final dynamic pet;
  final VoidCallback onTap;
  final bool isAdmin;

  const PetCard({
    Key? key,
    required this.pet,
    required this.onTap,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: lightGreen.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: softGreen,
          child: pet['foto_principal'] != null
              ? ClipOval(
                  child: Image.network(
                    pet['foto_principal'],
                    fit: BoxFit.cover,
                    width: 60,
                    height: 60,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.pets, color: white, size: 30),
                  ),
                )
              : const Icon(Icons.pets, color: white, size: 30),
        ),
        title: Text(
          pet['nombre'] ?? 'Sin nombre',
          style: const TextStyle(
            color: darkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAdmin && pet['owner_name'] != null) ...[
              const SizedBox(height: 4),
              Text(
                'Dueño: ${pet['owner_name']}',
                style: TextStyle(
                  color: darkGreen.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              '${pet['especie_nombre'] ?? 'Especie desconocida'} - ${pet['raza_nombre'] ?? 'Raza desconocida'}',
              style: TextStyle(
                color: darkGreen.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: darkGreen),
        onTap: onTap,
      ),
    );
  }
}
