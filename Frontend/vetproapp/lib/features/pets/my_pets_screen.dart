import 'package:flutter/material.dart';
import '../../app/config/theme.dart';
import '../../app/services/auth_service.dart';
import '../../app/services/pets_service.dart';
import '../../app/widgets/empty_state_widget.dart';
import 'widgets/pet_card.dart';
import 'add_pet_screen.dart';
import 'pet_detail_screen.dart';

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({super.key});

  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  bool _loading = true;
  List<dynamic> _pets = [];
  int? _userRole;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final role = await AuthService.getRole();
      List<dynamic> pets;
      if (role == 1) {
        // Admin: ver todas las mascotas
        pets = await PetsService.getAllPets();
      } else {
        // Usuario: solo sus mascotas
        pets = await PetsService.getMyPets();
      }
      setState(() {
        _userRole = role;
        _pets = pets;
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

  Future<void> _showAddPetDialog() async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const AddPetScreen()));
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _showPetDetail(dynamic pet) async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => PetDetailScreen(pet: pet)));
    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: mint,
        appBar: AppBar(
            title: Text(_userRole == 1 ? 'Todas las Mascotas' : 'Mis Mascotas',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: softGreen,
            foregroundColor: white,
            elevation: 0),
        floatingActionButton: _userRole != 1
            ? FloatingActionButton(
                onPressed: _showAddPetDialog,
                backgroundColor: softGreen,
                child: const Icon(Icons.add, color: white))
            : null,
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: softGreen))
            : SafeArea(
                child: Column(children: [
                if (_error != null)
                  Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: lightGreen.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(_error!,
                          style: const TextStyle(color: darkGreen))),
                Expanded(
                  child: _pets.isEmpty
                      ? Center(
                          child: EmptyStateWidget(
                            icon: Icons.pets,
                            message: _userRole == 1
                                ? 'No hay mascotas registradas'
                                : 'No tienes mascotas registradas',
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          color: softGreen,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _pets.length,
                            itemBuilder: (context, index) {
                              final pet = _pets[index];
                              return PetCard(
                                pet: pet,
                                isAdmin: _userRole == 1,
                                onTap: () => _showPetDetail(pet),
                              );
                            },
                          ),
                        ),
                ),
              ])));
  }
}
