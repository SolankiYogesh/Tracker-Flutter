class AppConstants {
  // ===========================================================================
  // LOCATION & SYNC CONFIGURATION
  // ===========================================================================

  /// Interval at which offline/background locations are synced to the backend.
  ///
  /// Usage: Used in `Repo._startSyncTimer`.
  /// Effect: Increasing this value reduces frequent network calls but delays
  /// data availability on the server. Decreasing it improves real-time sync
  /// but may consume more battery and data.
  static const Duration locationSyncInterval = Duration(seconds: 45);

  /// Number of decimal places to use when storing or displaying latitude/longitude.
  ///
  /// Usage: Used in `Repo.update` and `Repo._locationPointToString`.
  /// Effect: 5 decimal places provide accuracy up to ~1.1 meters, which is
  /// sufficient for most tracking needs. Lowering this reduces precision;
  /// increasing it adds negligible precision for consumer GPS.
  static const int coordinatePrecision = 5;

  // ===========================================================================
  // MAP CONFIGURATION
  // ===========================================================================

  /// Default zoom level for the map when the user centers on their location.
  ///
  /// Usage: Used in `MapScreen._makeSmooth` and `MapScreen._recenter`.
  /// Effect: Controls how close the camera is to the ground. Higher values (e.g., 18)
  /// zoom in closer; lower values (e.g., 10) show a wider area.
  static const double defaultMapZoom = 15.0;

  /// Minimum zoom level to prevent showing multiple world maps when zooming out.
  static const double minMapZoom = 3.0;

  /// Maximum zoom level to prevent zooming in too far.
  static const double maxMapZoom = 18.0;

  /// Interval for refreshing the local path (polylines) and foreground entities on the map.
  ///
  /// Usage: Used in `MapScreen.initState`.
  /// Effect: Controls how strictly the UI follows the database updates.
  /// A shorter duration makes the path appear more "live" but consumes more CPU
  /// for redrawing the map.
  static const Duration mapRefreshInterval = Duration(seconds: 5);

  /// Interval for fetching and refreshing "Nearby Users" on the map.
  ///
  /// Usage: Used in `MapScreen.initState` for the `_nearbyTimer`.
  /// Effect: Determines how often we check for other users.
  static const Duration nearbyUsersRefreshInterval = Duration(seconds: 45);

  /// Maximum distance (in meters) between two points to consider them part of the same segment.
  ///
  /// Usage: Used in `MapScreen._refreshLocations`.
  /// Effect: If the gap between two recorded points is larger than this (e.g., GPS signal lost
  /// and regained far away), a new separate line segment is started instead of connecting them.
  static const double polylineSegmentMaxDistance = 100.0;

  /// The number of subdivisions to add between points when smoothing the route line.
  ///
  /// Usage: Used in `MapScreen._makeSmooth` (Catmull-Rom spline calculation).
  /// Effect: Higher values result in smoother, curvier lines but increase the number
  /// of points the map has to render, potentially impacting performance.
  static const int splineSegmentSubdivisions = 10;

  /// The time window (in hours) for displaying location history on the map.
  ///
  /// Usage: Used in `MapScreen._refreshLocations` to prune old points.
  /// Effect: Only location points recorded within this many hours ago are shown.
  /// Reducing this improves performance (less points to process/render); increasing
  /// it shows more historical context but may cause UI lag if point density is high.
  static const int mapHistoryWindowHours = 24;

  // ===========================================================================
  // NETWORK CONFIGURATION
  // ===========================================================================

  /// Minimum distance (in meters) the user must move to trigger a new entity fetch.
  ///
  /// Usage: Used in `EntityProvider.fetchNearbyEntities` for smart invalidation.
  /// Effect: If the user hasn't moved at least this far since the last fetch,
  /// we skip the API call to save data/battery, as the nearby entities likely haven't changed.
  /// This prevents redundant calls when standing still.
  static const double entityFetchMinDistance = 100.0;

  /// Maximum time to wait for the server to establish a connection.
  ///
  /// Usage: Used in `DioClient`.
  /// Effect: If the server doesn't accept the connection within this time, the request fails.
  static const Duration apiConnectTimeout = Duration(seconds: 15);

  /// Maximum time to wait for the server to send the response data.
  ///
  /// Usage: Used in `DioClient`.
  /// Effect: If the response is not received within this time after connection, the request fails.
  static const Duration apiReceiveTimeout = Duration(seconds: 15);

  /// Interval for fetching new game entities (e.g., collectibles) from the server.
  ///
  /// Usage: Used in `EntityProvider.startPeriodicFetch`.
  /// Effect: Controls how often the app checks for new items around the user.
  static const Duration entityFetchInterval = Duration(seconds: 45);

  /// Maximum number of users to fetch for the leaderboard.
  ///
  /// Usage: Used in `EntityProvider.fetchLeaderboard`.
  /// Effect: Limits the size of the leaderboard list to manage UI performance and data usage.
  static const int leaderboardLimit = 50;

  /// Radius (in meters) within which entities are visible on the map around the user.
  ///
  /// Usage: Used in `MapScreen` to filter entities.
  /// Effect: Entities outside this radius will be hidden to prevent clutter
  /// and improve performance.
  static const double entityVisibilityRadius = 3000.0;

  // ===========================================================================
  // NOTIFICATION CONFIGURATION
  // ===========================================================================

  /// Unique ID for the persistent background tracking notification.
  ///
  /// Usage: Used in `notification.dart` (init and send).
  /// Effect: Must be unique to avoid conflict with other notifications.
  static const int notificationIdTracking = 879848645;

  /// Channel ID for the tracking notification (Android-specific).
  ///
  /// Usage: Used in `notification.dart`.
  /// Effect: Groups notifications in system settings. Changing this after release
  /// may duplicate channels on user devices.
  static const String notificationChannelIdTracking = 'tracking_channel';

  // ===========================================================================
  // STATS & FILTERING CONFIGURATION
  // ===========================================================================

  /// Interval for refreshing the data on the Stats screen.
  ///
  /// Usage: Used in `StatsScreen.initState`.
  /// Effect: Determines how "live" the step count and distance updates appear.
  static const Duration statsRefreshInterval = Duration(seconds: 5);

  /// Minimum accuracy (in meters) required for a GPS point to be included in stats.
  ///
  /// Usage: Used in `StatsScreen._calculateDistance`.
  /// Effect: Points with accuracy radius larger than this (e.g., 50m) are considered
  /// too noisy and are ignored to prevent "drifting" distance when standing still.
  static const double gpsMinAccuracyThreshold = 30.0;

  /// Maximum realistic speed (in meters/second) allowed between points.
  /// 28 m/s is approx 100 km/h.
  ///
  /// Usage: Used in `StatsScreen._calculateDistance`.
  /// Effect: Prevents GPS "teleports" or massive jumps from inflating the total distance.
  static const double gpsMaxSpeedMps = 28.0;

  /// Maximum distance (in meters) to consider "negligible" if time difference is zero.
  ///
  /// Usage: Used in `StatsScreen._calculateDistance`.
  /// Effect: If two points have the exact same timestamp but are further apart than this,
  /// it's considered an error/jump and ignored.
  static const double gpsMaxInstantJump = 5.0;

  // ===========================================================================
  // LOCATION FILTERING CONFIGURATION
  // ===========================================================================

  /// Minimum accuracy (in meters) required to accept a location update.
  ///
  /// Usage: Used in `Repo._shouldSaveLocation`.
  /// Effect: Any location update with a horizontal accuracy radius larger than this
  /// will be immediately rejected as "too noisy". This prevents large jumps due to
  /// poor GPS signal (e.g., inside buildings).
  static const double minLocationAccuracy = 20.0;

  /// Speed threshold (in meters/second) below which the user is considered stationary.
  ///
  /// Usage: Used in `Repo._shouldSaveLocation` to switch to stricter distance checks.
  /// Effect: 0.5 m/s is approx 1.8 km/h. If speed is below this, we assume the user
  /// is not effectively moving, so we apply `minStationaryDistance` to filter out stationary jitter.
  static const double minStationarySpeed = 0.5;

  /// Minimum distance (in meters) required to trigger a save when the user is stationary.
  ///
  /// Usage: Used in `Repo._shouldSaveLocation` when speed < `minStationarySpeed`.
  /// Effect: When standing still, GPS can "wander" a few meters. We ignore these small
  /// displacements (jitter). Only if the "wander" exceeds this threshold do we record it.
  static const double minStationaryDistance = 20.0;

  /// Minimum distance (in meters) required to trigger a save when the user is moving significantly.
  ///
  /// Usage: Used in `Repo._shouldSaveLocation`.
  /// Effect: If the user has moved at least this much since the last saved point,
  /// we accept the point regardless of time elapsed (fast movement).
  static const double minMovingDistance = 20.0;

  /// Lower distance threshold (in meters) to accept if enough time has passed.
  ///
  /// Usage: Used in `Repo._shouldSaveLocation` in conjunction with `minSignificantTime`.
  /// Effect: Allows recording slower, steady movements. If the user moves only 10m
  /// but it took 5 seconds, we record it to capture the path detail.
  static const double minSignificantDistance = 10.0;

  /// Time threshold (in seconds) to accept smaller distance updates.
  ///
  /// Usage: Used in `Repo._shouldSaveLocation` in conjunction with `minSignificantDistance`.
  /// Effect: Ensures we don't record tiny movements too frequently, but allows
  /// capturing detail (`minSignificantDistance`) if this much time has passed.
  static const int minSignificantTime = 5;
}
