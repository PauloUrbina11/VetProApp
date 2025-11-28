import 'package:flutter/material.dart';
import '../../app/services/services_service.dart';
import '../../app/config/theme.dart';

class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  List<dynamic> _services = [];
  List<dynamic> _serviceTypes = [];
  bool _loading = true;
  String? _error;

  // Form fields
  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  int? _selectedTypeId;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final services = await ServicesService.getServices();
      final types = await ServicesService.getServiceTypes();
      setState(() {
        _services = services;
        _serviceTypes = types;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _createService() async {
    if (_nombreCtrl.text.isEmpty || _selectedTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complete los campos obligatorios')));
      return;
    }

    setState(() {
      _creating = true;
      _error = null;
    });

    try {
      final payload = <String, dynamic>{
        'nombre': _nombreCtrl.text.trim(),
        'tipo_servicio_id': _selectedTypeId,
      };
      if (_descripcionCtrl.text.isNotEmpty) {
        payload['descripcion'] = _descripcionCtrl.text.trim();
      }

      await ServicesService.createService(payload);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Servicio creado exitosamente')));
      _nombreCtrl.clear();
      _descripcionCtrl.clear();
      setState(() => _selectedTypeId = null);
      _loadData();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _creating = false;
      });
    }
  }

  Future<void> _deleteService(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar este servicio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ]));

    if (confirm == true) {
      try {
        await ServicesService.deleteService(id);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Servicio eliminado exitosamente')));
        _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: darkGreen,
            fontSize: 15)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: softGreen,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8)),
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.6))),
          style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 16),
      ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
        title: const Text(
          'Gestión de Servicios',
          style:
              TextStyle( fontWeight: FontWeight.bold)),
        backgroundColor: softGreen,
        elevation: 0),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: lightGreen.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: darkGreen))),
                    if (_error != null) const SizedBox(height: 12),

                    // Formulario de creación
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: lightGreen.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(18)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Crear Nuevo Servicio',
                            style: TextStyle(
                              color: darkGreen,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _buildInput(
                            controller: _nombreCtrl,
                            label: 'Nombre *'),
                          _buildInput(
                            controller: _descripcionCtrl,
                            label: 'Descripción',
                            maxLines: 3),
                          const Text(
                            'Tipo de Servicio *',
                            style: TextStyle(
                              color: darkGreen,
                              fontSize: 15)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: softGreen,
                              borderRadius: BorderRadius.circular(8)),
                            child: DropdownButton<int>(
                              value: _selectedTypeId,
                              hint: const Text(
                                'Seleccionar tipo',
                                style: TextStyle(
                                  color: white)),
                              isExpanded: true,
                              underline: const SizedBox(),
                              dropdownColor: softGreen,
                              style: const TextStyle(
                                color: white),
                              items: _serviceTypes
                                  .map<DropdownMenuItem<int>>((type) {
                                return DropdownMenuItem<int>(
                                  value: type['id'],
                                  child: Text(
                                    type['nombre'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white)));
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedTypeId = val))),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: _creating ? null : _createService,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: white,
                                foregroundColor: darkGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                              child: _creating
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: darkGreen,
                                        strokeWidth: 2))
                                  : const Text(
                                      'Crear Servicio',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold)))),
                        ])),

                    const SizedBox(height: 24),

                    // Lista de servicios
                    const Text(
                      'Servicios Existentes',
                      style: TextStyle(
                        color: darkGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    _services.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(18)),
                            child: const Center(
                              child: Text(
                                'No hay servicios registrados',
                                style: TextStyle(
                                  color: darkGreen,
                                  fontSize: 16))))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _services.length,
                            itemBuilder: (context, index) {
                              final service = _services[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  title: Text(
                                    service['nombre'] ?? 'Sin nombre',
                                    style: const TextStyle(
                                      color: darkGreen,
                                      fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      if (service['descripcion'] != null)
                                        Text(
                                          service['descripcion'],
                                          style: TextStyle(
                                            color: darkGreen.withOpacity(0.8))),
                                      if (service['tipo_nombre'] != null)
                                        Text(
                                          'Tipo: ${service['tipo_nombre']}',
                                          style: TextStyle(
                                            color: darkGreen.withOpacity(0.8))),
                                    ]),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _deleteService(service['id']))));
                            }),
                  ]))));
  }
}
