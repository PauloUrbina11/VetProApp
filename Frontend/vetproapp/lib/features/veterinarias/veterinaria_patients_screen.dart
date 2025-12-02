import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../app/config/theme.dart';
import '../../app/services/permissions_service.dart';
import '../../app/services/auth_service.dart';
import '../../app/services/veterinaria_service.dart';
import 'patient_detail_screen.dart';

class VeterinariaPatients extends StatefulWidget {
  const VeterinariaPatients({super.key});

  @override
  State<VeterinariaPatients> createState() => _VeterinariaPatientsState();
}

class _VeterinariaPatientsState extends State<VeterinariaPatients> {
  bool _loading = true;
  List<dynamic> _patients = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final role = await AuthService.getRole();
    if (role == 2) {
      await PermissionsService.loadVeterinariaRoles();
    }
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _loading = true);

    try {
      final veterinariaIds = await VeterinariaService.getMyVeterinarias();
      if (veterinariaIds.isEmpty) {
        throw Exception('No se pudo obtener el ID de la veterinaria');
      }

      final veterinariaId = veterinariaIds[0];
      final token = await AuthService.getToken();
      final url = Uri.parse(
          'http://10.0.2.2:4000/api/veterinarias/$veterinariaId/patients');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _patients = List<Map<String, dynamic>>.from(data['data'] ?? []);
        });
      } else {
        throw Exception('Error al cargar pacientes');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
        title: const Text(
          'Pacientes',
          style: TextStyle(
            color: darkGreen,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: mint,
        foregroundColor: darkGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkGreen),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: softGreen))
          : _patients.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pets_outlined,
                          size: 64, color: darkGreen.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay pacientes registrados',
                        style: TextStyle(
                          color: darkGreen,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _patients.length,
                  itemBuilder: (context, index) {
                    final patient = _patients[index];
                    return _buildPatientCard(patient);
                  },
                ),
    );
  }

  Widget _buildPatientCard(dynamic patient) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: lightGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.pets, color: softGreen),
        ),
        title: Text(
          patient['nombre'] ?? 'Sin nombre',
          style: const TextStyle(
            color: darkGreen,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${patient['especie']} - ${patient['raza']}',
              style: TextStyle(
                color: softGreen,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Propietario: ${patient['propietario_nombre'] ?? 'N/A'}',
              style: TextStyle(
                color: darkGreen.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: darkGreen),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDetailScreen(
                patient: patient,
              ),
            ),
          );
        },
      ),
    );
  }
}
