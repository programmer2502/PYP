import 'dart:math';

class GeohashUtil {
  GeohashUtil._();

  static const String _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

  /// Encodes latitude and longitude into a geohash string of [precision] length.
  static String encode(double latitude, double longitude, {int precision = 9}) {
    var latMin = -90.0, latMax = 90.0;
    var lonMin = -180.0, lonMax = 180.0;
    var hash = '';
    var bit = 0;
    var ch = 0;
    var even = true;

    while (hash.length < precision) {
      if (even) {
        final mid = (lonMin + lonMax) / 2;
        if (longitude > mid) {
          ch |= 1 << (4 - bit);
          lonMin = mid;
        } else {
          lonMax = mid;
        }
      } else {
        final mid = (latMin + latMax) / 2;
        if (latitude > mid) {
          ch |= 1 << (4 - bit);
          latMin = mid;
        } else {
          latMax = mid;
        }
      }

      even = !even;
      if (bit < 4) {
        bit++;
      } else {
        hash += _base32[ch];
        bit = 0;
        ch = 0;
      }
    }
    return hash;
  }

  /// Calculates the approximate distance in kilometers between two GPS coordinates
  static double distanceBetween(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  /// Returns geohash query bounds for a center and radius in kilometers.
  static List<String> getGeohashQueries(double lat, double lon, double radiusKm) {
    // Determine geohash precision suitable for radius
    int precision;
    if (radiusKm > 600) {
      precision = 2;
    } else if (radiusKm > 70) {
      precision = 3;
    } else if (radiusKm > 20) {
      precision = 4;
    } else if (radiusKm > 2.5) {
      precision = 5;
    } else if (radiusKm > 0.6) {
      precision = 6;
    } else {
      precision = 7;
    }

    final centerHash = encode(lat, lon, precision: precision);
    return [centerHash];
  }
}
