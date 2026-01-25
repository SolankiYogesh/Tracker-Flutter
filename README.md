# 📍 GeoPulsify - Intelligent Location & Activity App

[![Flutter](https://img.shields.io/badge/Flutter-SDK%20%5E3.10.4-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Auth-orange.svg)](https://firebase.google.com/)
[![SQLite](https://img.shields.io/badge/SQLite-Offline--First-green.svg)](https://sqlite.org/)

**GeoPulsify** is a high-performance Flutter application designed for precise location tracking, activity monitoring, and interactive map experiences. Whether you're tracking your daily routes or collecting virtual entities, GeoPulsify provides a seamless, offline-first experience.

## ✨ Key Features

-   **🚀 Background Tracking**: High-accuracy location tracking even when the app is in the background or the device is locked.
-   **🗺️ Interactive Map**: Real-time map visualization with smoothed path rendering (Catmull-Rom Splines) and intelligent segmenting.
-   **🎒 Entity Collection**: Discover and collect virtual items scattered across the map as you move.
-   **📊 Activity Stats**: Precise step counting (with reboot resilience) and GPS-denoised distance calculation.
-   **🌙 Dynamic Theming**: Beautiful Dark and Light modes with persistent user preferences.
-   **☁️ Cloud Sync**: Automatic background synchronization of local data to the server when internet is available.
-   **📶 Offline First**: Complete map tile caching and local SQLite persistence for zero-connectivity environments.

## 🛠️ Tech Stack

-   **Framework**: Flutter (Dart)
-   **State Management**: `Provider` (Global State) & `fquery` (Server State/Polling)
-   **Maps**: `flutter_map` with `flutter_map_tile_caching`
-   **Database**: SQLite (`sqflite`) for local persistence
-   **Auth**: Firebase (Google & Apple Sign-In)
-   **Networking**: `dio` with remote API batch synchronization
-   **Services**: `background_location_tracker`, `pedometer`, `flutter_local_notifications`

## 📖 Documentation

We maintain detailed documentation for developers:

-   [**📘 Project Documentation**](project_specifications/PROJECT_DOCUMENTATION.md): Deep dive into Architecture, Logic Flows, Directory Structure, and Database Schema.
-   [**📏 Coding Standards**](project_specifications/CODING_STANDARDS.md): Strict guidelines on architecture, naming conventions, constants, and best practices.
-   [**⏱️ Internal Process Timeline**](project_specifications/INTERVAL_TIMELINE.md): Detailed breakdown of all background intervals, timers, and periodic tasks (Sync, Refresh, Polling).

## 🚀 Getting Started

### Prerequisites

-   Flutter SDK (^3.10.4)
-   A Firebase Project (for Auth)
-   A `.env` file for API configuration

### Installation

1.  **Clone the repository**:

    ```bash
    git clone https://github.com/SolankiYogesh/Tracker-Flutter.git
    cd tracker
    ```

2.  **Setup environment variables**:
    Create a `.env` file in the root and add your configuration:

    ```env
    BASE_URL=https://api.example.com
    ```

3.  **Install dependencies**:

    ```bash
    flutter pub get
    ```

4.  **Initialize Firebase**:
    Ensure you have configured `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).

5.  **Run the app**:

    ```bash
    flutter run
    ```

## ⚙️ Configuration

Core settings can be tweaked in `lib/constants/app_constants.dart`:

-   `locationSyncInterval`: Speed of cloud syncing.
-   `gpsMinAccuracyThreshold`: Filtering threshold for GPS noise.
-   `mapRefreshInterval`: Smoothness of UI updates.

## 🤝 Contributing

We welcome contributions! Please feel free to submit a Pull Request.

---

Developed by **Yogesh Solanki**
