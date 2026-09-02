import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

class CurrentLocationState {
  final String formattedAddress;
  final String city;
  final double latitude;
  final double longitude;
  final String geohash;
  final bool isLoading;
  final String? error;

  const CurrentLocationState({
    this.formattedAddress = 'Select Location',
    this.city = 'Near You',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.geohash = '',
    this.isLoading = false,
    this.error,
  });

  CurrentLocationState copyWith({
    String? formattedAddress,
    String? city,
    double? latitude,
    double? longitude,
    String? geohash,
    bool? isLoading,
    String? error,
  }) {
    return CurrentLocationState(
      formattedAddress: formattedAddress ?? this.formattedAddress,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geohash: geohash ?? this.geohash,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LocationNotifier extends StateNotifier<CurrentLocationState> {
  final LocationService _locationService;

  LocationNotifier(this._locationService) : super(const CurrentLocationState()) {
    detectCurrentLocation();
  }

  Future<void> detectCurrentLocation() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _locationService.getCurrentLocationDetails();
      if (result != null) {
        state = state.copyWith(
          formattedAddress: result.formattedAddress,
          city: result.city,
          latitude: result.latitude,
          longitude: result.longitude,
          geohash: result.geohash,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Location permission denied or unavailable.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setCustomLocation({
    required String formattedAddress,
    required String city,
    required double latitude,
    required double longitude,
    required String geohash,
  }) {
    state = state.copyWith(
      formattedAddress: formattedAddress,
      city: city,
      latitude: latitude,
      longitude: longitude,
      geohash: geohash,
      isLoading: false,
      error: null,
    );
  }
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, CurrentLocationState>((ref) {
  final service = ref.watch(locationServiceProvider);
  return LocationNotifier(service);
});
