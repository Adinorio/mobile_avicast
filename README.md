# Avicast Mobile App

A Flutter mobile application for the Avicast platform that provides offline-capable field data collection with local WiFi synchronization.

## Features

- **Offline-First Design**: Works without internet connection using locally stored data
- **Local WiFi Sync**: Automatically discovers and connects to Django backend on local network
- **User Authentication**: Secure login with employee ID and password
- **Data Synchronization**: Bidirectional sync when connected to local network
- **Modern UI**: Material Design 3 with light/dark theme support
- **Cross-Platform**: Runs on both Android and iOS

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mobile_avicast
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   └── user.dart            # User model
├── providers/                # State management
│   ├── auth_provider.dart   # Authentication state
│   ├── network_provider.dart # Network connectivity
│   └── sync_provider.dart   # Data synchronization
├── screens/                  # UI screens
│   ├── splash_screen.dart   # Loading screen
│   ├── login_screen.dart    # Login interface
│   └── home_screen.dart     # Main dashboard
├── services/                 # Business logic
│   ├── auth_service.dart    # Authentication logic
│   ├── local_storage_service.dart # Local data storage
│   ├── network_discovery_service.dart # WiFi server discovery
│   └── sync_service.dart    # Data sync logic
└── utils/                    # Utilities
    └── theme.dart           # App theming
```

## Configuration

### Local Network Setup

1. **Configure Django Backend**
   - Ensure your Django server is running on the local network
   - Set `ALLOWED_HOSTS` to include your local IP addresses
   - Configure CORS if needed for cross-origin requests

2. **Network Discovery**
   - The app automatically scans for servers on port 8000 (default Django port)
   - Add your network names to `_knownNetworks` in `network_discovery_service.dart`
   - Common network names: `Avicast_Local`, `Avicast_Office`, `Avicast_Field`

3. **API Endpoints**
   The app expects these Django API endpoints:
   - `/api/auth/login/` - User authentication
   - `/api/auth/logout/` - User logout
   - `/api/auth/profile/` - User profile
   - `/api/users/` - Users data
   - `/api/locations/` - Locations data
   - `/api/fauna/` - Fauna data
   - `/api/analytics/` - Analytics data
   - `/api/sync/` - Data synchronization
   - `/api/sync/stats/` - Sync statistics

### Offline Mode

The app automatically falls back to offline mode when:
- No local network is available
- Django server is unreachable
- Network connection is lost

In offline mode:
- Users can still log in with previously stored credentials
- All data operations are stored locally
- Changes are queued for sync when connection is restored

## Usage

### First Time Setup

1. **Install the app** on your mobile device
2. **Connect to local WiFi** network where Django backend is running
3. **Launch the app** - it will automatically discover the server
4. **Login** with your employee ID and password
5. **Data sync** will begin automatically

### Daily Operations

1. **Connect to local network** when starting work
2. **Login** to the app
3. **Collect data** - all changes are stored locally
4. **Sync data** when connected (automatic or manual)
5. **Continue working** even if connection is lost

### Data Synchronization

- **Automatic sync** occurs when:
  - App connects to local network
  - User manually triggers sync
  - Background sync (if implemented)

- **Manual sync** options:
  - Full sync (download + upload)
  - Upload only (pending changes)
  - Download only (new data)

## Development

### Adding New Features

1. **Create models** in `lib/models/`
2. **Add providers** in `lib/providers/` for state management
3. **Create services** in `lib/services/` for business logic
4. **Build UI** in `lib/screens/`
5. **Update sync logic** in `sync_service.dart`

### Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

### Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Troubleshooting

### Common Issues

1. **Server not discovered**
   - Check if Django server is running
   - Verify network connectivity
   - Check firewall settings
   - Ensure server is on port 8000

2. **Sync failures**
   - Check authentication token
   - Verify API endpoints
   - Check server logs for errors
   - Ensure data format compatibility

3. **Offline login issues**
   - Clear app data and re-login
   - Check stored user data integrity
   - Verify password hash storage

### Debug Mode

Enable debug logging by setting:
```dart
// In main.dart
debugPrint = (String? message, {int? wrapWidth}) {
  print('DEBUG: $message');
};
```

## Security Considerations

- **Password Storage**: Passwords are hashed using SHA-256 for offline verification
- **Local Data**: All local data is stored in app's private storage
- **Network Security**: Uses HTTP for local network (consider HTTPS for production)
- **Authentication**: Token-based authentication with local fallback

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

## Roadmap

- [ ] Offline data validation
- [ ] Background sync service
- [ ] Push notifications
- [ ] Advanced data visualization
- [ ] Multi-language support
- [ ] Biometric authentication
- [ ] Data export functionality
- [ ] Advanced search and filtering 