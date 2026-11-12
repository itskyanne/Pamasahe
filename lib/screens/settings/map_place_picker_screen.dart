import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../models/saved_place.dart';
import '../../services/location_service.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/notification_banner.dart';

enum OsmMapStyle {
  osmStandard(
    'OpenStreetMap (Full Detail)',
    'https://tile.openstreetmap.de',
    '© OpenStreetMap contributors (Mapnik)',
  ),
  worldStreet(
    'Detailed Street Map (Esri/OSM)',
    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile',
    '© Esri, OpenStreetMap contributors',
  ),
  cleanLight(
    'Clean Light Gray',
    'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile',
    '© Esri, HERE, Garmin, OpenStreetMap',
  );

  final String label;
  final String baseUrl;
  final String attribution;
  const OsmMapStyle(this.label, this.baseUrl, this.attribution);
}

class MapPlacePickerScreen extends StatefulWidget {
  final SavedPlace? initialPlace;
  final bool isViewOnly;

  const MapPlacePickerScreen({
    super.key,
    this.initialPlace,
    this.isViewOnly = false,
  });

  @override
  State<MapPlacePickerScreen> createState() => _MapPlacePickerScreenState();
}

class _MapPlacePickerScreenState extends State<MapPlacePickerScreen> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late double _latitude;
  late double _longitude;
  String _category = 'Home';
  String _address = 'Downtown Poblacion, Davao City';
  String? _nameError;
  bool _userModifiedName = false;
  late bool _isViewMode;

  // OpenStreetMap interactive state
  bool _isDragging = false;
  bool _isLocating = false;
  bool _isMapLoading = true;
  String _loadingStatusText = 'Loading Davao Map...';
  Timer? _loadingTimer;
  int _zoomLevel = 15; // Street & building level OpenStreetMap zoom
  OsmMapStyle _activeMapStyle = OsmMapStyle.osmStandard;
  Size _viewportSize = Size.zero;

  // Rich database of Davao landmarks for automatic reverse-geocoding and auto-fill
  final List<({String name, double lat, double lng, String address, String cat, double radiusKm})> _geoFeatures = [
    (
      name: 'Downtown (Roxas Night Market)',
      lat: 7.0707,
      lng: 125.6087,
      address: 'Roxas Ave, Poblacion District, Davao City',
      cat: 'Other',
      radiusKm: 0.6,
    ),
    (
      name: 'Ateneo de Davao University',
      lat: 7.0722,
      lng: 125.6128,
      address: 'E. Jacinto St / CM Recto, Poblacion, Davao City',
      cat: 'School',
      radiusKm: 0.5,
    ),
    (
      name: 'Matina Crossing',
      lat: 7.0628,
      lng: 125.5940,
      address: 'McArthur Highway, Matina Crossing, Davao City',
      cat: 'Home',
      radiusKm: 0.7,
    ),
    (
      name: 'University of Mindanao (UM Matina)',
      lat: 7.0585,
      lng: 125.5890,
      address: 'Matina Crossing, McArthur Highway, Davao City',
      cat: 'School',
      radiusKm: 0.6,
    ),
    (
      name: 'SM City Davao (Ecoland)',
      lat: 7.0519,
      lng: 125.5936,
      address: 'Quimpo Blvd, Ecoland, Davao City',
      cat: 'Mall',
      radiusKm: 0.6,
    ),
    (
      name: 'DCOTT Bus Terminal',
      lat: 7.0540,
      lng: 125.5920,
      address: 'Candelaria St, Ecoland, Davao City',
      cat: 'Terminal',
      radiusKm: 0.4,
    ),
    (
      name: 'Bankerohan Public Market',
      lat: 7.0655,
      lng: 125.6025,
      address: 'Quirino Ave / Bolton Bridge, Davao City',
      cat: 'Terminal',
      radiusKm: 0.5,
    ),
    (
      name: 'Davao City Hall & San Pedro',
      lat: 7.0650,
      lng: 125.6080,
      address: 'San Pedro St, Poblacion District, Davao City',
      cat: 'Work',
      radiusKm: 0.5,
    ),
    (
      name: 'Davao City Library',
      lat: 7.0700,
      lng: 125.6100,
      address: 'C. Bangoy St, Poblacion District, Davao City',
      cat: 'Other',
      radiusKm: 0.4,
    ),
    (
      name: 'Abreeza Ayala Mall',
      lat: 7.0870,
      lng: 125.6120,
      address: 'JP Laurel Ave, Bajada, Davao City',
      cat: 'Mall',
      radiusKm: 0.6,
    ),
    (
      name: 'Gaisano Mall of Davao',
      lat: 7.0780,
      lng: 125.6140,
      address: 'JP Laurel Ave, Bajada, Davao City',
      cat: 'Mall',
      radiusKm: 0.5,
    ),
    (
      name: 'Victoria Plaza / NCCC VP',
      lat: 7.0840,
      lng: 125.6130,
      address: 'JP Laurel Ave, Bajada, Davao City',
      cat: 'Mall',
      radiusKm: 0.5,
    ),
    (
      name: 'SPMC Hospital',
      lat: 7.0910,
      lng: 125.6170,
      address: 'JP Laurel Ave, Bajada, Davao City',
      cat: 'Work',
      radiusKm: 0.6,
    ),
    (
      name: 'SM Lanang Premier',
      lat: 7.0970,
      lng: 125.6350,
      address: 'JP Laurel Ave, Lanang, Davao City',
      cat: 'Mall',
      radiusKm: 0.7,
    ),
    (
      name: 'Buhangin Milan',
      lat: 7.0980,
      lng: 125.6130,
      address: 'Buhangin Road, Davao City',
      cat: 'Home',
      radiusKm: 0.8,
    ),
    (
      name: 'Cabantian Country Homes',
      lat: 7.1120,
      lng: 125.6220,
      address: 'Cabantian Road, Buhangin, Davao City',
      cat: 'Home',
      radiusKm: 0.9,
    ),
    (
      name: 'Toril Terminal',
      lat: 7.0180,
      lng: 125.4980,
      address: 'Toril Public Market & Terminal, Davao City',
      cat: 'Terminal',
      radiusKm: 0.9,
    ),
    (
      name: 'Francisco Bangoy Airport',
      lat: 7.1250,
      lng: 125.6450,
      address: 'Catitipan / Airport Road, Davao City',
      cat: 'Terminal',
      radiusKm: 1.0,
    ),
    (
      name: 'Sasa Ferry Wharf',
      lat: 7.1210,
      lng: 125.6580,
      address: 'Sasa Ferry Port, Km 10, Davao City',
      cat: 'Terminal',
      radiusKm: 0.8,
    ),
    (
      name: 'Agdao Public Market',
      lat: 7.0770,
      lng: 125.6260,
      address: 'Lapu-Lapu St, Agdao, Davao City',
      cat: 'Terminal',
      radiusKm: 0.6,
    ),
    (
      name: 'Bangkal Central Corridor',
      lat: 7.0500,
      lng: 125.5700,
      address: 'McArthur Highway, Bangkal, Davao City',
      cat: 'Home',
      radiusKm: 0.8,
    ),
    (
      name: 'Mintal Green Meadows',
      lat: 7.0850,
      lng: 125.5350,
      address: 'Tugbok District, Davao City',
      cat: 'Home',
      radiusKm: 1.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _isViewMode = widget.isViewOnly;
    final init = widget.initialPlace;
    _latitude = init?.latitude ?? 7.0707;
    _longitude = init?.longitude ?? 125.6087;
    _zoomLevel = 15;
    _activeMapStyle = OsmMapStyle.osmStandard;

    final initialFeature = _findFeatureForCoordinates(_latitude, _longitude);
    _address = init?.address ?? initialFeature.address;
    _category = init?.category ?? initialFeature.cat;

    _nameController = TextEditingController(text: init?.name ?? initialFeature.name);
    _addressController = TextEditingController(text: _address);

    if (init != null) {
      _userModifiedName = true;
    }

    _nameController.addListener(() {
      if (_nameController.text.trim().isNotEmpty) {
        if (_nameError != null) {
          setState(() => _nameError = null);
        }
      }
    });

    _isMapLoading = true;
    _loadingStatusText = 'Loading Davao Map...';
    _loadingTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isMapLoading = false;
        });
      }
    });
  }

  void _triggerLoading(String statusText, [int durationMs = 400]) {
    _loadingTimer?.cancel();
    setState(() {
      _isMapLoading = true;
      _loadingStatusText = statusText;
    });
    _loadingTimer = Timer(Duration(milliseconds: durationMs), () {
      if (mounted) {
        setState(() {
          _isMapLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // --- Web Mercator (Slippy Map) Math Functions ---

  double _lngToTileX(double lng, int zoom) {
    return (lng + 180.0) / 360.0 * (1 << zoom);
  }

  double _latToTileY(double lat, int zoom) {
    final rad = lat * math.pi / 180.0;
    return (1.0 - math.log(math.tan(rad) + 1.0 / math.cos(rad)) / math.pi) / 2.0 * (1 << zoom);
  }

  double _tileXToLng(double tileX, int zoom) {
    return tileX / (1 << zoom) * 360.0 - 180.0;
  }

  double _tileYToLat(double tileY, int zoom) {
    final n = math.pi - 2.0 * math.pi * tileY / (1 << zoom);
    return 180.0 / math.pi * math.atan(0.5 * (math.exp(n) - math.exp(-n)));
  }

  String _getTileUrl(int x, int y, int z, OsmMapStyle style) {
    switch (style) {
      case OsmMapStyle.osmStandard:
        return 'https://tile.openstreetmap.de/$z/$x/$y.png';
      case OsmMapStyle.worldStreet:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/$z/$y/$x';
      case OsmMapStyle.cleanLight:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/$z/$y/$x';
    }
  }

  String _getBackupTileUrl(int x, int y, int z, OsmMapStyle style) {
    switch (style) {
      case OsmMapStyle.osmStandard:
        return 'https://a.tile.openstreetmap.fr/osmfr/$z/$x/$y.png';
      case OsmMapStyle.worldStreet:
      case OsmMapStyle.cleanLight:
        return 'https://tile.openstreetmap.de/$z/$x/$y.png';
    }
  }

  // Auto-fill fields whenever the pin lands or drops
  void _autoFillForCoordinates(double lat, double lng) {
    final feature = _findFeatureForCoordinates(lat, lng);

    setState(() {
      _latitude = lat;
      _longitude = lng;
      _address = feature.address;
      _addressController.text = feature.address;
      if (!_userModifiedName) {
        _nameController.text = feature.name;
      }
      _category = feature.cat;
      if (_nameError != null) _nameError = null;
    });
  }

  ({String name, String address, String cat}) _findFeatureForCoordinates(double lat, double lng) {
    var closestDist = double.infinity;
    var closest = _geoFeatures.first;

    for (final f in _geoFeatures) {
      // Euclidean distance in km near equator (1 deg lat ~= 110.6 km, 1 deg lng ~= 110.5 km)
      final dLat = (lat - f.lat) * 110.6;
      final dLng = (lng - f.lng) * 110.5;
      final distKm = math.sqrt(dLat * dLat + dLng * dLng);

      if (distKm < closestDist) {
        closestDist = distKm;
        closest = f;
      }
    }

    if (closestDist <= closest.radiusKm) {
      return (name: closest.name, address: closest.address, cat: closest.cat);
    } else if (closestDist <= 2.0) {
      return (
        name: 'Near ${closest.name}',
        address: 'Vicinity of ${closest.address}',
        cat: closest.cat,
      );
    }

    // Corridor fallbacks
    if (lat < 7.035 && lng < 125.530) {
      return (name: 'Toril District Spot', address: 'Toril District Corridor, Davao City', cat: 'Home');
    } else if (lat >= 7.050 && lat <= 7.075 && lng >= 125.580 && lng <= 125.600) {
      return (name: 'Matina Landmark', address: 'Matina Crossing / McArthur Highway, Davao City', cat: 'Home');
    } else if (lat >= 7.045 && lat <= 7.060 && lng >= 125.590 && lng <= 125.610) {
      return (name: 'Ecoland Spot', address: 'Ecoland / Quimpo Boulevard, Davao City', cat: 'Mall');
    } else if (lat >= 7.062 && lat <= 7.072 && lng >= 125.600 && lng <= 125.612) {
      return (name: 'Bankerohan Area', address: 'Bankerohan / Quirino Ave, Davao City', cat: 'Terminal');
    } else if (lat >= 7.068 && lat <= 7.078 && lng >= 125.605 && lng <= 125.620) {
      return (name: 'Downtown Poblacion Spot', address: 'Roxas Ave / Poblacion Downtown, Davao City', cat: 'Other');
    } else if (lat >= 7.080 && lat <= 7.095 && lng >= 125.615 && lng <= 125.630) {
      return (name: 'Bajada Commercial Hub', address: 'Bajada / JP Laurel Avenue, Davao City', cat: 'Mall');
    } else if (lat >= 7.090 && lat <= 7.120 && lng >= 125.625 && lng <= 125.650) {
      return (name: 'Lanang Corridor', address: 'Lanang / SM Lanang Corridor, Davao City', cat: 'Mall');
    } else if (lat >= 7.090 && lat <= 7.120 && lng >= 125.600 && lng <= 125.625) {
      return (name: 'Buhangin Area', address: 'Buhangin / Airport Road Corridor, Davao City', cat: 'Home');
    }

    return (
      name: 'Pinned Point',
      address: 'Davao Commuter Zone (${lat.toStringAsFixed(4)}° N, ${lng.toStringAsFixed(4)}° E)',
      cat: 'Other',
    );
  }

  void _onPanUpdate(Offset delta) {
    final currentTileX = _lngToTileX(_longitude, _zoomLevel);
    final currentTileY = _latToTileY(_latitude, _zoomLevel);

    final newTileX = currentTileX - (delta.dx / 256.0);
    final newTileY = currentTileY - (delta.dy / 256.0);

    final newLng = _tileXToLng(newTileX, _zoomLevel).clamp(-180.0000, 180.0000);
    final newLat = _tileYToLat(newTileY, _zoomLevel).clamp(-85.0000, 85.0000);

    setState(() {
      _longitude = double.parse(newLng.toStringAsFixed(5));
      _latitude = double.parse(newLat.toStringAsFixed(5));
    });
  }

  // Tap anywhere on the map to jump and drop the pin directly there (like Google Maps)
  void _handleMapTap(Offset tapPosition, double pinScreenX, double pinScreenY) {
    if (_isViewMode) return;

    final deltaX = tapPosition.dx - pinScreenX;
    final deltaY = tapPosition.dy - pinScreenY;

    setState(() {
      _isDragging = true;
    });

    final currentTileX = _lngToTileX(_longitude, _zoomLevel);
    final currentTileY = _latToTileY(_latitude, _zoomLevel);

    final newTileX = currentTileX + (deltaX / 256.0);
    final newTileY = currentTileY + (deltaY / 256.0);

    final newLng = _tileXToLng(newTileX, _zoomLevel).clamp(-180.0000, 180.0000);
    final newLat = _tileYToLat(newTileY, _zoomLevel).clamp(-85.0000, 85.0000);

    final resolvedLat = double.parse(newLat.toStringAsFixed(5));
    final resolvedLng = double.parse(newLng.toStringAsFixed(5));

    _autoFillForCoordinates(resolvedLat, resolvedLng);

    // Subtle bounce drop animation
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) {
        setState(() {
          _isDragging = false;
        });
      }
    });
  }

  Future<void> _locateUserCurrentPosition() async {
    if (_isLocating) return;

    _loadingTimer?.cancel();
    setState(() {
      _isLocating = true;
      _loadingStatusText = 'Acquiring GPS location...';
    });

    try {
      final loc = await LocationService.getCurrentLocation();
      if (!mounted) return;

      if (loc.error != null) {
        NotificationBanner.showInfo(context, loc.error!);
      } else {
        final resolvedLat = double.parse(loc.lat.toStringAsFixed(5));
        final resolvedLng = double.parse(loc.lng.toStringAsFixed(5));

        _autoFillForCoordinates(resolvedLat, resolvedLng);

        if (_zoomLevel < 15) {
          setState(() => _zoomLevel = 16);
        }

        NotificationBanner.showSuccess(
          context,
          'Pin dropped at GPS location (${resolvedLat.toStringAsFixed(4)}° N, ${resolvedLng.toStringAsFixed(4)}° E)',
        );
      }
    } catch (e) {
      if (mounted) {
        NotificationBanner.showError(context, 'Location access error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  void _changeZoom(int delta) {
    final newZoom = (_zoomLevel + delta).clamp(11, 18);
    if (newZoom == _zoomLevel) return;
    setState(() {
      _zoomLevel = newZoom;
    });
  }

  void _applyPreset(({String name, double lat, double lng, String address, String cat, double radiusKm}) preset) {
    _triggerLoading('Navigating to ${preset.name}...', 350);
    setState(() {
      _isDragging = true;
    });

    _autoFillForCoordinates(preset.lat, preset.lng);

    if (_zoomLevel < 15) {
      _zoomLevel = 15;
    }

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isDragging = false;
        });
      }
    });
  }

  void _savePlace() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _nameError = 'Please enter a name for this place';
      });
      return;
    }

    final address = _addressController.text.trim().isNotEmpty
        ? _addressController.text.trim()
        : _address;

    final state = AppStateScope.of(context);
    final place = SavedPlace(
      name: name,
      latitude: _latitude,
      longitude: _longitude,
      address: address,
      category: _category,
    );

    if (widget.initialPlace != null) {
      state.updateSavedPlaceItem(widget.initialPlace!.name, place);
      NotificationBanner.showSuccess(context, 'Updated "$name" in saved places');
    } else {
      state.addSavedPlaceItem(place);
      NotificationBanner.showSuccess(context, 'Added "$name" to saved places');
    }
    Navigator.of(context).pop();
  }

  void _deletePlace() async {
    final name = widget.initialPlace?.name ?? _nameController.text.trim();
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Saved Place',
      message: 'Are you sure you want to remove "$name" from your saved places?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      final state = AppStateScope.of(context);
      state.deleteSavedPlace(name);
      NotificationBanner.showInfo(context, 'Removed "$name" from saved places');
      Navigator.of(context).pop();
    }
  }

  static const List<String> _categories = ['Home', 'School', 'Mall', 'Work', 'Terminal', 'Other'];

  @override
  Widget build(BuildContext context) {
    final isView = _isViewMode;
    final isExisting = widget.initialPlace != null;
    final topPadding = MediaQuery.of(context).padding.top;
    final topBarHeight = topPadding + (isView ? 62.0 : 108.0);
    final bottomSheetHeight = isView ? 165.0 : 360.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF2EFE9),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. FULL-SCREEN INTERACTIVE MAP CANVAS (Google-style with live tile render)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                _viewportSize = Size(constraints.maxWidth, constraints.maxHeight);

                final visibleHeight = math.max(100.0, constraints.maxHeight - topBarHeight - bottomSheetHeight);
                final pinScreenX = constraints.maxWidth / 2;
                final pinScreenY = topBarHeight + (visibleHeight / 2);

                final centerTileX = _lngToTileX(_longitude, _zoomLevel);
                final centerTileY = _latToTileY(_latitude, _zoomLevel);

                final centerXPixels = centerTileX * 256.0;
                final centerYPixels = centerTileY * 256.0;

                final vx0 = centerXPixels - pinScreenX;
                final vy0 = centerYPixels - pinScreenY;

                final minTileX = (vx0 / 256.0).floor();
                final maxTileX = ((vx0 + _viewportSize.width) / 256.0).floor();
                final minTileY = (vy0 / 256.0).floor();
                final maxTileY = ((vy0 + _viewportSize.height) / 256.0).floor();

                final tileWidgets = <Widget>[];

                for (int tx = minTileX; tx <= maxTileX; tx++) {
                  for (int ty = minTileY; ty <= maxTileY; ty++) {
                    final left = (tx * 256.0) - vx0;
                    final top = (ty * 256.0) - vy0;
                    final tileUrl = _getTileUrl(tx, ty, _zoomLevel, _activeMapStyle);

                    tileWidgets.add(
                      Positioned(
                        left: left,
                        top: top,
                        width: 256.0,
                        height: 256.0,
                        child: Image.network(
                          tileUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.network(
                              _getBackupTileUrl(tx, ty, _zoomLevel, _activeMapStyle),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(color: const Color(0xFFF2EFE9));
                          },
                        ),
                      ),
                    );
                  }
                }

                return Listener(
                  onPointerSignal: (pointerSignal) {
                    if (pointerSignal is PointerScrollEvent) {
                      if (pointerSignal.scrollDelta.dy < 0) {
                        _changeZoom(1);
                      } else if (pointerSignal.scrollDelta.dy > 0) {
                        _changeZoom(-1);
                      }
                    }
                  },
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onDoubleTap: () => _changeZoom(1),
                    onTapUp: (details) {
                      _handleMapTap(details.localPosition, pinScreenX, pinScreenY);
                    },
                    onPanStart: (details) {
                      setState(() {
                        _isDragging = true;
                      });
                    },
                    onPanUpdate: (details) {
                      _onPanUpdate(details.delta);
                    },
                    onPanEnd: (details) {
                      setState(() {
                        _isDragging = false;
                      });
                      // Auto-fill all location fields when pin drops
                      _autoFillForCoordinates(_latitude, _longitude);
                    },
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: const Color(0xFFF2EFE9),
                      child: ClipRect(
                        child: Stack(
                          children: tileWidgets,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. THE GOOGLE MAPS CENTER PIN (Lifts when dragging, drops when released)
          Positioned(
            left: 0,
            right: 0,
            top: topBarHeight,
            bottom: bottomSheetHeight,
            child: IgnorePointer(
              child: Center(
                child: _GoogleMapsCenterPin(
                  isDragging: _isDragging,
                  placeName: _nameController.text,
                  category: _category,
                  getCategoryIcon: _getCategoryIcon,
                ),
              ),
            ),
          ),

          // 3. TOP FLOATING GOOGLE MAPS SEARCH BAR & PRESET PILLS
          Positioned(
            top: topPadding + 10,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floating Search Capsule
                Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(27),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(28),
                        blurRadius: 14,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.deepGreen),
                        tooltip: 'Back',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isView
                                  ? 'Pinned Place'
                                  : (isExisting ? 'Edit Saved Place' : 'Drop Pin on Map'),
                              style: const TextStyle(
                                color: AppColors.deepGreen,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              isView
                                  ? 'Saved location • Tap Edit to modify'
                                  : (isExisting
                                      ? 'Move map or tap anywhere to relocate'
                                      : 'Tap anywhere to drop pin & auto-fill'),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (isView)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.mainGreen, size: 20),
                          tooltip: 'Edit place',
                          onPressed: () => setState(() => _isViewMode = false),
                        )
                      else if (isExisting)
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.coral, size: 20),
                          tooltip: 'Delete place',
                          onPressed: _deletePlace,
                        ),
                      // Layer Switcher
                      PopupMenuButton<OsmMapStyle>(
                        initialValue: _activeMapStyle,
                        tooltip: 'Map Layers',
                        icon: const Icon(Icons.layers_outlined, color: AppColors.mainGreen),
                        onSelected: (style) {
                          if (style == _activeMapStyle) return;
                          _triggerLoading('Switching to ${style.label}...', 450);
                          setState(() {
                            _activeMapStyle = style;
                          });
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: OsmMapStyle.osmStandard,
                            child: Row(
                              children: [
                                Icon(Icons.map_rounded, size: 18, color: AppColors.mainGreen),
                                SizedBox(width: 10),
                                Text('OpenStreetMap (Full Detail)'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: OsmMapStyle.worldStreet,
                            child: Row(
                              children: [
                                Icon(Icons.alt_route_rounded, size: 18, color: AppColors.deepGreen),
                                SizedBox(width: 10),
                                Text('Detailed Street Map (Esri/OSM)'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: OsmMapStyle.cleanLight,
                            child: Row(
                              children: [
                                Icon(Icons.wb_sunny_outlined, size: 18, color: Colors.grey),
                                SizedBox(width: 10),
                                Text('Clean Light Gray'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Floating Horizontal Landmark Presets
                if (!isView)
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _geoFeatures.length + 1,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return InkWell(
                            onTap: _locateUserCurrentPosition,
                            borderRadius: BorderRadius.circular(18),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: _isLocating ? AppColors.surfaceMint : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppColors.mainGreen,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.mainGreen.withAlpha(25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_isLocating)
                                    const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.mainGreen,
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.near_me_rounded,
                                      size: 13,
                                      color: AppColors.mainGreen,
                                    ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _isLocating ? 'Locating...' : 'My Location',
                                    style: const TextStyle(
                                      color: AppColors.deepGreen,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final preset = _geoFeatures[index - 1];
                        final isCurrent = (_latitude - preset.lat).abs() < 0.005 && (_longitude - preset.lng).abs() < 0.005;

                        return InkWell(
                          onTap: () => _applyPreset(preset),
                          borderRadius: BorderRadius.circular(18),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: isCurrent ? AppColors.mainGreen : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isCurrent ? AppColors.mainGreen : AppColors.border,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(isCurrent ? 25 : 12),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getCategoryIcon(preset.cat),
                                  size: 13,
                                  color: isCurrent ? Colors.white : AppColors.mainGreen,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  preset.name,
                                  style: TextStyle(
                                    color: isCurrent ? Colors.white : AppColors.deepGreen,
                                    fontSize: 12,
                                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // 4. FLOATING ACTION CONTROLS ON RIGHT EDGE (Google Maps Zoom & Center)
          Positioned(
            right: 16,
            bottom: bottomSheetHeight + 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _GoogleMapActionButton(
                  icon: _isLocating ? Icons.hourglass_top_rounded : Icons.my_location_rounded,
                  tooltip: 'My Current Location (GPS)',
                  iconColor: _isLocating ? AppColors.coral : AppColors.mainGreen,
                  onTap: _locateUserCurrentPosition,
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(22),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_rounded, color: AppColors.deepGreen, size: 20),
                        tooltip: 'Zoom In',
                        onPressed: () => _changeZoom(1),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMint,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'z$_zoomLevel',
                          style: const TextStyle(
                            color: AppColors.deepGreen,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_rounded, color: AppColors.deepGreen, size: 20),
                        tooltip: 'Zoom Out',
                        onPressed: () => _changeZoom(-1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 5. GOOGLE MAPS BOTTOM DETAIL SHEET WITH AUTO-FILLED FIELDS
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 18,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top drag handle bar
                      Center(
                        child: Container(
                          width: 36,
                          height: 4.5,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),

                      // Location Header with auto-fill pill
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFECEB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.location_on_rounded, color: AppColors.coral, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _address,
                                        style: const TextStyle(
                                          color: AppColors.deepGreen,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          height: 1.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE2F7EB),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.check_circle_rounded, size: 11, color: Color(0xFF165B47)),
                                          SizedBox(width: 3),
                                          Text(
                                            'Auto-filled',
                                            style: TextStyle(
                                              color: Color(0xFF165B47),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${_latitude.toStringAsFixed(4)}° N, ${_longitude.toStringAsFixed(4)}° E • Davao Commuter Zone',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (!isView) ...[
                        const SizedBox(height: 14),

                        // Auto-filled Place Name Input Field
                        TextField(
                          controller: _nameController,
                          onChanged: (_) {
                            _userModifiedName = true;
                            if (_nameError != null) setState(() => _nameError = null);
                          },
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.deepGreen),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            labelText: 'Place Name (Auto-filled from Pin)',
                            hintText: 'e.g. My Home, Ateneo, Abreeza Mall',
                            errorText: _nameError,
                            prefixIcon: const Icon(Icons.bookmark_outline_rounded, size: 20, color: AppColors.mainGreen),
                            filled: true,
                            fillColor: AppColors.surfaceMint.withAlpha(120),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.mainGreen, width: 1.8)),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Auto-filled Address Input Field
                        TextField(
                          controller: _addressController,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF374151)),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            labelText: 'Address / Landmark (Auto-filled)',
                            hintText: 'e.g. Roxas Ave, Poblacion District, Davao City',
                            prefixIcon: const Icon(Icons.place_outlined, size: 20, color: AppColors.coral),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.mainGreen, width: 1.8)),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Category Tag Selection Row
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _categories.map((cat) {
                            final isSel = _category.toLowerCase() == cat.toLowerCase();

                            return ChoiceChip(
                              label: Text(cat),
                              avatar: Icon(
                                _getCategoryIcon(cat),
                                size: 13,
                                color: isSel ? Colors.white : AppColors.deepGreen,
                              ),
                              selected: isSel,
                              onSelected: (selected) {
                                if (selected) setState(() => _category = cat);
                              },
                              selectedColor: AppColors.mainGreen,
                              backgroundColor: AppColors.surfaceMint,
                              labelStyle: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                color: isSel ? Colors.white : AppColors.deepGreen,
                              ),
                              side: BorderSide(
                                color: isSel ? AppColors.mainGreen : AppColors.border,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 16),

                        if (isExisting) ...[
                          // Action buttons for Edit Mode (Update Place + Delete)
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _savePlace,
                                  icon: const Icon(Icons.check_rounded, size: 20),
                                  label: const Text(
                                    'Update Place',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(0, 48),
                                    backgroundColor: AppColors.mainGreen,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton.icon(
                                onPressed: _deletePlace,
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.coral),
                                label: const Text(
                                  'Delete',
                                  style: TextStyle(color: AppColors.coral, fontWeight: FontWeight.w700),
                                ),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 48),
                                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Save Pinned Place Button for Add Mode
                          ElevatedButton.icon(
                            onPressed: _savePlace,
                            icon: const Icon(Icons.bookmark_add_rounded, size: 20),
                            label: const Text(
                              'Save Pinned Place',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor: AppColors.mainGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 1,
                            ),
                          ),
                        ],
                      ] else ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => setState(() => _isViewMode = false),
                                icon: const Icon(Icons.edit_rounded, size: 18),
                                label: const Text(
                                  'Edit Place',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                ),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(0, 46),
                                  backgroundColor: AppColors.mainGreen,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back_rounded, size: 18),
                              label: const Text('Back'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 46),
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 6. LOADING SCREEN & SWITCHING OVERLAY
          if (_isMapLoading || _isLocating)
            Positioned.fill(
              child: Container(
                color: const Color(0xFFF2EFE9).withAlpha(210),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceMint,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.8,
                                color: AppColors.mainGreen,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _loadingStatusText,
                          style: const TextStyle(
                            color: AppColors.deepGreen,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Updating OpenStreetMap street tiles...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'mall':
        return Icons.storefront_rounded;
      case 'work':
        return Icons.business_center_rounded;
      case 'terminal':
        return Icons.directions_bus_rounded;
      default:
        return Icons.place_rounded;
    }
  }
}

class _GoogleMapActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color iconColor;
  final VoidCallback onTap;

  const _GoogleMapActionButton({
    required this.icon,
    required this.tooltip,
    this.iconColor = AppColors.deepGreen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(22),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 20),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }
}

class _GoogleMapsCenterPin extends StatelessWidget {
  final bool isDragging;
  final String placeName;
  final String category;
  final IconData Function(String) getCategoryIcon;

  const _GoogleMapsCenterPin({
    required this.isDragging,
    required this.placeName,
    required this.category,
    required this.getCategoryIcon,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = isDragging
        ? 'Adjusting pin...'
        : (placeName.trim().isNotEmpty ? placeName.trim() : 'Pinned Location');

    return SizedBox(
      width: 160,
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 1. Precision Ground Reticle Ring & Center Dot
          Positioned(
            bottom: 42,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.coral.withAlpha(35),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.coral, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.coral.withAlpha(55),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.coral,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: isDragging ? 12 : 24,
                  height: isDragging ? 4 : 6,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(isDragging ? 25 : 75),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),

          // 2. Google Maps Signature Teardrop Pin & Floating Badge (Lifts up on drag)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            bottom: isDragging ? 76 : 60, // Lifts 16px on drag, lands exactly on reticle
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floating Callout Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.deepGreen,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(45),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        getCategoryIcon(category),
                        color: Colors.white,
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),

                // Teardrop Pin
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 46,
                      color: Color(0xFFE53935), // Google Maps signature red
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 11,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
