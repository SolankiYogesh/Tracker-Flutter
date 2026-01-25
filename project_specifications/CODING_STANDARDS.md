# 📏 GeoPulsify Coding Standards & Best Practices

This document outlines the strict coding standards, architectural patterns, and conventions used in **GeoPulsify**. It is designed to be a single source of truth for both human developers and LLM assistants to ensure consistency and maintainability.

---

## 1. 🚫 Constants & Magic Values

**Rule**: NEVER hardcode functionality-impacting numbers or strings directly in the business logic or UI code.

### ❌ Incorrect
```dart
// Bad: Magic number with no context
if (speed > 28.0) { ... }

// Bad: Hardcoded configuration string
final channelId = 'location_channel_01';
```

### ✅ Correct
All constants must be defined in `lib/constants/app_constants.dart`.

```dart
// lib/constants/app_constants.dart
class AppConstants {
  // Used to filter GPS teleportation glitches. 
  // 28m/s is approx 100km/h, effectively filtering unlikely human running speeds.
  static const double maxSpeedMps = 28.0; 
  
  static const String notificationChannelId = 'location_channel_01';
}

// Usage
if (speed > AppConstants.maxSpeedMps) { ... }
```

**Documentation Requirement**: When adding a constant, you MUST add a comment explaining:
1.  **What** the value represents.
2.  **Why** this specific value was chosen (e.g., "Limits API calls to avoid rate limiting").

---

## 2. 📁 Directory Structure & Organization

We follow a **Feature-First / Cleanish Architecture**.

### Rules

1.  **Screens (`lib/screens/`)**:
    *   Group by feature (e.g., `screens/main/maps/`).
    *   Sub-directories for screen-specific widgets: `screens/main/maps/widgets/`.
    *   **Do not** put reusable, generic widgets here. Put them in `lib/widgets/` (if we create one) or `lib/utils`.

2.  **Network Layer (`lib/network/`)**:
    *   **Repositories (`lib/network/repositories/`)**: ALL API calls must go through a Repository. Never call `Dio` directly from a UI widget or Provider.
    *   **Queries (`lib/network/api_queries.dart`)**: Reusable `fquery` keys and fetchers must be defined here to ensure cache consistency.

3.  **Models (`lib/models/`)**:
    *   Must have `fromJson` and `toJson`.
    *   Must be immutable (`final` fields).

4.  **Providers (`lib/providers/`)**:
    *   Use `Provider` for **Global Client State** (Auth, Theme).
    *   Use `fquery` for **Server State** (Data fetching, caching).
    *   Avoid complex business logic in Providers if possible; delegate to `Services` or `Repositories`.

---

## 3. 🐫 Naming Conventions

### Files & Directories
**Format**: `snake_case`
*   `user_repository.dart`
*   `map_screen.dart`
*   `auth_service_provider.dart`

### Classes & Enums
**Format**: `PascalCase`
*   `class UserRepository { ... }`
*   `enum LoadingState { ... }`

### Variables & Functions
**Format**: `camelCase`
*   `void fetchUserData() { ... }`
*   `bool isLoading = false;`

### Private Members
**Format**: `_camelCase` (Prefix with underscore)
*   `final Dio _dio;`
*   `void _calculateDistance() { ... }`

---

## 4. 🧩 State Management Patterns

### Hybrid Approach
1.  **fquery**: Use for *any* data that comes from the backend.
    *   Why? Automatic caching, deduplication, invalidation, and background polling.
    *   Pattern: Create a `QueryBuilder` in the UI.
2.  **Provider**: Use for *client-side* state.
    *   Auth info (User ID, Tokens).
    *   Theme toggles.
    *   Form state (if complex).

### Isolate Logic
Background location updates run in a **separate isolate**.
*   **Guideline**: You cannot access the main UI `Provider` or context from the background callback.
*   **Communication**: Use `DatabaseHelper` (SQLite) as the shared bus.
    *   Background writes to DB.
    *   Foreground UI polls DB or listens to streams that watch the DB.

---

## 5. 🏗 Widget Structure

### "Smart" vs "Dumb" Widgets
*   **Screens (Smart)**: Connect to Providers/Queries, handle routing, scaffold layout.
*   **Widgets (Dumb)**: Take data via constructor arguments. Do not fetch data internally.

### Performance
*   Use `const` constructors wherever possible.
*   Use `Selector` or `context.select` instead of `context.watch` if you only need a specific field to avoid unnecessary rebuilds.

---

## 6. 📝 Logging & Debugging

**Rule**: Do not use `print()`. Use `AppLogger`.

### ✅ Correct
```dart
import 'package:tracker/utils/app_logger.dart';

try {
  ...
} catch (e, stack) {
  AppLogger.error('Failed to save location', e, stack);
}
```

This ensures logs are routed correctly (e.g., to `Talker` or Crashlytics in production).

---

## 7. 🛡 Error Handling

*   **Repositories**: Catch `DioException`, wrap in `ApiException` (or similar), and rethrow.
*   **UI**: Handle errors gracefully (SnackBar, Error Widget). Never let the app crash silently.

---

## 8. 🧹 Code Formatting

*   Use `flutter format .` (80 chars line length default, or 120 if configured).
*   Sort imports: Dart -> Package -> Relative.

---
