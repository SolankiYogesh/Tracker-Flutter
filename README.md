# 📍 Tracker - Intelligent Location & Activity App

[![Flutter](https://img.shields.io/badge/Flutter-SDK%20%5E3.10.4-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Auth-orange.svg)](https://firebase.google.com/)
[![SQLite](https://img.shields.io/badge/SQLite-Offline--First-green.svg)](https://sqlite.org/)

**Tracker** is a high-performance Flutter application designed for precise location tracking, activity monitoring, and interactive map experiences. Whether you're tracking your daily routes or collecting virtual entities, Tracker provides a seamless, offline-first experience.

## ✨ Key Features

- **🚀 Background Tracking**: High-accuracy location tracking even when the app is in the background or the device is locked.
- **🗺️ Interactive Map**: Real-time map visualization with smoothed path rendering (Catmull-Rom Splines) and intelligent segmenting.
- **🎒 Entity Collection**: Discover and collect virtual items scattered across the map as you move.
- **📊 Activity Stats**: Precise step counting (with reboot resilience) and GPS-denoised distance calculation.
- **🌙 Dynamic Theming**: Beautiful Dark and Light modes with persistent user preferences.
- **☁️ Cloud Sync**: Automatic background synchronization of local data to the server when internet is available.
- **📶 Offline First**: Complete map tile caching and local SQLite persistence for zero-connectivity environments.

## 🛠️ Tech Stack

- **UI**: Flutter with Custom Themes
- **State**: Provider & fquery (Server State)
- **Database**: SQLite (sqflite)
- **Auth**: Firebase & Google Sign-In
- **Networking**: Dio with Batch Sync Logic

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.10.4)
- A Firebase Project (for Auth)
- A `.env` file for API configuration

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/SolankiYogesh/Tracker-Flutter.git
   cd tracker
   ```

2. **Setup environment variables**:
   Create a `.env` file in the root and add your configuration:
   ```env
   BASE_URL=https://api.example.com
   ```

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

4. **Initialize Firebase**:
   Ensure you have configured `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).

5. **Run the app**:
   ```bash
   flutter run
   ```

## 📖 Architecture & Logic

For a deep dive into the project's logic, directory structure, and technical implementation details, please refer to the [**Project Documentation**](PROJECT_DOCUMENTATION.md).

## ⚙️ Configuration

Core settings can be tweaked in `lib/constants/app_constants.dart`:
- `locationSyncInterval`: Speed of cloud syncing.
- `gpsMinAccuracyThreshold`: Filtering threshold for GPS noise.
- `mapRefreshInterval`: Smoothness of UI updates.

## 🤝 Contributing

We welcome contributions! Please feel free to submit a Pull Request.

---
Developed by **Yogesh Solanki**
