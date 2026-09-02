import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../core/utils/geohash_util.dart';

class LocationResult {
  final String formattedAddress;
  final String city;
  final double latitude;
  final double longitude;
  final String geohash;

  LocationResult({
    required this.formattedAddress,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.geohash,
  });
}

class LocationSuggestion {
  final String description;
  final String placeId;
  final double? latitude;
  final double? longitude;

  LocationSuggestion({
    required this.description,
    required this.placeId,
    this.latitude,
    this.longitude,
  });
}

class LocationService {
  /// Request location permission and get current device position
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  /// Get reverse-geocoded location result from GPS position
  Future<LocationResult?> getCurrentLocationDetails() async {
    final position = await getCurrentPosition();
    if (position == null) return null;

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String formattedAddress = 'Current Location';
      String city = 'Nearby';

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final street = place.street ?? '';
        final locality = place.locality ?? place.subLocality ?? '';
        final adminArea = place.administrativeArea ?? '';

        city = locality.isNotEmpty ? locality : adminArea;
        formattedAddress = [street, locality, adminArea]
            .where((s) => s.isNotEmpty)
            .join(', ');
      }

      final geohash = GeohashUtil.encode(position.latitude, position.longitude);

      return LocationResult(
        formattedAddress: formattedAddress,
        city: city,
        latitude: position.latitude,
        longitude: position.longitude,
        geohash: geohash,
      );
    } catch (e) {
      // Fallback
      final geohash = GeohashUtil.encode(position.latitude, position.longitude);
      return LocationResult(
        formattedAddress: '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
        city: 'GPS Coordinates',
        latitude: position.latitude,
        longitude: position.longitude,
        geohash: geohash,
      );
    }
  }

  /// Search places by text query (Nominatim / Google Places)
  Future<List<LocationSuggestion>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=6',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'LensMatchApp/1.0 (lensmatch.app)'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) {
          final lat = double.tryParse(item['lat']?.toString() ?? '');
          final lon = double.tryParse(item['lon']?.toString() ?? '');
          return LocationSuggestion(
            description: item['display_name'] ?? query,
            placeId: item['place_id']?.toString() ?? '',
            latitude: lat,
            longitude: lon,
          );
        }).toList();
      }
    } catch (_) {
      // Fallback geocoding
      try {
        final locations = await locationFromAddress(query);
        return locations.map((loc) {
          return LocationSuggestion(
            description: query,
            placeId: '${loc.latitude}_${loc.longitude}',
            latitude: loc.latitude,
            longitude: loc.longitude,
          );
        }).toList();
      } catch (_) {}
    }

    return [];
  }
}
