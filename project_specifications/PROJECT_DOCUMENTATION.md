# GeoPulsify Project Documentation

Welcome to the **GeoPulsify** project documentation. This document serves as the comprehensive technical guide for the application, detailing its architecture, directory structure, core logic flows, and feature implementations.

---

## 🏗 Architecture Overview

GeoPulsify is a Flutter-based location-tracking and gamified exploration application. It is primarily **offline-first**, relying on a local SQLite database for immediate data access, with background synchronization to a remote backend.

### Tech Stack

-   **Framework**: Flutter (Dart)
-   **State Management**:
    -   `Provider`: Global application state (Authentication, Theme, Entity Logic).
    -   `fquery`: Data fetching, caching, and background polling (Leaderboards, XP, Nearby Users, Collections).
-   **Local Persistence**: `sqflite` (SQLite) for storing user profile, location logs, entities, and stats.
-   **Networking**:
    -   `dio`: HTTP client with interceptors for logging and error handling.
    -   `talker`: Advanced logging and debugging.
-   **Services**:
    -   `background_location_tracker`: Dedicated isolate-based background GPS tracking.
    -   `flutter_local_notifications`: Interactive notifications for tracking status and game events.
    -   `pedometer`: Hardware step counting.
-   **Maps**: `flutter_map` with `flutter_map_tile_caching` for offline map capability.

> **Note**: For a detailed breakdown of all timers, intervals, and polling frequencies mentioned in this document, please refer to the [**Interval Timeline**](INTERVAL_TIMELINE.md).

---

## 📁 Directory Structure

```text
lib/
├── constants/          # App-wide constants (AppConstants, AppColors)
├── data/               # Static data assets
├── models/             # Data classes (Entity, LocationPoint, UserResponse, etc.)
├── network/            # Networking layer
│   ├── repositories/   # API abstraction (Auth, Entity, Location, User)
│   ├── api_queries.dart# fquery definitions for reusable queries
│   └── dio_client.dart # Dio configuration
├── providers/          # ChangeNotifier classes for global state
│   ├── auth_service_provider.dart
│   ├── entity_provider.dart
│   └── theme_provider.dart
├── router/             # Navigation logic (AppRouter, MainNavigationScreen)
├── screens/            # UI Components grouped by feature
│   ├── auth/           # LoginScreen (Animations & Auth logic)
│   └── main/
│       ├── achievements/# AchievementsScreen (XP & Collection History)
│       ├── leaderboard/ # LeaderboardScreen (Rankings)
│       ├── maps/        # MapScreen (Main map, Polylines, Markers)
│       │   └── widgets/ # Specific map overlays (AnimationOverlay, Markers)
│       ├── permissions/ # PermissionScreen (Wizard-style request flow)
│       ├── settings/    # SettingsScreen & Sub-screens
│       │   ├── about/
│       │   ├── data_storage/
│       │   ├── help_support/
│       │   └── privacy_security/
│       └── stats/       # StatsScreen (Pedometer & Distance)
├── services/           # Service Layer
│   ├── auth/           # AuthGate (Route Guard)
│   ├── database_helper.dart # SQLite Singleton
│   ├── notification.dart    # Local Notifications Logic
│   └── repo.dart            # Central Repository for Location/Entity Logic
├── theme/              # AppTheme & Color Definitions
└── utils/              # Utility classes (Logger, Responsive, TimeUtils)
```

---

## 🕹 Core Logic & Functionality

### 1. Authentication & Session Management
-   **Implementation**: `AuthServiceProvider` wraps `AuthRepository`.
-   **Features**:
    -   Supports **Google** and **Apple** Sign-In via Firebase Auth.
    -   **Sync**: Upon successful Firebase login, a backend user account is created/synced via `UserCreate` API.
    -   **Persistence**: User profile is cached in the `app_user` SQLite table for offline availability.
    -   **Guard**: `AuthGate` prevents access to main screens until authenticated *and* permissions are granted.

### 2. User Profile & Settings
-   **Edit Profile**:
    -   Implemented in `EditProfileScreen`.
    -   Allows updating `username`, `phone_number`, `gender`, `birthdate`, and `social_media_links`.
    -   Includes validation for unique usernames (handled via 409 Conflict) and phone number formatting.
-   **Social Integration**:
    -   `UserInfoSheet` displays social icons (Instagram, YouTube, etc.) for nearby users.
    -   Uses `url_launcher` to open external profile links.

### 2. Permissions System
-   **Flow**: Regulated by `PermissionScreen`.
-   **Requirements**: Location (When In Use), Location (Always), Activity Recognition (Android), Notifications.
-   **Logic**: The user must grant all required permissions sequentially before entering the `MainNavigationScreen`.

