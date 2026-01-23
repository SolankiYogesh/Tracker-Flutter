# Interval Process Timeline & Documentation

This document outlines all the periodic, interval-based, and background processes currently running in the **GeoPulsify** application. It details *what* happens, *when* it happens, *why* it happens, and *where* the code is located.

## 1. Background Processes

These processes run even when the application is minimized or the screen is off (provided the OS doesn't kill the service).

### 1.1. Background Location Tracking
*   **Interval:** Every **5 seconds**
*   **Location:** `lib/main.dart` (Configuration) & `BackgroundLocationTrackerManager` (Plugin)
*   **Key Code:**
    ```dart
    // lib/main.dart
    trackingInterval: Duration(seconds: 5)
    distanceFilterMeters: 5
    ```
*   **What happens:**
    The native platform (Android/iOS) wakes up the app's background service to request the device's GPS coordinates.
*   **Why:**
    To ensure a smooth "perfect track" of the user's movement history.
*   **Flow:**
    1.  OS triggers update.
    2.  `backgroundCallback` in `main.dart` is executed.
    3.  Checks if `horizontalAccuracy < 50`.
    4.  Calls `repo.update(data)` in `lib/services/repo.dart`.
    5.  **Filtering:** `Repo._shouldSaveLocation` applies logic (speed check, distance check, jitter filter) to decide if the point is worthy of saving.
    6.  **Storage:** If valid, the point is saved to the local SQLite database via `DatabaseHelper().insertLocation()`.

### 1.2. Background Entity Collection Check
*   **Interval:** **Event-Driven** (Triggered on every valid location update, approx. every 5 seconds)
*   **Location:** `lib/services/repo.dart` -> `update` -> `_checkEntityCollection`
*   **Key Code:**
    ```dart
    // lib/services/repo.dart
    _checkEntityCollection(data, user.id);
    ```
*   **What happens:**
    Immediately after receiving a new background location (and before saving it), the app queries the local database for uncollected entities.
*   **Logic:**
    1.  **Query:** Finds uncollected entities within approx. 500 meters (`range = 0.005` degrees) of the user.
    2.  **Check:** Loop through entities and calculate distance.
    3.  **Collect:** If `distance <= entity.spawnRadius` (which usually defaults to around **50 meters** depending on the specific entity configuration):
        *   Triggers API call: `_entityRepository.collectEntity`.
        *   Sends a local notification: "Collected [Entity Name]! You earned [XP] XP".
        *   Updates the local database to mark it as collected.
*   **Why:**
    To allow users to "play" the game and collect items while walking with the phone in their pocket, without needing the screen on.

### 1.3. Location Sync to Backend
*   **Interval:** Every **30 seconds**
*   **Location:** `lib/services/repo.dart` -> `_startSyncTimer`
*   **Constant:** `AppConstants.locationSyncInterval`
*   **Key Code:**
    ```dart
    // lib/services/repo.dart
    Timer.periodic(AppConstants.locationSyncInterval, (_) => _syncLocations());
    ```
*   **What happens:**
    The app checks the local database for any location points that haven't been uploaded yet (`isSynced = 0`).
*   **Why:**
    To batch upload user movement data to the server instead of spamming an API request every 5 seconds. This saves battery and data usage.
*   **Flow:**
    1.  `_syncLocations` is called.
    2.  Query `DatabaseHelper().getUnsyncedLocations()`.
    3.  If data exists, wraps it in `LocationBatch`.
    4.  Sends POST request to Backend via `_locationRepository.uploadBatch`.
    5.  On success, marks those specific IDs as synced in the local DB.

---

## 2. Foreground Processes (UI Active)

These processes only run when the application is open and the specific screen is active.

### 2.1. Map Path & Entity Refresh
*   **Interval:** Every **5 seconds**
*   **Location:** `lib/screens/main/maps/map_screen.dart` -> `initState`
*   **Constant:** `AppConstants.mapRefreshInterval`
*   **Key Code:**
    ```dart
    // lib/screens/main/maps/map_screen.dart
    Timer.periodic(AppConstants.mapRefreshInterval, (_) => _refreshLocations());
    ```
*   **What happens:**
    The map screen re-reads the location history from the local database and redraws the polyline (route). It also checks for collectible entities nearby.
*   **Why:**
    To verify that the line drawn on the map reflects the latest data captured by the background service, and to detect if the user has walked into the range of a collectible item.
*   **Flow:**
    1.  `_refreshLocations` is called.
    2.  **Path:** Fetches all points from DB -> Smooths them (`MapUtils.makeSmooth`) -> Updates `_polylines`.
    3.  **Foreground Collection Check:** Calls `EntityProvider.checkProximityAndCollect`.
        *   Checks if distance to any entity <= `spawnRadius` (e.g. 50m).
        *   If yes, collects it (failsafe if background service didn't catch it yet or for immediate UI feedback).
    4.  **Animation:** Calls `EntityProvider.checkForNewCollections` to see if a background collection happened recently (to trigger the "Got Item!" animation).

### 2.2. Nearby Users Refresh
*   **Interval:** Every **30 seconds**
*   **Location:** `lib/screens/main/maps/map_screen.dart` -> `QueryBuilder`
*   **Constant:** `AppConstants.nearbyUsersRefreshInterval`
*   **Key Code:**
    ```dart
    // lib/screens/main/maps/map_screen.dart
    QueryOptions(
      refetchInterval: AppConstants.nearbyUsersRefreshInterval,
      ...
    )
    ```
*   **What happens:**
    The app polls the API for other users' locations.
*   **Why:**
    To show "live" movement of other players on the map without needing real-time sockets (polling is used for simplicity).

### 2.3. New Entity Fetch from Server
*   **Interval:** Every **50 seconds**
*   **Location:** `lib/providers/entity_provider.dart` -> `startPeriodicFetch`
*   **Constant:** `AppConstants.entityFetchInterval`
*   **Key Code:**
    ```dart
    // lib/providers/entity_provider.dart
    Timer.periodic(AppConstants.entityFetchInterval, (_) => fetchNearbyEntities(userId));
    ```
*   **What happens:**
    The app asks the server: "Are there any new collectibles generated near my current location?"
*   **Why:**
    To dynamically spawn new items (coins, chests, monsters) around the user as they walk, keeping the gameplay infinite.
*   **Flow:**
    1.  `fetchNearbyEntities` is called.
    2.  Gets last known location from DB.
    3.  Calls `_repo.fetchAndSaveNearbyEntities` (API Request).
    4.  Server returns list of entities.
    5.  Entities are saved to local DB.
    6.  `_loadLocalEntities` updates the `_nearbyEntities` list which the Map Screen uses to draw markers.

### 2.4. Stats Screen Refresh
*   **Interval:** Every **5 seconds**
*   **Location:** `lib/screens/main/stats/stats_screen.dart` -> `initState`
*   **Constant:** `AppConstants.statsRefreshInterval`
*   **Key Code:**
    ```dart
    // lib/screens/main/stats/stats_screen.dart
    Timer.periodic(AppConstants.statsRefreshInterval, (_) => _refreshStats());
    ```
*   **What happens:**
    Recalculates total distance and steps.
*   **Why:**
    To show the user live feedback on their walking stats as they move, referencing the latest data committed to the database.

---

## 3. Event-Driven & Other Triggers

### 3.1. Pedometer (Step Counter)
*   **Interval:** **Real-time** (Sensor Event)
*   **Location:** `lib/screens/main/stats/stats_screen.dart`
*   **Source:** `Pedometer.stepCountStream`
*   **What happens:**
    Listens to the phone's hardware step sensor.
*   **Why:**
    To get the most accurate step count possible without relying on GPS distance estimation.

### 3.2. Query Cache Staling
*   **Interval:** **30 seconds** (Stale Duration)
*   **Location:** `lib/main.dart` -> `queryCache`
*   **What happens:**
    API responses (like User Profile, XP, Leaderboard) are cached. After 30s, they are marked "stale".
*   **Why:**
    To prevent fetching data too often when switching screens, but ensuring data isn't older than 30 seconds when the user returns to a screen.

---

## Summary View

| Process | Interval | Foreground/Background | Responsible Component |
| :--- | :--- | :--- | :--- |
| **GPS Fix & Entity Check** | 5 sec | **Background** | `BackgroundLocationTracker` -> `Repo` |
| **Map Redraw & Entity Check** | 5 sec | Foreground | `MapScreen` |
| **Stats Calc** | 5 sec | Foreground | `StatsScreen` |
| **Sync Location** | 30 sec | **Background** | `Repo` |
| **Nearby Users** | 30 sec | Foreground | `MapScreen` (Query) |
| **Fetch New Entities**| 50 sec | Foreground | `EntityProvider` |
