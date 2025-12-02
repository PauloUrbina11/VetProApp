import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/config/theme.dart';
import '../../app/services/admin_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<dynamic> _users = [];
  List<dynamic> _filteredUsers = [];
  bool _loading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final users = await AdminService.listUsers();
      debugPrint('Users loaded: ${users.length}');
      debugPrint('First user: ${users.isNotEmpty ? users[0] : "empty"}');
      setState(() {
        _users = users;
        _filteredUsers = users;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((user) {
          final nombre = (user['nombre'] ?? '').toString().toLowerCase();
          return nombre.contains(query);
        }).toList();
      }
    });
  }

  Color _getRolColor(int? rolId) {
    switch (rolId) {
      case 1:
        return Colors.purple;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getRolIcon(int? rolId) {
    switch (rolId) {
      case 1:
        return Icons.admin_panel_settings;
      case 2:
        return Icons.medical_services;
      case 3:
        return Icons.person;
      default:
        return Icons.account_circle;
    }
  }

  Future<void> _toggleUserStatus(dynamic user) async {
    final bool isActive = user['activo'] ?? true;
    final String action = isActive ? 'desactivar' : 'activar';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action[0].toUpperCase()}${action.substring(1)} usuario'),
        content:
            Text('¿Estás seguro de que deseas $action a ${user['nombre']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? Colors.red : softGreen,
            ),
            child: Text(action[0].toUpperCase() + action.substring(1)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AdminService.toggleUserActive(user['id']);

        // Actualizar el estado local
        setState(() {
          final index = _users.indexWhere((u) => u['id'] == user['id']);
          if (index != -1) {
            _users[index]['activo'] = !isActive;
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Usuario ${!isActive ? 'activado' : 'desactivado'} correctamente'),
              backgroundColor: softGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(
        title: const Text(
          'Usuarios del Sistema',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: softGreen,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: softGreen))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: darkGreen),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUsers,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: softGreen,
                        ),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Buscador
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre...',
                          prefixIcon:
                              const Icon(Icons.search, color: darkGreen),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon:
                                      const Icon(Icons.clear, color: darkGreen),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),

                    // Estadísticas rápidas
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: lightGreen.withOpacity(0.3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            'Total',
                            _users.length.toString(),
                            Icons.people,
                          ),
                          _buildStatCard(
                            'Admins',
                            _users
                                .where((u) => u['rol_id'] == 1)
                                .length
                                .toString(),
                            Icons.admin_panel_settings,
                          ),
                          _buildStatCard(
                            'Vets',
                            _users
                                .where((u) => u['rol_id'] == 2)
                                .length
                                .toString(),
                            Icons.medical_services,
                          ),
                          _buildStatCard(
                            'Clientes',
                            _users
                                .where((u) => u['rol_id'] == 3)
                                .length
                                .toString(),
                            Icons.person,
                          ),
                        ],
                      ),
                    ),

                    // Lista de usuarios
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadUsers,
                        color: softGreen,
                        child: _filteredUsers.isEmpty && !_loading
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.people,
                                        size: 64,
                                        color: darkGreen.withOpacity(0.3)),
                                    const SizedBox(height: 16),
                                    Text(
                                      _searchController.text.isEmpty
                                          ? 'No hay usuarios registrados'
                                          : 'No se encontraron usuarios con ese nombre',
                                      style: const TextStyle(
                                        color: darkGreen,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredUsers.length,
                                itemBuilder: (context, index) {
                                  final user = _filteredUsers[index];
                                  return _buildUserCard(user);
                                },
                              ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: darkGreen, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: darkGreen.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(dynamic user) {
    final rolColor = _getRolColor(user['rol_id']);
    final rolIcon = _getRolIcon(user['rol_id']);
    final rolName = user['rol_nombre'] ?? 'Desconocido';
    final createdAt = user['created_at'] != null
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(user['created_at']))
        : 'N/A';
    final bool isActive = user['activo'] ?? true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: rolColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(rolIcon, color: rolColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['nombre'] ?? 'Sin nombre',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: darkGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['email'] ?? 'N/A',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: rolColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rolName,
                    style: TextStyle(
                      color: rolColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Registro: $createdAt',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const Spacer(),
                if (user['celular'] != null) ...[
                  Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    user['celular'],
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleUserStatus(user),
                    icon: Icon(
                      isActive ? Icons.block : Icons.check_circle,
                      size: 18,
                    ),
                    label: Text(isActive ? 'Desactivar' : 'Activar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isActive ? Colors.red : Colors.green,
                      side: BorderSide(
                        color: isActive ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
