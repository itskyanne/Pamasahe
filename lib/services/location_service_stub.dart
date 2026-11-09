import 'dart:async';

Future<({double lat, double lng, String? error})> getDeviceLocation() async {
  // Default fallback for platforms without direct HTML5 navigator
  return (lat: 7.0640, lng: 125.6000, error: null);
}
