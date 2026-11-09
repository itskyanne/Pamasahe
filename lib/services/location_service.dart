import 'location_service_stub.dart'
    if (dart.library.html) 'location_service_web.dart' as impl;

class LocationService {
  /// Fetches the user's current GPS location via HTML5 Geolocation API on Web
  /// or returns fallback coordinates on unsupported platforms.
  static Future<({double lat, double lng, String? error})> getCurrentLocation() {
    return impl.getDeviceLocation();
  }
}
