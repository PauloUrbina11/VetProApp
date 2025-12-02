import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/config/theme.dart';
import '../../app/services/medical_records_service.dart';

class MedicalRecordsScreen extends StatefulWidget {
  final int petId;

  const MedicalRecordsScreen({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _records = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMedicalRecords();
  }

  Future<void> _loadMedicalRecords() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final records =
          await MedicalRecordsService.getMedicalRecordsByPet(widget.petId);
      setState(() {
        _records = List<Map<String, dynamic>>.from(records);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
        title: const Text(
          'Historial Clínico',
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
          ? const Center(
              child: CircularProgressIndicator(color: softGreen),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : _records.isEmpty
                  ? _buildEmptyState()
                  : _buildRecordsList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: darkGreen,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadMedicalRecords,
              style: ElevatedButton.styleFrom(
                backgroundColor: softGreen,
                foregroundColor: white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 64,
              color: darkGreen.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay historial clínico registrado',
              style: TextStyle(
                color: darkGreen,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Las consultas médicas aparecerán aquí',
              style: TextStyle(
                color: darkGreen.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    return RefreshIndicator(
      onRefresh: _loadMedicalRecords,
      color: softGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final record = _records[index];
          return _buildRecordCard(record);
        },
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    final fecha = record['fecha'] != null
        ? DateTime.parse(record['fecha'])
        : DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(fecha);
    final veterinariaNombre = record['veterinaria_nombre'] ?? 'Veterinaria';
    final motivo = record['motivo'] ?? 'Sin motivo especificado';
    final descripcion = record['descripcion'] ?? '';
    final diagnostico = record['diagnostico'] ?? '';
    final tratamiento = record['tratamiento'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: softGreen.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.medical_services,
            color: softGreen,
            size: 24,
          ),
        ),
        title: Text(
          motivo,
          style: const TextStyle(
            color: darkGreen,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: darkGreen.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: darkGreen.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.local_hospital,
                  size: 14,
                  color: darkGreen.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    veterinariaNombre,
                    style: TextStyle(
                      color: darkGreen.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          if (descripcion.isNotEmpty) ...[
            _buildDetailSection(
              'Descripción',
              descripcion,
              Icons.description,
            ),
            const SizedBox(height: 12),
          ],
          if (diagnostico.isNotEmpty) ...[
            _buildDetailSection(
              'Diagnóstico',
              diagnostico,
              Icons.assignment,
            ),
            const SizedBox(height: 12),
          ],
          if (tratamiento.isNotEmpty) ...[
            _buildDetailSection(
              'Tratamiento',
              tratamiento,
              Icons.medication,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: softGreen,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: darkGreen,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: mint.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            content,
            style: const TextStyle(
              color: darkGreen,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
