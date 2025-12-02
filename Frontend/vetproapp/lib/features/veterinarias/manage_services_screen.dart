import 'package:flutter/material.dart';
import '../../../app/config/theme.dart';
import '../../../app/services/veterinaria_services_service.dart';
import '../../../app/services/services_service.dart';
import '../../../app/services/permissions_service.dart';
import '../../../app/services/auth_service.dart';

class ManageServicesScreen extends StatefulWidget {
  final int veterinariaId;

  const ManageServicesScreen({
    Key? key,
    required this.veterinariaId,
  }) : super(key: key);

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  bool _loading = true;
  List<dynamic> _serviciosVeterinaria = [];
  List<dynamic> _todosLosServicios = [];
  bool _canEdit = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final role = await AuthService.getRole();
    if (role == 2) {
      await PermissionsService.loadVeterinariaRoles();
      setState(() {
        _canEdit = PermissionsService.canEditService();
      });
    }
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final serviciosVet =
          await VeterinariaServicesService.getServicios(widget.veterinariaId);
      final todosServicios = await ServicesService.getServices();

      setState(() {
        _serviciosVeterinaria = serviciosVet;
        _todosLosServicios = todosServicios;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _servicioEstaAgregado(int servicioId) {
    return _serviciosVeterinaria
        .any((sv) => sv['servicio_id'] == servicioId && sv['activo'] == true);
  }

  Future<void> _agregarServicio(int servicioId) async {
    try {
      await VeterinariaServicesService.addServicio(
          widget.veterinariaId, servicioId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Servicio agregado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
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
    }
  }

  Future<void> _eliminarServicio(int servicioVeterinariaId) async {
    try {
      await VeterinariaServicesService.deleteServicio(
          widget.veterinariaId, servicioVeterinariaId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Servicio eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
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
    }
  }

  void _mostrarDialogoAgregar() {
    // Filtrar servicios que aún no están agregados
    final serviciosDisponibles = _todosLosServicios
        .where((servicio) => !_servicioEstaAgregado(servicio['id']))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Agregar Servicio',
          style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: serviciosDisponibles.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Todos los servicios han sido agregados',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: serviciosDisponibles.length,
                  itemBuilder: (context, index) {
                    final servicio = serviciosDisponibles[index];
                    return ListTile(
                      title: Text(servicio['nombre']),
                      subtitle: servicio['descripcion'] != null
                          ? Text(
                              servicio['descripcion'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        _agregarServicio(servicio['id']);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
        title: const Text(
          'Gestionar Servicios',
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
      floatingActionButton: _canEdit
          ? FloatingActionButton(
              onPressed: _mostrarDialogoAgregar,
              backgroundColor: softGreen,
              child: const Icon(Icons.add, color: white),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: softGreen))
          : _serviciosVeterinaria.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.medical_services_outlined,
                          size: 64, color: darkGreen.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay servicios agregados',
                        style: TextStyle(
                          color: darkGreen,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_canEdit)
                        ElevatedButton.icon(
                          onPressed: _mostrarDialogoAgregar,
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar servicio'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: softGreen,
                            foregroundColor: white,
                          ),
                        ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: softGreen,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _serviciosVeterinaria
                        .where((sv) => sv['activo'] == true)
                        .length,
                    itemBuilder: (context, index) {
                      final serviciosActivos = _serviciosVeterinaria
                          .where((sv) => sv['activo'] == true)
                          .toList();
                      final servicioVet = serviciosActivos[index];
                      return _buildServicioCard(servicioVet);
                    },
                  ),
                ),
    );
  }

  Widget _buildServicioCard(dynamic servicioVet) {
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
          child: const Icon(Icons.medical_services, color: softGreen),
        ),
        title: Text(
          servicioVet['servicio_nombre'] ?? 'Sin nombre',
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
            if (servicioVet['tipo_servicio_nombre'] != null)
              Text(
                servicioVet['tipo_servicio_nombre'],
                style: TextStyle(
                  color: softGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (servicioVet['servicio_descripcion'] != null) ...[
              const SizedBox(height: 4),
              Text(
                servicioVet['servicio_descripcion'],
                style: TextStyle(
                  color: darkGreen.withOpacity(0.7),
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: _canEdit
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirmar eliminación'),
                      content: Text(
                          '¿Está seguro que desea eliminar el servicio "${servicioVet['servicio_nombre']}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _eliminarServicio(servicioVet['id']);
                          },
                          style:
                              TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }
}
