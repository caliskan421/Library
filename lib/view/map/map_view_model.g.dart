// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_view_model.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MapViewModel on _MapViewModel, Store {
  Computed<Set<Marker>>? _$markersComputed;

  @override
  Set<Marker> get markers => (_$markersComputed ??= Computed<Set<Marker>>(
    () => super.markers,
    name: '_MapViewModel.markers',
  )).value;
  Computed<CameraPosition>? _$initialCameraPositionComputed;

  @override
  CameraPosition get initialCameraPosition =>
      (_$initialCameraPositionComputed ??= Computed<CameraPosition>(
        () => super.initialCameraPosition,
        name: '_MapViewModel.initialCameraPosition',
      )).value;

  late final _$currentPositionAtom = Atom(
    name: '_MapViewModel.currentPosition',
    context: context,
  );

  @override
  LatLng? get currentPosition {
    _$currentPositionAtom.reportRead();
    return super.currentPosition;
  }

  @override
  set currentPosition(LatLng? value) {
    _$currentPositionAtom.reportWrite(value, super.currentPosition, () {
      super.currentPosition = value;
    });
  }

  late final _$isLocationPermissionGrantedAtom = Atom(
    name: '_MapViewModel.isLocationPermissionGranted',
    context: context,
  );

  @override
  bool get isLocationPermissionGranted {
    _$isLocationPermissionGrantedAtom.reportRead();
    return super.isLocationPermissionGranted;
  }

  @override
  set isLocationPermissionGranted(bool value) {
    _$isLocationPermissionGrantedAtom.reportWrite(
      value,
      super.isLocationPermissionGranted,
      () {
        super.isLocationPermissionGranted = value;
      },
    );
  }

  late final _$isLocationServiceEnabledAtom = Atom(
    name: '_MapViewModel.isLocationServiceEnabled',
    context: context,
  );

  @override
  bool get isLocationServiceEnabled {
    _$isLocationServiceEnabledAtom.reportRead();
    return super.isLocationServiceEnabled;
  }

  @override
  set isLocationServiceEnabled(bool value) {
    _$isLocationServiceEnabledAtom.reportWrite(
      value,
      super.isLocationServiceEnabled,
      () {
        super.isLocationServiceEnabled = value;
      },
    );
  }

  late final _$statusMessageAtom = Atom(
    name: '_MapViewModel.statusMessage',
    context: context,
  );

  @override
  String get statusMessage {
    _$statusMessageAtom.reportRead();
    return super.statusMessage;
  }

  @override
  set statusMessage(String value) {
    _$statusMessageAtom.reportWrite(value, super.statusMessage, () {
      super.statusMessage = value;
    });
  }

  late final _$isInitializedAtom = Atom(
    name: '_MapViewModel.isInitialized',
    context: context,
  );

  @override
  bool get isInitialized {
    _$isInitializedAtom.reportRead();
    return super.isInitialized;
  }

  @override
  set isInitialized(bool value) {
    _$isInitializedAtom.reportWrite(value, super.isInitialized, () {
      super.isInitialized = value;
    });
  }

  late final _$initializeLocationServicesAsyncAction = AsyncAction(
    '_MapViewModel.initializeLocationServices',
    context: context,
  );

  @override
  Future<void> initializeLocationServices() {
    return _$initializeLocationServicesAsyncAction.run(
      () => super.initializeLocationServices(),
    );
  }

  late final _$startLocationUpdatesAsyncAction = AsyncAction(
    '_MapViewModel.startLocationUpdates',
    context: context,
  );

  @override
  Future<void> startLocationUpdates() {
    return _$startLocationUpdatesAsyncAction.run(
      () => super.startLocationUpdates(),
    );
  }

  late final _$refreshLocationAsyncAction = AsyncAction(
    '_MapViewModel.refreshLocation',
    context: context,
  );

  @override
  Future<void> refreshLocation() {
    return _$refreshLocationAsyncAction.run(() => super.refreshLocation());
  }

  late final _$_MapViewModelActionController = ActionController(
    name: '_MapViewModel',
    context: context,
  );

  @override
  void updateStatus(String message) {
    final _$actionInfo = _$_MapViewModelActionController.startAction(
      name: '_MapViewModel.updateStatus',
    );
    try {
      return super.updateStatus(message);
    } finally {
      _$_MapViewModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateCurrentPosition(LatLng position) {
    final _$actionInfo = _$_MapViewModelActionController.startAction(
      name: '_MapViewModel.updateCurrentPosition',
    );
    try {
      return super.updateCurrentPosition(position);
    } finally {
      _$_MapViewModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLocationPermissionGranted(bool granted) {
    final _$actionInfo = _$_MapViewModelActionController.startAction(
      name: '_MapViewModel.setLocationPermissionGranted',
    );
    try {
      return super.setLocationPermissionGranted(granted);
    } finally {
      _$_MapViewModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLocationServiceEnabled(bool enabled) {
    final _$actionInfo = _$_MapViewModelActionController.startAction(
      name: '_MapViewModel.setLocationServiceEnabled',
    );
    try {
      return super.setLocationServiceEnabled(enabled);
    } finally {
      _$_MapViewModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setInitialized(bool initialized) {
    final _$actionInfo = _$_MapViewModelActionController.startAction(
      name: '_MapViewModel.setInitialized',
    );
    try {
      return super.setInitialized(initialized);
    } finally {
      _$_MapViewModelActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currentPosition: ${currentPosition},
isLocationPermissionGranted: ${isLocationPermissionGranted},
isLocationServiceEnabled: ${isLocationServiceEnabled},
statusMessage: ${statusMessage},
isInitialized: ${isInitialized},
markers: ${markers},
initialCameraPosition: ${initialCameraPosition}
    ''';
  }
}
