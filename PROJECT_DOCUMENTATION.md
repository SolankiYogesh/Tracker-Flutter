# Tracker Project Documentation

Welcome to the **Tracker** project documentation. This document is designed to help new developers understand the architecture, logic flow, and core functionalities of the application.

---

## 🏗 Architecture Overview

The application follows a clean, modular structure with a focus on local-first data persistence and background processing.

### Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: 
    - `Provider`: For global app state (Auth, Theme, Entities).
    - `fquery`: For server-state management and periodic polling (Nearby Users, Leaderboard).
- **Local Database**: `sqflite` (SQLite) for offline data persistence.
- **Networking**: `dio` with custom interceptors for logging.
- **Backend Services**: Firebase (Auth) + Custom API (Location sync, Entities).
- **Background Tasks**: `background_location_tracker` for continuous tracking even when the app is closed.

---

## 📁 Directory Structure

```text
lib/
├── constants/          # Centralized app constants and config
├── data/               # Local data handling (if any static)
├── models/             # Data models for API and DB
├── network/            # API repositories and query logic
│   ├── repositories/   # Abstracted API calls
│   └── api_queries.dart # fquery definitions
├── providers/          # ChangeNotifier providers for state
├── router/             # GoRouter or Custom Router logic
├── screens/            # UI Screens
│   ├── main/           # Core feature screens
│   └── auth/           # Login and onboarding
├── services/           # Long-running services (DB, Notifications, Repo)
├── theme/              # App themes (Light/Dark)
└── utils/              # Helper functions and Logger
```

---

## 🕹 Core Logic & Functionality

### 1. Authentication
- **Path**: `lib/providers/auth_service_provider.dart` & `lib/network/repositories/auth_repository.dart`
- Uses **Firebase Authentication** (Google Sign-in) for identity.
- Syncs user profile with the custom backend after a successful login.
- User data is cached locally in SQLite (`app_user` table) for offline access.

### 2. Background Location Tracking
- **Path**: `lib/main.dart` & `lib/services/repo.dart`
- **Initialisation**: Started in `main.dart` using `BackgroundLocationTrackerManager`.
- **Callback**: `backgroundCallback` (running in a separate isolate) receives location updates.
- **Persistence**: Updates are handled by the `Repo` singleton, which:
    1. Filters updates by accuracy.
    2. Saves the point to the `locations` table.
    3. Checks for nearby "Entities" (items) to collect.
    4. Triggers periodic sync to the server.

### 3. Location Synchronization (Local-to-Server)
- **Path**: `lib/services/repo.dart` -> `_syncLocations()`
- A periodic timer (default 30s) batches unsynced locations from the `locations` table.
- Points are sent as a `LocationBatch` to the `/points/batch` endpoint.
- Upon success, points are marked as `is_synced = 1` in the local DB.

### 4. Map & Smoothing Logic
- **Path**: `lib/screens/main/maps/map_screen.dart`
- **Polyline Rendering**: Draws the user's path by reading local location history.
- **Smoothing**: Uses a **Catmull-Rom Spline** algorithm to turn raw GPS points into smooth curves.
- **Segments**: Logic exists to split polylines if points are too far apart (handling "teleportation" or gaps in tracking).
- **Tile Caching**: Uses `flutter_map_tile_caching` to ensure maps work without internet.

### 5. Entity Collection System
- **Path**: `lib/providers/entity_provider.dart` & `lib/services/repo.dart`
- Entities (items/loot) are spawned by the server and cached locally in the `entities` table.
- **Proximity Check**: When new location data arrives (in foreground or background), the app checks if the user is within the `spawnRadius` of any uncollected entity.
- **Collection**: If within range, it hits the `collectEntity` API.
- **Animation**: Foreground collection triggers a `CollectionAnimationOverlay` with a custom Lottie or image sequence.

### 6. Stats & Step Counting
- **Path**: `lib/screens/main/stats/stats_screen.dart`
- **Steps**: Uses the `pedometer` plugin. It handles device reboots by storing the "last boot step count" in SQLite and calculating the delta.
- **Distance**: Calculated mathematically by summing distances between all historical points in the local DB, with filtering for GPS noise (accuracy/speed thresholds).

### 7. Permissions Handling
- **Path**: `lib/screens/main/permissions/permission_screen.dart`
- Uses `permission_handler` to manage critical requirements:
    - **Location (Always)**: Essential for background tracking.
    - **Activity Recognition**: Used for the pedometer.
    - **Notifications**: Required to maintain a foreground service for location tracking on Android.
- **Flow**: The app checks status on startup. If any required permission is missing, it redirects to the `PermissionScreen`. Once all are granted, it proceeds to the main application.

---

## 🗄 Database Schema (SQLite)

- `app_user`: Id, email, name, picture.
- `locations`: Lat, lon, timestamp, accuracy, bearing, speed, is_synced.
- `app_settings`: Theme preference.
- `entities`: Spatially indexed items for collection.
- `user_stats`: Persistent step counter.

---

## 🛠 Setup & Development

### Environment Variables
Create a `.env` file in the root directory:
```env
BASE_URL=https://your-api.com/api
# Add other keys...
```

### Key Commands
- `flutter pub get`: Fetch dependencies.
- `flutter run`: Run the application.
- `flutter build apk`: Generate production APK.

---

## 📝 Troubleshooting & Logging
The app uses the `talker` package for logging.
- Routes are observed via `TalkerRouteObserver`.
- Network calls are logged via `TalkerDioLogger`.
- Open the Talker Monitor (if implemented) or check the console for detailed debug logs.
