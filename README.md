# Weather App

A Flutter application that provides real-time weather data and forecasts using the OpenWeather API.

## Features

- Current weather information for any city
- 5-day weather forecast with daily breakdown
- Hourly forecast for the next 24 hours
- Automatic location detection
- Search history for quick access
- Offline support with local caching
- Dark/Light theme toggle
- Celsius/Fahrenheit temperature units
- Responsive UI for mobile, tablet, and desktop

### Demo Videos

<p align="center">
  <video width="280" controls>
    <source src="videos/macos.mov" type="video/mp4">
    Your browser does not support the video tag.
  </video>
  <video width="280" controls>
    <source src="videos/mobile.mp4" type="video/mp4">
    Your browser does not support the video tag.
  </video>
</p>

- [App Overview and Features Demo_Mac_OS](videos/macos.mov)
- [App Overview and Features Demo_Mobile](videos/mobile.mp4)


### APK Download

You can download the latest APK build of the Weather App:
- [Download APK v1.0.0](releases/weather-app-v1.apk)

## Getting Started

### Prerequisites

- Flutter 3.29.2 or higher (we use FVM for version management)
- Dart SDK 3.3.0 or higher
- A valid OpenWeather API key

### Installation and Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/utsav-savani/Weather-App-FL.git
   cd weather-app
   ```

2. Set up FVM (Flutter Version Management):
   ```bash
   # Install FVM if you don't have it
   dart pub global activate fvm
   
   # Install and use Flutter 3.29.2
   fvm install 3.29.2
   fvm use 3.29.2
   ```

3. Install dependencies:
   ```bash
   fvm flutter pub get
   ```

4. Set your OpenWeather API key:
    - Open `lib/core/config/environment.dart`
    - Replace the API key with your own OpenWeather API key

5. Run the code generation for models:
   ```bash
   fvm flutter pub run build_runner build --delete-conflicting-outputs
   ```

6. Run the app:
   ```bash
   fvm flutter run
   ```

## Architecture & Project Structure

This project follows Clean Architecture principles with a clear separation of concerns. The codebase is organized into the following layers:

### Project Structure

```
lib/
├── core/                   # Core functionality and utilities
│   ├── api/                # API client implementation
│   ├── config/             # App configuration and environment variables
│   ├── di/                 # Dependency injection container
│   ├── errors/             # Custom errors and exceptions
│   ├── navigation/         # Routing configuration
│   ├── storage/            # Local storage implementation
│   ├── theme/              # App theming
│   └── utils/              # Utility functions and constants
├── data/                   # Data layer
│   ├── datasources/        # Data sources (local and remote)
│   │   ├── local/          # Local data sources
│   │   └── remote/         # Remote API data sources
│   ├── models/             # Data models with JSON serialization
│   └── repositories/       # Repository implementations
├── domain/                 # Domain layer
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Use cases defining business logic
├── gen/                    # Generated code for assets
└── presentation/           # Presentation layer
    ├── blocs/              # BLoC state management
    │   ├── current_weather/
    │   ├── forecast/
    │   ├── settings/
    │   └── theme/
    ├── pages/              # App screens
    └── widgets/            # Reusable UI components
```

### Test Structure

```
test/
├── data/                   # Tests for data layer
│   └── repositories/       # Repository implementation tests
├── domain/                 # Tests for domain layer
│   └── usecases/           # Use case tests
├── presentation/           # Tests for presentation layer
│   └── blocs/              # BLoC tests
└── widget_test.dart        # Widget tests

integration_test/
└── app_test.dart           # Integration tests for the app
```

## Using the App

### Searching for Cities
1. Tap the search icon in the app bar
2. Enter a city name in the search field
3. Select a city from the results or suggestions
4. View the current weather and forecast for the selected city

### Changing Settings
1. **Temperature Units**:
    - Navigate to the Settings page
    - Under "Units", select your preferred temperature unit (Celsius or Fahrenheit)

2. **Theme**:
    - Navigate to the Settings page
    - Toggle the "Dark Mode" switch to change between light and dark themes

## Technologies & Libraries

- **State Management**: Flutter BLoC/Cubit
- **Dependency Injection**: GetIt
- **Local Storage**: Hive
- **Networking**: Dio
- **Routing**: Go Router
- **Connectivity**: Connectivity Plus
- **Location**: Geolocator
- **Animation**: Flutter Animate
- **Image Caching**: Cached Network Image
- **UI Effects**: Shimmer
- **Code Generation**: Build Runner & JSON Serializable
- **Testing**: Mockito

## Testing

The app includes unit, widget, and integration tests:

### Unit Tests

Tests for repositories, use cases, and BLoCs to ensure business logic works correctly.

```bash
fvm flutter test
```

### Integration Tests

End-to-end tests to verify app behavior from the user's perspective.

```bash
fvm flutter test integration_test/app_test.dart
```

## Steps Taken to Build the App

1. **Project Setup**:
    - Created Flutter project with FVM to manage Flutter version
    - Set up clean architecture folder structure
    - Configured project dependencies

2. **Core Infrastructure**:
    - Implemented API client for OpenWeather API
    - Set up local storage with Hive
    - Created error handling system
    - Implemented dependency injection

3. **Data & Domain Layers**:
    - Developed data models with JSON serialization
    - Created repository interfaces and implementations
    - Implemented use cases for business logic

4. **Presentation Layer**:
    - Implemented state management with BLoC/Cubit
    - Created responsive UI with responsive_builder
    - Built custom animations for weather conditions
    - Developed theme switching functionality

5. **Testing**:
    - Created unit tests for repositories and use cases
    - Implemented BLoC tests
    - Added integration tests for key user flows

6. **Refinement**:
    - Added error handling and loading states
    - Implemented caching for offline support
    - Added location detection
    - Refined UI animations and transitions

## Acknowledgements

- [OpenWeather API](https://openweathermap.org/api) for providing weather data
- All the package authors whose libraries were used in this project
