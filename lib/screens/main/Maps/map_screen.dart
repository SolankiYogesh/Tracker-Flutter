import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tracker/services/database_helper.dart';
import 'package:fquery_core/fquery_core.dart';

import 'package:tracker/models/nearby_user.dart';
import 'package:tracker/providers/auth_service_provider.dart';
import 'package:tracker/providers/entity_provider.dart';
import 'package:tracker/models/entity_model.dart' as model;

import 'package:tracker/constants/app_constants.dart';
import 'package:tracker/utils/app_logger.dart';
import 'package:fquery/fquery.dart';
import 'package:tracker/network/api_queries.dart';
import 'collection_animation_overlay.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

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
  Timer? _timer;
  bool _hasInitiallyCentered = false;
  bool _shouldFollowUser = true;
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
            // Show snackbar after a delay or let animation handle it
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
    // Also refresh entities from DB as the background service might have collected some
    if (mounted) {
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
      smoothedSegments.add(_makeSmooth(segment));
    }

    setState(() {
      _polylines = smoothedSegments;
      if (points.isNotEmpty) {
        _currentLocation = LatLng(points.last.latitude, points.last.longitude);

        if (_shouldFollowUser && _currentLocation != null) {
          _mapController.move(_currentLocation!, _mapController.camera.zoom);
        } else if (!_hasInitiallyCentered && _currentLocation != null) {
          _mapController.move(_currentLocation!, AppConstants.defaultMapZoom);
          _hasInitiallyCentered = true;
        }
      }
    });
  }

  List<LatLng> _makeSmooth(List<LatLng> points) {
    if (points.length < 3) return points;
    List<LatLng> spline = [];
    // Catmull-Rom Spline
    // We add duplicate first and last points for control
    List<LatLng> padded = [points.first, ...points, points.last];

    for (int i = 0; i < padded.length - 3; i++) {
      LatLng p0 = padded[i];
      LatLng p1 = padded[i + 1];
      LatLng p2 = padded[i + 2];
      LatLng p3 = padded[i + 3];

      // 10 points per segment for smoothness
      for (int t = 0; t <= AppConstants.splineSegmentSubdivisions; t++) {
        double tNorm = t / AppConstants.splineSegmentSubdivisions.toDouble();
        double t2 = tNorm * tNorm;
        double t3 = t2 * tNorm;

        double f0 = -0.5 * t3 + t2 - 0.5 * tNorm;
        double f1 = 1.5 * t3 - 2.5 * t2 + 1.0;
        double f2 = -1.5 * t3 + 2.0 * t2 + 0.5 * tNorm;
        double f3 = 0.5 * t3 - 0.5 * t2;

        double lat =
            p0.latitude * f0 +
            p1.latitude * f1 +
            p2.latitude * f2 +
            p3.latitude * f3;
        double lon =
            p0.longitude * f0 +
            p1.longitude * f1 +
            p2.longitude * f2 +
            p3.longitude * f3;
        spline.add(LatLng(lat, lon));
      }
    }
    return spline;
  }

  void _recenter() {
    if (_currentLocation != null) {
      setState(() {
        _shouldFollowUser = true;
      });
      _mapController.move(_currentLocation!, AppConstants.defaultMapZoom);
    }
  }

  void _showUserInfo(NearbyUser user) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 45,
              backgroundImage: user.picture != null
                  ? CachedNetworkImageProvider(user.picture!)
                  : null,
              child: user.picture == null
                  ? const Icon(Icons.person, size: 45)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.name ?? 'Unknown User',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.place, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        '${user.distanceMeters.toStringAsFixed(0)}m away',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Active ${_timeAgo(user.lastUpdated)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _openDirections(user.latitude, user.longitude),
                icon: const Icon(Icons.directions_outlined),
                label: const Text(
                  'Get Directions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEntityInfo(model.Entity entity) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.transparent,
              backgroundImage: entity.entityType?.iconUrl != null
                  ? CachedNetworkImageProvider(entity.entityType!.iconUrl!)
                  : null,
              child: entity.entityType?.iconUrl == null
                  ? const Icon(Icons.extension, size: 45)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              entity.entityType?.name ?? 'Unknown Item',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              entity.entityType?.description ?? 'Discover this item on the map',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${entity.xpValue} XP',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () =>
                    _openDirections(entity.latitude, entity.longitude),
                icon: const Icon(Icons.directions_outlined),
                label: const Text(
                  'Get Directions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDirections(double lat, double lng) async {
    final Uri googleMapsUrl = Uri.parse('google.navigation:q=$lat,$lng');
    final Uri appleMapsUrl = Uri.parse(
      'https://maps.apple.com/?daddr=$lat,$lng',
    );
    final Uri fallbackUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl);
      } else {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      AppLogger.log('Error launching maps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open map directions')),
        );
      }
    }
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    final entities = context.watch<EntityProvider>().nearbyEntities;

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
                userAgentPackageName: 'com.baazinfotech.tracktor',
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
              // Nearby Entities Markers (drawn before users so users are on top)
              MarkerLayer(
                markers: entities
                    .map(
                      (entity) => Marker(
                        point: LatLng(entity.latitude, entity.longitude),
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () => _showEntityInfo(entity),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              entity.entityType?.iconUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: entity.entityType!.iconUrl!,
                                      width: 50,
                                      height: 50,
                                      errorWidget: (c, e, s) => const Icon(
                                        Icons.extension,
                                        color: Colors.purple,
                                        size: 40,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.extension,
                                      color: Colors.purple,
                                      size: 40,
                                    ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),

              // Current User Marker
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              // Nearby Users Markers
              if (context.watch<AuthServiceProvider>().userId != null)
                QueryBuilder<List<NearbyUser>, Exception>(
                  options: QueryOptions(
                    queryKey: QueryKey([
                      ApiQueries.nearbyUsersKey,
                      context.watch<AuthServiceProvider>().userId,
                    ]),
                    queryFn: () => ApiQueries.fetchNearbyUsers(
                      context.read<AuthServiceProvider>().userId!,
                    ),
                    refetchInterval: AppConstants.nearbyUsersRefreshInterval,
                  ),
                  builder: (context, query) {
                    final nearbyUsers = query.data ?? [];
                    return MarkerLayer(
                      markers: nearbyUsers
                          .map(
                            (user) => Marker(
                              point: LatLng(user.latitude, user.longitude),
                              width: 40,
                              height: 40,
                              child: GestureDetector(
                                onTap: () => _showUserInfo(user),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    backgroundImage: user.picture != null
                                        ? CachedNetworkImageProvider(
                                            user.picture!,
                                          )
                                        : null,
                                    child: user.picture == null
                                        ? const Icon(Icons.person, size: 24)
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
            ],
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              onPressed: _recenter,
              child: const Icon(Icons.my_location),
            ),
          ),

          if (_currentCollection != null)
            CollectionAnimationOverlay(
              collection: _currentCollection!,
              onAnimationComplete: () {
                setState(() {
                  _currentCollection = null;
                });
                // Show snackbar after animation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Collected ${_currentCollection?.entityType?.name ?? 'Item'}!",
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
