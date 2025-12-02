import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../app/config/theme.dart';
import '../../app/services/auth_service.dart';
import '../../app/services/permissions_service.dart';
import '../../app/services/veterinaria_service.dart';
import '../medical_records/medical_records_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const PatientDetailScreen({
    Key? key,
    required this.patient,
  }) : super(key: key);

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _appointments = [];
  bool _canView = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final role = await AuthService.getRole();
    if (role == 2) {
      await PermissionsService.loadVeterinariaRoles();
      setState(() {
        _canView = PermissionsService.canViewMedicalHistory();
      });
    }

    if (_canView) {
      await _loadAppointmentHistory();
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadAppointmentHistory() async {
    setState(() => _loading = true);

    try {
      final veterinariaIds = await VeterinariaService.getMyVeterinarias();
      if (veterinariaIds.isEmpty) {
        throw Exception('No se pudo obtener el ID de la veterinaria');
      }

      final veterinariaId = veterinariaIds[0];
      final token = await AuthService.getToken();
      final url = Uri.parse(
          'http://10.0.2.2:4000/api/veterinarias/$veterinariaId/patients/${widget.patient['id']}/history');

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
          _appointments = List<Map<String, dynamic>>.from(data['data'] ?? []);
        });
      } else {
        throw Exception('Error al cargar historial');
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
        title: Text(
          widget.patient['nombre'] ?? 'Paciente',
          style: const TextStyle(
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
          : !_canView
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline,
                          size: 64, color: darkGreen.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        'No tienes permisos para ver el historial médico',
                        style: TextStyle(
                          color: darkGreen,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAppointmentHistory,
                  color: softGreen,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPetInfoCard(),
                        const SizedBox(height: 16),
                        _buildMedicalHistoryButton(context),
                        const SizedBox(height: 16),
                        const Text(
                          'Historial de Citas',
                          style: TextStyle(
                            color: darkGreen,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_appointments.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(Icons.calendar_today_outlined,
                                      size: 64,
                                      color: darkGreen.withOpacity(0.3)),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No hay citas registradas',
                                    style: TextStyle(
                                      color: darkGreen,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ..._appointments
                              .map((appointment) =>
                                  _buildAppointmentCard(appointment))
                              .toList(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildPetInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del Paciente',
            style: TextStyle(
              color: darkGreen,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Especie', widget.patient['especie'] ?? 'N/A'),
          _buildInfoRow('Raza', widget.patient['raza'] ?? 'N/A'),
          _buildInfoRow(
              'Edad',
              _formatAge(
                widget.patient['edad_anos'],
                widget.patient['edad_meses'],
                widget.patient['edad_dias'],
              )),
          _buildInfoRow('Sexo', widget.patient['sexo'] ?? 'N/A'),
          if (widget.patient['propietario_nombre'] != null)
            _buildInfoRow(
                'Propietario', widget.patient['propietario_nombre'] ?? 'N/A'),
        ],
      ),
    );
  }

  String _formatAge(dynamic anos, dynamic meses, dynamic dias) {
    try {
      // Convertir a int manejando null
      int anosInt = 0;
      int mesesInt = 0;
      int diasInt = 0;

      if (anos != null) {
        anosInt = anos is int ? anos : (int.tryParse(anos.toString()) ?? 0);
      }
      if (meses != null) {
        mesesInt = meses is int ? meses : (int.tryParse(meses.toString()) ?? 0);
      }
      if (dias != null) {
        diasInt = dias is int ? dias : (int.tryParse(dias.toString()) ?? 0);
      }

      if (anosInt > 0) {
        return anosInt == 1 ? '1 año' : '$anosInt años';
      } else if (mesesInt > 0) {
        return mesesInt == 1 ? '1 mes' : '$mesesInt meses';
      } else if (diasInt > 0) {
        return diasInt == 1 ? '1 día' : '$diasInt días';
      } else {
        return 'Recién nacido';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: darkGreen.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: darkGreen,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final dateTime = DateTime.parse(appointment['fecha_hora']).toLocal();
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    final estado = appointment['estado_nombre'] ?? 'Sin estado';
    final notas = appointment['notas_veterinaria'] ?? '';

    Color estadoColor = softGreen;
    IconData estadoIcon = Icons.schedule;

    switch (appointment['estado_id']) {
      case 1: // Pendiente
        estadoColor = Colors.orange;
        estadoIcon = Icons.pending_actions;
        break;
      case 2: // Confirmada
        estadoColor = Colors.blue;
        estadoIcon = Icons.check_circle_outline;
        break;
      case 3: // Completada
        estadoColor = Colors.green;
        estadoIcon = Icons.check_circle;
        break;
      case 4: // Cancelada
        estadoColor = Colors.red;
        estadoIcon = Icons.cancel;
        break;
      case 5: // No asistió
        estadoColor = Colors.grey;
        estadoIcon = Icons.event_busy;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: softGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  formattedDate,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: estadoColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(estadoIcon, color: estadoColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      estado,
                      style: TextStyle(
                        color: estadoColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (notas.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: mint.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notes,
                          color: darkGreen.withOpacity(0.7), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Notas del veterinario:',
                        style: TextStyle(
                          color: darkGreen.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notas,
                    style: const TextStyle(
                      color: darkGreen,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicalHistoryButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicalRecordsScreen(
                petId: widget.patient['id'],
              ),
            ),
          );
        },
        icon: const Icon(Icons.medical_services, size: 20),
        label: const Text(
          'Ver Historial Clínico',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: softGreen,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