### 3. Background Location Tracking
-   **Manager**: `BackgroundLocationTrackerManager` (Plugin) + `Repo` (Service).
-   **Cycle**:
    1.  **OS Trigger**: Location update received (approx every 5s).
    2.  **Isolate Callback**: `backgroundCallback` in `main.dart` is invoked.
    3.  **Filtration (Repo)**: `Repo._shouldSaveLocation` filters noise based on:
        -   Accuracy (>20m rejected).
        -   Stationary Jitter (Speed < 0.5m/s & Dist < 20m ignored).
        -   Teleportation (Speed > 28m/s rejected).
    4.  **Persistence**: Valid points are saved to `locations` table (`is_synced = 0`).
    5.  **Sync**: `Repo` runs a 45s periodic timer to batch upload unsynced points to `/locations/batch`.

### 4. Entity Collection (The "Game")
-   **Concept**: Users collect physical "Entities" by walking near them.
-   **Background Check**:
    -   During every valid location update in `Repo`, `_checkEntityCollection` runs.
    -   It queries the DB for uncollected entities within range (`spawnRadius`).
    -   If valid, it calls the `collectEntity` API, sends a local notification, and updates the local DB (`markEntityAsCollected`).
-   **Foreground Animation**:
    -   `EntityProvider` listens to `Repo` streams.
    -   When a collection occurs, it pushes an event to `MapScreen`, triggering the `CollectionAnimationOverlay` (flying icon + XP).
-   **Spawning**: `EntityProvider` polls `/entities/nearby` every 50s to populate the local map with new items.

### 5. Map & Visualization
-   **Implementation**: `MapScreen` using `flutter_map`.
-   **Polylines**:
    -   Draws historical path from local DB.
    -   **Smoothing**: Applies Catmull-Rom spline algorithm (`MapUtils.makeSmooth`) for visual fluidity.
    -   **Segmentation**: Breaks lines if distance > 100m (gap detection).
-   **Markers**:
    -   **User**: `UserLocationMarker` with bearing.
    -   **Entities**: Interactive icons for collectibles.
    -   **Nearby Users**: Polled every 30s via `ApiQueries.fetchNearbyUsers`, displaying other players on the map.

### 6. Gamification Screens
-   **Achievements**: Displays current Level, Total XP, and a scrollable history (`ListView`) of all collected items.
-   **Leaderboard**: Shows top 3 players on a visual podium and the rest in a list. Data is cached and managed by `fquery`.

### 7. Stats & Pedometer
-   **Implementation**: `StatsScreen`.
-   **Sources**:
    -   **Steps**: `pedometer` plugin (stream). Handles device reboots by comparing against `last_boot_step_count` in DB.
    -   **Distance**: Calculated purely from valid GPS points in `locations` table (not step-based estimation).

---

## 🗄 Database Schema (SQLite)

The `DatabaseHelper` manages `location_tracker.db` (Version 4).

### Tables

1.  **`app_user`**
    -   Stores the currently logged-in user profile.
    -   Columns: `id`, `email`, `name`, `picture`, `created_at`, `updated_at`.

2.  **`locations`**
    -   The core log of user movement.
    -   Columns: `id`, `user_id`, `latitude`, `longitude`, `recorded_at`, `accuracy`, `altitude`, `speed`, `bearing`, `is_synced` (0/1).
    -   Indexes: `(user_id, recorded_at)`, `(is_synced)`.

3.  **`entities`**
    -   Cache of game items around the user.
    -   Columns: `id`, `entity_type_id`, `latitude`, `longitude`, `spawn_radius`, `xp_value`, `is_collected`, `collected_at`, `type_name`, `type_icon_url`, `type_rarity`.

4.  **`user_stats`**
    -   Persistent counter for steps preventing reset on app restart.
    -   Columns: `id` (Always 1), `total_steps`, `last_boot_step_count`, `last_updated_at`.

5.  **`app_settings`**
    -   Stores basic preferences.
    -   Columns: `isDark` (Theme).

---

## 🛠 Configuration

### Environment Variables (.env)
Required keys for the application to function:
```env
BASE_URL=https://your-api.com/api/v1  # API Endpoint
# Add Maps/Firebase keys if externalized
```

### Constants
Centralized in `lib/constants/app_constants.dart`:
-   `locationSyncInterval`: 45s
-   `entityFetchInterval`: 45s
-   `nearbyUsersRefreshInterval`: 45s
-   `mapRefreshInterval`: 5s
-   `gpsMinAccuracyThreshold`: 30.0m

---
