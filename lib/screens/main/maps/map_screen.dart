import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tracker/utils/responsive_utils.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:provider/provider.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:fquery/fquery.dart';
import 'package:fquery_core/fquery_core.dart';

import 'package:tracker/services/database_helper.dart';
import 'package:tracker/models/nearby_user.dart';
import 'package:tracker/providers/auth_service_provider.dart';
import 'package:tracker/providers/entity_provider.dart';
import 'package:tracker/models/entity_model.dart' as model;
import 'package:tracker/constants/app_constants.dart';
import 'package:tracker/utils/app_logger.dart';
import 'package:tracker/utils/map_utils.dart';
import 'package:tracker/utils/time_utils.dart';
import 'package:tracker/network/api_queries.dart';

import 'widgets/collection_animation_overlay.dart';
import 'widgets/user_location_marker.dart';
import 'widgets/nearby_user_marker.dart';
import 'widgets/entity_marker.dart';
import 'widgets/entity_info_sheet.dart';
import 'widgets/user_info_sheet.dart';
import 'widgets/map_controls.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _tileProvider = FMTCTileProvider(
    stores: const {'mapStore': BrowseStoreStrategy.readUpdateCreate},
  );
  final MapController _mapController = MapController();
  List<List<LatLng>> _polylines = [];
  LatLng? _currentLocation;
  double? _currentBearing;
  Timer? _timer;
  bool _hasInitiallyCentered = false;
  bool _shouldFollowUser = true;
  String _currentActivity = 'UNKNOWN';
  model.Collection? _currentCollection;
  StreamSubscription<model.Collection>? _collectionSubscription;

  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _refreshLocations();

    // Refresh local path every 5 seconds
    _timer = Timer.periodic(
      AppConstants.mapRefreshInterval,
      (_) => _refreshLocations(),
    );

    // Listen for collection events from Provider (Foreground)
    _collectionSubscription = context
        .read<EntityProvider>()
        .onCollectionComplete
        .listen((collection) {
          if (mounted) {
            setState(() {
              _currentCollection = collection;
            });
          }
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final userId = context.watch<AuthServiceProvider>().userId;
      if (userId != null) {
        _isInit = true;
        AppLogger.log(
          'MapScreen: Initializing EntityProvider for user $userId',
        );
        context.read<EntityProvider>().init(userId);
      } else {
        AppLogger.log('MapScreen: Waiting for userId...');
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _collectionSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _refreshLocations() async {
    final points = await DatabaseHelper().getLocations();
    // Poll activity status
    String activity = 'UNKNOWN';
    try {
      activity = await DatabaseHelper().getActivityStatus();
    } catch (e) {
      if (mounted) AppLogger.error('MapScreen: Failed to get activity', e);
    }

    if (mounted) {
      setState(() {
        _currentActivity = activity;
      });

      final provider = context.read<EntityProvider>();
      // 1. Refresh from DB (sync with background)
      await provider.refreshEntitiesFromDb();

      // 2. Check for foreground collection if we have a location
      final user = await DatabaseHelper().getCurrentUser();
      if (points.isNotEmpty && user != null) {
        // 2. Check for foreground collection
        await provider.checkProximityAndCollect(
          points.last.latitude,
          points.last.longitude,
          user.id,
        );
        // 3. Poll for any collections (bg or fg) to trigger animation
        await provider.checkForNewCollections(user.id);
      }
    }

    if (points.isEmpty) return;

    List<List<LatLng>> segments = [];
    List<LatLng> currentSegment = [];

    for (int i = 0; i < points.length; i++) {
      final p = LatLng(points[i].latitude, points[i].longitude);

      if (currentSegment.isEmpty) {
        currentSegment.add(p);
      } else {
        final lastPoint = currentSegment.last;
        final distance = const Distance().as(LengthUnit.Meter, lastPoint, p);

        if (distance > AppConstants.polylineSegmentMaxDistance) {
          segments.add(currentSegment);
          currentSegment = [p];
        } else {
          currentSegment.add(p);
        }
      }
    }
    if (currentSegment.isNotEmpty) {
      segments.add(currentSegment);
    }

    // 2. Smooth segments
    List<List<LatLng>> smoothedSegments = [];
    for (var segment in segments) {
      smoothedSegments.add(MapUtils.makeSmooth(segment));
    }

    setState(() {
      _polylines = smoothedSegments;
      if (points.isNotEmpty) {
        _currentLocation = LatLng(points.last.latitude, points.last.longitude);
        _currentBearing = points.last.bearing;

        if (_shouldFollowUser && _currentLocation != null) {
          _mapController.move(_currentLocation!, _mapController.camera.zoom);
        } else if (!_hasInitiallyCentered && _currentLocation != null) {
          _mapController.move(_currentLocation!, AppConstants.defaultMapZoom);
          _hasInitiallyCentered = true;
        }
      }
    });
  }

  void _recenter() {
    if (_currentLocation != null) {
      setState(() {
        _shouldFollowUser = true;
      });
      _mapController.move(_currentLocation!, AppConstants.defaultMapZoom);
    }
  }

  void _handleOpenDirections(double lat, double lng) async {
    try {
      await MapUtils.openDirections(lat, lng);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open map directions')),
        );
      }
    }
  }

  void _showUserInfo(NearbyUser user) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserInfoSheet(
        user: user,
        onDirectionTap: _handleOpenDirections,
        timeAgoFormatter: TimeUtils.timeAgo,
      ),
    );
  }

  void _showEntityInfo(model.Entity entity) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EntityInfoSheet(
        entity: entity,
        onDirectionTap: _handleOpenDirections,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entities = context.watch<EntityProvider>().nearbyEntities;
    final userId = context.watch<AuthServiceProvider>().userId;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(0, 0),
              initialZoom: AppConstants.defaultMapZoom,
              minZoom: AppConstants.minMapZoom,
              maxZoom: AppConstants.maxMapZoom,
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(
                  const LatLng(-90, -180),
                  const LatLng(90, 180),
                ),
              ),
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _shouldFollowUser = false;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                tileProvider: _tileProvider,
                urlTemplate: Theme.of(context).brightness == Brightness.dark
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: Theme.of(context).brightness == Brightness.dark
                    ? const ['a', 'b', 'c', 'd']
                    : const ['a', 'b', 'c'],
                userAgentPackageName: 'in.timetrix.geopulsify',
              ),
              PolylineLayer(
                polylines: _polylines
                    .map(
                      (points) => Polyline(
                        points: points,
                        strokeWidth: 4.0,
                        color: Colors.lightBlue,
                      ),
                    )
                    .toList(),
              ),
              // Nearby Entities Markers
              MarkerLayer(
                markers: entities
                    .map(
                      (entity) => Marker(
                        point: LatLng(entity.latitude, entity.longitude),
                        width: context.w(50),
                        height: context.w(50),
                        child: EntityMarker(
                          entity: entity,
                          onTap: () => _showEntityInfo(entity),
                        ),
                      ),
                    )
                    .toList(),
              ),

              if (userId != null)
                QueryBuilder<List<NearbyUser>, Exception>(
                  options: QueryOptions(
                    queryKey: QueryKey([ApiQueries.nearbyUsersKey, userId]),
                    queryFn: () => ApiQueries.fetchNearbyUsers(userId),
                    refetchInterval: AppConstants.nearbyUsersRefreshInterval,
                  ),
                  builder: (context, query) {
                    final nearbyUsers = query.data ?? [];
                    return MarkerLayer(
                      markers: nearbyUsers
                          .map(
                            (user) => Marker(
                              point: LatLng(user.latitude, user.longitude),
                              width: context.w(40),
                              height: context.w(40),
                              child: NearbyUserMarker(
                                user: user,
                                onTap: () => _showUserInfo(user),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),

              // Current User Marker
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: context.w(60),
                      height: context.w(60),
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).removeCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Current Activity: $_currentActivity'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: UserLocationMarker(bearing: _currentBearing),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          MapControls(onRecenter: _recenter),

          if (_currentCollection != null)
            CollectionAnimationOverlay(
              collection: _currentCollection!,
              onAnimationComplete: () {
                final collectedName =
                    _currentCollection?.entityType?.name ?? 'Item';
                setState(() {
                  _currentCollection = null;
                });
                // Show snackbar after animation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Collected $collectedName!')),
                );
              },
            ),
        ],
      ),
    );
  }
}
