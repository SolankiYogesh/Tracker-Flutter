# Tracker

A location tracking Flutter project.

## Configuration

The application's core configuration and hardcoded values are centralized in `lib/constants/app_constants.dart`.
This file allows you to easily tune parameters such as:

- **Location Sync**: `locationSyncInterval` (default: 30s)
- **Map Display**: `defaultMapZoom` (default: 15.0), `mapRefreshInterval` (default: 5s)
- **Network**: Timeouts and fetch intervals
- **GPS Filtering**: Thresholds for accuracy and speed to filter out noisy data in stats

Refer to the documentation comments in `lib/constants/app_constants.dart` for detailed explanations of each setting.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
