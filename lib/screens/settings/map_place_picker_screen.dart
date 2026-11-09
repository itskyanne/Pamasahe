import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../models/saved_place.dart';
import '../../services/location_service.dart';
import '../../state/app_scope.dart';
import '../../theme/app_colors.dart';
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
  late double _latitude;
  late double _longitude;
  String _category = 'Home';
  String _address = 'Downtown Poblacion, Davao City';
  String? _nameError;

  // OpenStreetMap interactive state
  bool _isDragging = false;
  bool _isLocating = false;
  int _zoomLevel = 14; // Street & building level OpenStreetMap zoom (11 to 18)
  OsmMapStyle _activeMapStyle = OsmMapStyle.osmStandard;
  Size _viewportSize = Size.zero;

  final List<({String name, double lat, double lng, String address, String cat})> _davaoPresets = [
    (
      name: 'Downtown (Roxas)',
      lat: 7.0707,
      lng: 125.6087,
      address: 'Roxas Ave, Poblacion District, Davao City',
      cat: 'School',
    ),
    (
      name: 'Matina Crossing',
      lat: 7.0628,
      lng: 125.5940,
      address: 'McArthur Highway, Matina Crossing, Davao City',
      cat: 'Home',
    ),
    (
      name: 'Ecoland (SM City)',
      lat: 7.0519,
      lng: 125.5936,
      address: 'Quimpo Blvd, Ecoland, Davao City',
      cat: 'Mall',
    ),
    (
      name: 'Bankerohan Market',
      lat: 7.0655,
      lng: 125.6025,
      address: 'Quirino Ave / Bolton Bridge, Davao City',
      cat: 'Terminal',
    ),
    (
      name: 'Buhangin Milan',
      lat: 7.0980,
      lng: 125.6130,
      address: 'Buhangin Road, Davao City',
      cat: 'Home',
    ),
    (
      name: 'Lanang (SM Lanang)',
      lat: 7.0970,
      lng: 125.6350,
      address: 'JP Laurel Ave, Lanang, Davao City',
      cat: 'Mall',
    ),
    (
      name: 'Toril Terminal',
      lat: 7.0180,
      lng: 125.4980,
      address: 'Toril Public Market & Terminal, Davao City',
      cat: 'Terminal',
    ),
    (
      name: 'Abreeza (Bajada)',
      lat: 7.0870,
      lng: 125.6120,
      address: 'JP Laurel Ave, Bajada, Davao City',
      cat: 'Mall',
    ),
    (
      name: 'Airport (F. Bangoy)',
      lat: 7.1250,
      lng: 125.6450,
      address: 'Catitipan / Airport Road, Davao City',
      cat: 'Terminal',
    ),
    (
      name: 'Sasa Wharf',
      lat: 7.1210,
      lng: 125.6580,
      address: 'Sasa Ferry Port, Davao City',
      cat: 'Terminal',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final init = widget.initialPlace;
    _nameController = TextEditingController(text: init?.name ?? '');
    _latitude = init?.latitude ?? 7.0640;
    _longitude = init?.longitude ?? 125.6000;
    _zoomLevel = 14;
    _activeMapStyle = OsmMapStyle.osmStandard;
    _category = init?.category ?? 'Home';
    _address = init?.address ?? _findNearestAddress(_latitude, _longitude);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // --- OpenStreetMap Web Mercator (Slippy Map) Math Functions ---

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

  void _onPanUpdate(Offset delta) {
    // 1 pixel delta movement in global tile space
    final currentTileX = _lngToTileX(_longitude, _zoomLevel);
    final currentTileY = _latToTileY(_latitude, _zoomLevel);

    final newTileX = currentTileX - (delta.dx / 256.0);
    final newTileY = currentTileY - (delta.dy / 256.0);

    final newLng = _tileXToLng(newTileX, _zoomLevel).clamp(-180.0000, 180.0000);
    final newLat = _tileYToLat(newTileY, _zoomLevel).clamp(-85.0000, 85.0000);

    setState(() {
      _longitude = double.parse(newLng.toStringAsFixed(5));
      _latitude = double.parse(newLat.toStringAsFixed(5));
      _address = _findNearestAddress(_latitude, _longitude);
    });
  }

  Future<void> _locateUserCurrentPosition() async {
    if (_isLocating) return;

    setState(() {
      _isLocating = true;
    });

    try {
      final loc = await LocationService.getCurrentLocation();
      if (!mounted) return;

      if (loc.error != null) {
        NotificationBanner.showInfo(context, loc.error!);
      } else {
        setState(() {
          _latitude = double.parse(loc.lat.toStringAsFixed(5));
          _longitude = double.parse(loc.lng.toStringAsFixed(5));
          _address = _findNearestAddress(_latitude, _longitude);
          if (_zoomLevel < 15) {
            _zoomLevel = 16;
          }
        });
        NotificationBanner.showSuccess(
          context,
          'GPS location detected: ${_latitude.toStringAsFixed(4)}° N, ${_longitude.toStringAsFixed(4)}° E',
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

  void _applyPreset(({String name, double lat, double lng, String address, String cat}) preset) {
    setState(() {
      _latitude = preset.lat;
      _longitude = preset.lng;
      _address = preset.address;
      _category = preset.cat;
      if (_zoomLevel < 14) {
        _zoomLevel = 15;
      }
      if (_nameController.text.trim().isEmpty) {
        _nameController.text = preset.name;
      }
    });
  }

  String _findNearestAddress(double lat, double lng) {
    for (final p in _davaoPresets) {
      if ((p.lat - lat).abs() < 0.008 && (p.lng - lng).abs() < 0.008) {
        return p.address;
      }
    }

    if (lat < 7.035 && lng < 125.530) {
      return 'Toril District Corridor, Davao City';
    } else if (lat >= 7.050 && lat <= 7.075 && lng >= 125.580 && lng <= 125.600) {
      return 'Matina Crossing / McArthur Highway, Davao City';
    } else if (lat >= 7.045 && lat <= 7.060 && lng >= 125.590 && lng <= 125.610) {
      return 'Ecoland / Quimpo Boulevard, Davao City';
    } else if (lat >= 7.062 && lat <= 7.072 && lng >= 125.600 && lng <= 125.612) {
      return 'Bankerohan / Quirino Ave, Davao City';
    } else if (lat >= 7.068 && lat <= 7.078 && lng >= 125.605 && lng <= 125.620) {
      return 'Roxas Ave / Poblacion Downtown, Davao City';
    } else if (lat >= 7.080 && lat <= 7.095 && lng >= 125.615 && lng <= 125.630) {
      return 'Bajada / JP Laurel Avenue, Davao City';
    } else if (lat >= 7.090 && lat <= 7.120 && lng >= 125.625 && lng <= 125.650) {
      return 'Lanang / SM Lanang Corridor, Davao City';
    } else if (lat >= 7.090 && lat <= 7.120 && lng >= 125.600 && lng <= 125.625) {
      return 'Buhangin / Airport Road Corridor, Davao City';
    } else if (lng > 125.635) {
      return 'Davao Coastal / Port Zone, Davao City';
    }

    return 'Current GPS Location (${lat.toStringAsFixed(4)}° N, ${lng.toStringAsFixed(4)}° E)';
  }

  void _savePlace() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _nameError = 'Please enter a name for this place';
      });
      return;
    }

    final state = AppStateScope.of(context);
    final newPlace = SavedPlace(
      name: name,
      latitude: _latitude,
      longitude: _longitude,
      address: _address,
      category: _category,
    );

    state.addSavedPlaceItem(newPlace);
    NotificationBanner.showSuccess(context, 'Location pinned: "$name" added to saved places');
    Navigator.of(context).pop();
  }

  static const List<String> _categories = ['Home', 'School', 'Mall', 'Work', 'Terminal', 'Other'];

  @override
  Widget build(BuildContext context) {
    final isView = widget.isViewOnly;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomSheetHeight = isView ? 140.0 : 260.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF2EFE9), // OSM land background
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. FULL-SCREEN INTERACTIVE OPENSTREETMAP CANVAS (Full bleed)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                _viewportSize = Size(constraints.maxWidth, constraints.maxHeight);

                // Center coordinates optimized for Google Maps layout (above the bottom sheet)
                final centerScreenX = _viewportSize.width / 2;
                final centerScreenY = math.max(120.0, (_viewportSize.height - bottomSheetHeight) / 2 + 10);

                final centerTileX = _lngToTileX(_longitude, _zoomLevel);
                final centerTileY = _latToTileY(_latitude, _zoomLevel);

                final centerXPixels = centerTileX * 256.0;
                final centerYPixels = centerTileY * 256.0;

                final vx0 = centerXPixels - centerScreenX;
                final vy0 = centerYPixels - centerScreenY;

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

                return Stack(
                  children: [
                    // Draggable Tile Surface
                    Listener(
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
                    ),

                    // Google Maps Dropped Pin (stays precisely pinned at centerScreenX, centerScreenY)
                    IgnorePointer(
                      child: Positioned(
                        left: centerScreenX,
                        top: centerScreenY,
                        child: SizedBox(
                          width: 0,
                          height: 0,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              // Ground target shadow (shrinks and softens when lifted)
                              Positioned(
                                top: -3,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: _isDragging ? 12 : 22,
                                  height: _isDragging ? 5 : 8,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(_isDragging ? 30 : 70),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),

                              // Ground pinpoint reticle dot
                              Positioned(
                                top: -3,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: AppColors.coral,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black26, blurRadius: 2),
                                    ],
                                  ),
                                ),
                              ),

                              // Pin and Callout Bubble that lifts up smoothly on drag
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 160),
                                curve: Curves.easeOutCubic,
                                bottom: _isDragging ? 18 : 0,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Floating callout badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.deepGreen,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(50),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getCategoryIcon(_category),
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            _isDragging
                                                ? 'Locating...'
                                                : (_nameController.text.trim().isNotEmpty
                                                    ? _nameController.text.trim()
                                                    : 'Dropped Pin'),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 2),

                                    // Teardrop Icon
                                    const Icon(
                                      Icons.location_on_rounded,
                                      size: 42,
                                      color: AppColors.coral,
                                      shadows: [
                                        Shadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // 2. TOP FLOATING GOOGLE MAPS SEARCH BAR & HEADER
          Positioned(
            top: topPadding + 10,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floating Search Capsule
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
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
                              isView ? 'Pinned Location' : 'Pin Desired Location',
                              style: const TextStyle(
                                color: AppColors.deepGreen,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              isView ? 'OpenStreetMap view' : 'Drag map or select a quick hub below',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Layer Switcher Popup Menu
                      PopupMenuButton<OsmMapStyle>(
                        initialValue: _activeMapStyle,
                        tooltip: 'Map Layers',
                        icon: const Icon(Icons.layers_outlined, color: AppColors.mainGreen),
                        onSelected: (style) {
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

                // Floating Horizontal Landmark Presets (Google Maps Category Pills)
                if (!isView)
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _davaoPresets.length + 1,
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

                        final preset = _davaoPresets[index - 1];
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

          // 3. FLOATING ACTION CONTROLS ON RIGHT EDGE (Google Maps Style)
          Positioned(
            right: 16,
            bottom: bottomSheetHeight + 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Re-Center / GPS Location Button
                _GoogleMapActionButton(
                  icon: _isLocating ? Icons.hourglass_top_rounded : Icons.my_location_rounded,
                  tooltip: 'My Current Location (GPS)',
                  iconColor: _isLocating ? AppColors.coral : AppColors.mainGreen,
                  onTap: _locateUserCurrentPosition,
                ),
                const SizedBox(height: 10),

                // Connected Zoom Capsule (+, z indicator, -)
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

          // 4. FLOATING DRAG HINT PILL
          if (_isDragging)
            Positioned(
              top: topPadding + 115,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.deepGreen.withAlpha(235),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 8),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Move map to position pin',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 5. GOOGLE MAPS BOTTOM DETAIL SHEET (Clean, Organized, Elegant)
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
                    color: Colors.black.withAlpha(22),
                    blurRadius: 18,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtle top drag handle bar
                    Center(
                      child: Container(
                        width: 36,
                        height: 4.5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),

                    // Location Title & Coordinates Header
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
                              Text(
                                _address,
                                style: const TextStyle(
                                  color: AppColors.deepGreen,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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

                      // Modern Place Name Input Field
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.deepGreen),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          hintText: 'Place name (e.g. My Home, UM Matina, Abreeza)',
                          errorText: _nameError,
                          prefixIcon: const Icon(Icons.bookmark_outline_rounded, size: 20, color: AppColors.mainGreen),
                          filled: true,
                          fillColor: AppColors.surfaceMint.withAlpha(120),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.mainGreen, width: 1.8)),
                        ),
                        onChanged: (_) {
                          if (_nameError != null) setState(() => _nameError = null);
                        },
                      ),

                      const SizedBox(height: 12),

                      // Category Tag Selection Row (Clean pills)
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

                      // Primary Google Maps Style Action Button
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
                    ] else ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text('Back to Saved Places'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          backgroundColor: AppColors.deepGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ],
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
