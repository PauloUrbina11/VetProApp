import 'package:flutter/material.dart';
import '../../app/services/admin_service.dart';
import '../../app/config/theme.dart';

class ManageRolesScreen extends StatefulWidget {
  const ManageRolesScreen({super.key});
  @override
  State<ManageRolesScreen> createState() => _ManageRolesScreenState();
}

class _ManageRolesScreenState extends State<ManageRolesScreen> {
  List<dynamic> _users = [];
  List<dynamic> _veterinariaRoles = [];
  List<dynamic> _veterinarias = [];
  bool _loading = true;
  String? _error;
  int? _selectedVeterinariaRolId;
  int? _selectedUserId;
  int? _selectedVeterinariaId;
  bool _assigning = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final users = await AdminService.listVeterinariaUsers();
      final roles = await AdminService.listVeterinariaRoles();
      final vets = await AdminService.listVeterinarias();
      setState(() {
        _users = users;
        _veterinariaRoles = roles;
        _veterinarias = vets;
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

  Future<void> _assign() async {
    if (_selectedUserId == null ||
        _selectedVeterinariaRolId == null ||
        _selectedVeterinariaId == null) {
      setState(() {
        _error = 'Debe seleccionar usuario, veterinaria y rol';
      });
      return;
    }
    setState(() {
      _assigning = true;
      _error = null;
    });
    try {
      await AdminService.assignVeterinariaRole(
        _selectedVeterinariaId!,
        _selectedUserId!,
        _selectedVeterinariaRolId!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rol de veterinaria asignado')));
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _assigning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
        title: const Text(
          'Asignar Roles Veterinaria',
          style:
              TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
        backgroundColor: softGreen,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: lightGreen.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: darkGreen,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    const Text(
                      'Usuarios con rol Veterinaria',
                      style: TextStyle(
                        color: darkGreen,
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (ctx, i) {
                          final u = _users[i];
                          final isSelected = _selectedUserId == u['id'];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? lightGreen.withOpacity(0.8)
                                  : lightGreen.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                '${u['nombre_completo'] ?? 'Usuario'}',
                                style: const TextStyle(
                                  color: darkGreen,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${u['correo']} - ID: ${u['id']}',
                                style: TextStyle(
                                  color: darkGreen.withOpacity(0.7),
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              selected: isSelected,
                              onTap: () => setState(() {
                                _selectedUserId = u['id'];
                              }),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: lightGreen.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Veterinaria',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: darkGreen,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: softGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<int>(
                              value: _selectedVeterinariaId,
                              hint: const Text(
                                'Seleccionar veterinaria',
                                style: TextStyle(
                                  color: white,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              isExpanded: true,
                              underline: const SizedBox(),
                              dropdownColor: const Color(0xFF15803D),
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                              ),
                              items: _veterinarias
                                  .map<DropdownMenuItem<int>>((vet) {
                                return DropdownMenuItem<int>(
                                  value: vet['id'],
                                  child: Text(
                                    vet['nombre'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() {
                                _selectedVeterinariaId = val;
                              }),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Rol en Veterinaria',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: darkGreen,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: softGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<int>(
                              value: _selectedVeterinariaRolId,
                              hint: const Text(
                                'Seleccionar rol',
                                style: TextStyle(
                                  color: white,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              isExpanded: true,
                              underline: const SizedBox(),
                              dropdownColor: const Color(0xFF15803D),
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Montserrat',
                              ),
                              items: _veterinariaRoles
                                  .map<DropdownMenuItem<int>>((role) {
                                return DropdownMenuItem<int>(
                                  value: role['id'],
                                  child: Text(
                                    role['nombre'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() {
                                _selectedVeterinariaRolId = val;
                              }),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: _assigning ? null : _assign,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: white,
                                foregroundColor: darkGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _assigning
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: darkGreen,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Asignar Rol',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
