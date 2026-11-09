// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;

Future<({double lat, double lng, String? error})> getDeviceLocation() async {
  try {
    final completer = Completer<({double lat, double lng, String? error})>();

    html.window.navigator.geolocation.getCurrentPosition(
      enableHighAccuracy: true,
      timeout: const Duration(seconds: 12),
    ).then((position) {
      final coords = position.coords;
      if (coords != null && coords.latitude != null && coords.longitude != null) {
        completer.complete((
          lat: coords.latitude!.toDouble(),
          lng: coords.longitude!.toDouble(),
          error: null,
        ));
      } else {
        completer.complete((
          lat: 7.0640,
          lng: 125.6000,
          error: 'GPS coordinates were empty.',
        ));
      }
    }).catchError((err) {
      completer.complete((
        lat: 0.0,
        lng: 0.0,
        error: 'Location permission was denied or unavailable in your browser.',
      ));
    });

    return await completer.future;
  } catch (e) {
    return (
      lat: 0.0,
      lng: 0.0,
      error: 'Location access error: $e',
    );
  }
}
