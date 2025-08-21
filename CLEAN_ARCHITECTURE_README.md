# Avicast Mobile - Clean Architecture Implementation

This project has been restructured to follow Clean Architecture principles, providing a scalable, maintainable, and testable codebase for the Avicast mobile application.

## Architecture Overview

The project follows a layered architecture pattern with clear separation of concerns:

```
lib/
├── core/                    # Core functionality shared across features
│   ├── error/              # Custom exceptions and failure classes
│   ├── network/            # Network connectivity checker
│   └── usecase/            # Base use case for all domain operations
├── features/               # Feature-based modules
│   ├── auth/              # Authentication feature
│   ├── sites/             # Site management feature
│   ├── bird_counting/     # Bird counting feature
│   └── notes/             # Field notes feature
├── injection_container.dart # Dependency injection setup
├── app.dart               # Main app configuration and routing
└── main.dart              # Application entry point
```

## Layer Structure

Each feature follows the same layered structure:

### 1. Domain Layer (`domain/`)
- **Entities**: Core business objects (e.g., `User`, `Site`, `Bird`)
- **Repositories**: Abstract interfaces for data operations
- **Use Cases**: Business logic and application rules

### 2. Data Layer (`data/`)
- **Models**: Data transfer objects extending domain entities
- **Data Sources**: Local (SharedPreferences) and remote (API) data sources
- **Repository Implementations**: Concrete implementations of domain repositories

### 3. Presentation Layer (`presentation/`)
- **Bloc**: State management using BLoC pattern
- **Pages**: UI screens
- **Widgets**: Reusable UI components

## Key Features Implemented

### Authentication Feature
- ✅ User sign in/sign up
- ✅ Password reset
- ✅ Profile management
- ✅ Secure token storage
- ✅ Offline-first approach with local caching

### Core Infrastructure
- ✅ Error handling with custom exceptions and failures
- ✅ Network connectivity monitoring
- ✅ Dependency injection with GetIt
- ✅ State management with BLoC
- ✅ Clean routing and navigation

## Dependencies

The project uses the following key packages:

```yaml
dependencies:
  flutter_bloc: ^8.1.3          # State management
  get_it: ^7.6.4                # Dependency injection
  dartz: ^0.10.1                # Functional programming (Either type)
  equatable: ^2.0.5             # Value equality
  connectivity_plus: ^5.0.2     # Network connectivity
  network_info_plus: ^4.1.0     # Network information
  shared_preferences: ^2.2.2    # Local storage
```

## Getting Started

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the Application
```bash
flutter run
```

## Development Guidelines

### Adding New Features

1. **Create the domain layer first**:
   - Define entities
   - Create repository interfaces
   - Implement use cases

2. **Implement the data layer**:
   - Create data models
   - Implement local and remote data sources
   - Create repository implementations

3. **Build the presentation layer**:
   - Create BLoC for state management
   - Build UI pages and widgets
   - Handle user interactions

### Error Handling

- Use `Either<Failure, Success>` for operations that can fail
- Define specific failure types in `core/error/failures.dart`
- Create corresponding exceptions in `core/error/exceptions.dart`
- Handle errors gracefully in the UI

### State Management

- Use BLoC pattern for complex state management
- Keep UI components stateless when possible
- Use `BlocListener` for side effects (navigation, showing messages)
- Use `BlocBuilder` for UI updates

### Testing

The clean architecture makes testing easier:

- **Unit Tests**: Test use cases, repositories, and data sources in isolation
- **Widget Tests**: Test UI components with mocked BLoCs
- **Integration Tests**: Test complete user flows

## File Naming Conventions

- **Entities**: `user.dart`, `site.dart`
- **Models**: `user_model.dart`, `site_model.dart`
- **Repositories**: `auth_repository.dart`, `site_repository.dart`
- **Use Cases**: `sign_in.dart`, `get_sites.dart`
- **Data Sources**: `auth_local_data_source.dart`, `auth_remote_data_source.dart`
- **BLoCs**: `auth_bloc.dart`, `site_bloc.dart`
- **Pages**: `login_page.dart`, `sites_page.dart`

## Benefits of This Architecture

1. **Separation of Concerns**: Clear boundaries between layers
2. **Testability**: Easy to mock dependencies and test in isolation
3. **Maintainability**: Changes in one layer don't affect others
4. **Scalability**: Easy to add new features following the same pattern
5. **Dependency Inversion**: High-level modules don't depend on low-level modules
6. **Single Responsibility**: Each class has one reason to change

## Next Steps

To complete the implementation:

1. **Implement remaining features**:
   - Sites management (CRUD operations)
   - Bird counting functionality
   - Field notes system
   - Report generation

2. **Add real API integration**:
   - Replace mock data sources with actual HTTP calls
   - Implement proper authentication tokens
   - Add API error handling

3. **Enhance offline capabilities**:
   - Implement data synchronization
   - Add conflict resolution
   - Improve local storage

4. **Add advanced features**:
   - Camera integration for bird identification
   - GPS tracking and geotagging
   - Data export and reporting

## Contributing

When contributing to this project:

1. Follow the established architecture patterns
2. Write tests for new functionality
3. Use meaningful commit messages
4. Update documentation as needed
5. Follow Flutter best practices and style guidelines

## Resources

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter BLoC Documentation](https://bloclibrary.dev/)
- [GetIt Documentation](https://pub.dev/packages/get_it)
- [Dartz Functional Programming](https://pub.dev/packages/dartz) 