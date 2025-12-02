import 'package:flutter/material.dart';
import '../../app/config/theme.dart';
import '../../app/services/recommendations_service.dart';
import '../../app/services/pets_service.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  bool _loading = true;
  List<dynamic> _recommendations = [];
  // List<dynamic> _userPets = []; // No se usa actualmente

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      // Obtener mascotas del usuario
      final pets = await PetsService.getMyPets();
      // _userPets = pets; // No se usa actualmente

      // Especies únicas de las mascotas
      final speciesIds = pets
          .map((p) => p['especie_id'])
          .where((id) => id != null)
          .toSet()
          .cast<int>()
          .toList();

      List<dynamic> recs = [];
      if (speciesIds.isNotEmpty) {
        final results = await Future.wait(speciesIds.map(
            (id) => RecommendationsService.getRecommendations(especieId: id)));
        for (final list in results) recs.addAll(list);
        // Eliminar duplicados por id
        final seen = <int>{};
        recs = recs.where((r) {
          final rid = r['id'] as int?;
          if (rid == null) return true;
          if (seen.contains(rid)) return false;
          seen.add(rid);
          return true;
        }).toList();
      }

      setState(() {
        _recommendations = recs;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: mint,
        appBar: AppBar(
            title: const Text('Recomendaciones',
                style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: softGreen,
            foregroundColor: white),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _recommendations.isEmpty
                ? Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Icon(Icons.lightbulb_outline,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('No hay recomendaciones disponibles',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 16)),
                      ]))
                : RefreshIndicator(
                    onRefresh: _loadRecommendations,
                    child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _recommendations.length,
                        itemBuilder: (context, index) {
                          final rec = _recommendations[index];
                          return _buildRecommendationCard(rec);
                        })));
  }

  Widget _buildRecommendationCard(Map<String, dynamic> rec) {
    return Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (rec['imagen_url'] != null)
            ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(rec['imagen_url'],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: Colors.grey.shade200,
                        child: Icon(Icons.image_not_supported,
                            size: 64, color: Colors.grey.shade400)))),
          Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rec['titulo'] ?? 'Sin título',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkGreen)),
                    const SizedBox(height: 8),
                    Text(rec['descripcion'] ?? '',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.5)),
                  ])),
        ]));
  }
}
