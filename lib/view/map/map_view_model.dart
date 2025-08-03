import 'dart:async';
import 'dart:developer';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mobx/mobx.dart';
import 'package:where_is_library/model/library_location.dart';

part 'map_view_model.g.dart';

class MapViewModel = _MapViewModel with _$MapViewModel;

abstract class _MapViewModel with Store {
  final Location _locationController = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  static const LatLng _initialLocation = LatLng(37.76, 30.557);
  static const LatLng _destinationLocation = LatLng(37.75, 30.55);

  @observable
  List<LibraryLocation> paramterOfExtra = [];

  @observable
  LatLng? currentPosition;

  @observable
  bool isLocationPermissionGranted = false;

  @observable
  bool isLocationServiceEnabled = false;

  @observable
  String statusMessage = 'Konum servisi hazırlanıyor...';

  @observable
  bool isInitialized = false;

  @computed
  Set<Marker> get markers {
    final markerSet = <Marker>{};
    for (var libLoc in paramterOfExtra) {
      markerSet.add(Marker(markerId: MarkerId(libLoc.id.toString()), icon: BitmapDescriptor.defaultMarker, position: _initialLocation));
    }
    if (currentPosition != null) {
      markerSet.add(Marker(markerId: const MarkerId("current"), icon: BitmapDescriptor.defaultMarker, position: currentPosition!));
    }

    return markerSet;
  }

  @computed
  CameraPosition get initialCameraPosition {
    return const CameraPosition(target: _initialLocation, zoom: 13);
  }

  @action
  void init() {
    initializeLocationServices();
  }

  @action
  void updateStatus(String message) {
    statusMessage = message;
    log('🗺️ MAP STATUS: $message');
  }

  @action
  void updateCurrentPosition(LatLng position) {
    currentPosition = position;
  }

  @action
  void setLocationPermissionGranted(bool granted) {
    isLocationPermissionGranted = granted;
  }

  @action
  void setLocationServiceEnabled(bool enabled) {
    isLocationServiceEnabled = enabled;
  }

  @action
  void setInitialized(bool initialized) {
    isInitialized = initialized;
  }

  @action
  Future<void> initializeLocationServices() async {
    try {
      updateStatus('Konum izinleri kontrol ediliyor...');

      // --> [Servis] durumunu kontrol et
      bool serviceEnabled = await _locationController.serviceEnabled();
      if (!serviceEnabled) {
        updateStatus('Konum servisi istek ediliyor...');
        serviceEnabled = await _locationController.requestService();
        if (!serviceEnabled) {
          updateStatus('Konum servisi reddedildi');
          setLocationServiceEnabled(false);
          return;
        }
      }
      setLocationServiceEnabled(true);

      // --> [İzin] durumunu kontrol et
      PermissionStatus permissionGranted = await _locationController.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        updateStatus('Konum izni istek ediliyor...');
        permissionGranted = await _locationController.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          updateStatus('Konum izni reddedildi');
          setLocationPermissionGranted(false);
          return;
        }
      }
      setLocationPermissionGranted(true);

      updateStatus('Konum güncellemeleri başlatılıyor...');
      await startLocationUpdates();
      setInitialized(true);
      updateStatus('Konum servisleri aktif');
    } catch (e) {
      updateStatus('Konum servisi başlatılırken hata: ${e.toString()}');
      log('Location initialization error: $e');
    }
  }

  @action
  Future<void> startLocationUpdates() async {
    try {
      // Önceki subscription varsa iptal et
      _locationSubscription?.cancel();

      _locationSubscription = _locationController.onLocationChanged.listen((LocationData locationData) {
        if (locationData.latitude != null && locationData.longitude != null) {
          final newPosition = LatLng(locationData.latitude!, locationData.longitude!);
          updateCurrentPosition(newPosition);
          log('🎯 Konum güncellendi: ${locationData.latitude}, ${locationData.longitude}');
        }
      });
    } catch (e) {
      updateStatus('Konum güncellemeleri başlatılırken hata: ${e.toString()}');
      log('Location updates error: $e');
    }
  }

  @action
  Future<void> refreshLocation() async {
    if (!isLocationPermissionGranted || !isLocationServiceEnabled) {
      await initializeLocationServices();
      return;
    }

    try {
      updateStatus('Konum yenileniyor...');
      final locationData = await _locationController.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        final newPosition = LatLng(locationData.latitude!, locationData.longitude!);
        updateCurrentPosition(newPosition);
        updateStatus('Konum yenilendi');
      }
    } catch (e) {
      updateStatus('Konum yenilenirken hata: ${e.toString()}');
      log('Refresh location error: $e');
    }
  }

  @action
  void printCurrentLocationToTerminal() {
    if (currentPosition != null) {
      log('📍 Mevcut Konum:');
      log('   Enlem (Latitude): ${currentPosition!.latitude.toStringAsFixed(6)}');
      log('   Boylam (Longitude): ${currentPosition!.longitude.toStringAsFixed(6)}');
      log('   Google Maps Link: https://www.google.com/maps?q=${currentPosition!.latitude},${currentPosition!.longitude}');
      updateStatus('Konum terminale yazdırıldı');
    } else {
      log('❌ Henüz konum bilgisi alınamadı. Lütfen önce konum servisini başlatın.');
      updateStatus('Konum bilgisi bulunamadı');
    }
  }

  void dispose() {
    // Stream subscription'ı iptal et
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }
}
