import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:where_is_library/core/view/base_view.dart';
import 'package:where_is_library/view/map/model/map_extra_model.dart';

import 'map_view_model.dart';

class MapView extends StatefulWidget {
  const MapView({super.key, required this.extra});

  final MapExtraModel extra;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late final MapViewModel vm = MapViewModel()..init();

  @override
  void initState() {
    super.initState();
    vm.paramterOfExtra = widget.extra.libLocs;
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      vm: vm,
      builder: (ctx, viewModel) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Harita'),
            actions: [
              Observer(
                builder: (_) => IconButton(
                  onPressed: vm.isInitialized ? () => vm.refreshLocation() : null,
                  icon: const Icon(Icons.search),
                  tooltip: 'Konumu Yenile',
                ),
              ),
            ],
          ),
          body: Observer(
            builder: (_) {
              if (!vm.isInitialized) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(vm.statusMessage, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                    ],
                  ),
                );
              }

              return Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: vm.initialCameraPosition,
                    markers: vm.markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    // Custom button kullanıyoruz
                    zoomControlsEnabled: true,
                  ),
                  DraggableScrollableSheet(
                    initialChildSize: 0.1,
                    minChildSize: 0.08,
                    maxChildSize: 0.5,
                    snap: true,
                    snapSizes: const [0.08, 0.5],
                    builder: (context, scrollController) {
                      return SizedBox(
                        height: double.infinity,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                          child: Container(
                            height: double.infinity,
                            decoration: BoxDecoration(color: Colors.white),
                            child: Column(
                              children: [
                                Container(
                                  width: 40,
                                  height: 5,
                                  margin: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text('Kütüphane Detayları', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
