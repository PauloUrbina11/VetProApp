import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../app/config/theme.dart';
import '../../../app/services/veterinaria_service.dart';

class VeterinaryMapCard extends StatefulWidget {
  const VeterinaryMapCard({Key? key}) : super(key: key);

  @override
  State<VeterinaryMapCard> createState() => _VeterinaryMapCardState();
}

class _VeterinaryMapCardState extends State<VeterinaryMapCard> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _hasLocationPermission = false;

  // Ubicación por defecto (centro de una ciudad ejemplo)
  static const LatLng _defaultLocation =
      LatLng(14.0818, -87.2068); // Tegucigalpa

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _checkLocationPermission();
    if (_hasLocationPermission) {
      await _getCurrentLocation();
    }
    await _loadVeterinarias();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _hasLocationPermission = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _hasLocationPermission = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _hasLocationPermission = false;
        });
        return;
      }

      setState(() {
        _hasLocationPermission = true;
      });
    } catch (e) {
      debugPrint('Error verificando permisos: $e');
      setState(() {
        _hasLocationPermission = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });

      // Mover la cámara a la ubicación actual
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            14.0,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error obteniendo ubicación: $e');
    }
  }

  Future<void> _loadVeterinarias() async {
    try {
      final veterinarias = await VeterinariaService.getAllVeterinarias();

      setState(() {
        _markers.clear();

        // Agregar marcador de ubicación actual si está disponible
        if (_currentPosition != null) {
          _markers.add(
            Marker(
              markerId: const MarkerId('current_location'),
              position: LatLng(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
              infoWindow: const InfoWindow(
                title: 'Tu ubicación',
              ),
            ),
          );
        }

        // Agregar marcadores para cada veterinaria
        for (var i = 0; i < veterinarias.length; i++) {
          final vet = veterinarias[i];

          // Si la veterinaria tiene coordenadas, usarlas
          // De lo contrario, generar ubicaciones de ejemplo cerca de la ubicación por defecto
          double lat = _defaultLocation.latitude + (i * 0.01);
          double lng = _defaultLocation.longitude + (i * 0.01);

          if (vet['latitud'] != null && vet['longitud'] != null) {
            lat = double.tryParse(vet['latitud'].toString()) ?? lat;
            lng = double.tryParse(vet['longitud'].toString()) ?? lng;
          }

          _markers.add(
            Marker(
              markerId: MarkerId('vet_${vet['id']}'),
              position: LatLng(lat, lng),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen,
              ),
              infoWindow: InfoWindow(
                title: vet['nombre'] ?? 'Veterinaria',
                snippet: vet['direccion'] ?? 'Ver detalles',
                onTap: () {
                  _showVeterinariaDetails(vet);
                },
              ),
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('Error cargando veterinarias: $e');
    }
  }

  void _showVeterinariaDetails(dynamic veterinaria) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              veterinaria['nombre'] ?? 'Veterinaria',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: vetproGreen,
              ),
            ),
            const SizedBox(height: 12),
            if (veterinaria['direccion'] != null) ...[
              Row(
                children: [
                  const Icon(Icons.location_on, color: vetproGreen, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(veterinaria['direccion']),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (veterinaria['telefono'] != null) ...[
              Row(
                children: [
                  const Icon(Icons.phone, color: vetproGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(veterinaria['telefono']),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (veterinaria['email'] != null) ...[
              Row(
                children: [
                  const Icon(Icons.email, color: vetproGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(veterinaria['email']),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/veterinaria_detail',
                    arguments: veterinaria['id'],
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: vetproGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Ver Detalles',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: softGreen,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: vetproGreen,
                ),
              )
            : Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition != null
                          ? LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            )
                          : _defaultLocation,
                      zoom: 14.0,
                    ),
                    markers: _markers,
                    myLocationEnabled: _hasLocationPermission,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    onMapCreated: (controller) {
                      _mapController = controller;
                      if (_currentPosition != null) {
                        controller.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            ),
                            14.0,
                          ),
                        );
                      }
                    },
                  ),
                  // Botón para centrar en ubicación actual
                  if (_hasLocationPermission)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.white,
                        onPressed: () async {
                          await _getCurrentLocation();
                        },
                        child: const Icon(
                          Icons.my_location,
                          color: vetproGreen,
                        ),
                      ),
                    ),
                  // Botón para ver todas las veterinarias
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.white,
                      onPressed: () {
                        Navigator.pushNamed(context, '/veterinarias');
                      },
                      child: const Icon(
                        Icons.list,
                        color: vetproGreen,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
