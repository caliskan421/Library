import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map_view_model.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late final MapViewModel _viewModel = MapViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.initializeLocationServices();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harita'),
        actions: [
          Observer(
            builder: (_) => IconButton(
              onPressed: _viewModel.isInitialized
                  ? () => _viewModel.refreshLocation()
                  : null,
              icon: const Icon(Icons.my_location),
              tooltip: 'Konumu Yenile',
            ),
          ),
        ],
      ),
      body: Observer(
        builder: (_) {
          if (!_viewModel.isInitialized) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    _viewModel.statusMessage,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return GoogleMap(
            initialCameraPosition: _viewModel.initialCameraPosition,
            markers: _viewModel.markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // Custom button kullanıyoruz
            zoomControlsEnabled: true,
          );
        },
      ),
    );
  }
}
