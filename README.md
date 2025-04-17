# GeoCam News App

A Flutter application that captures location and photos, and displays news from a public API.

## Features

### GeoCam Feature
- Captures user location (latitude & longitude) with permission
- Takes photos with the camera
- Saves location data and photos to local storage
- Resets stored data

### News Feature
- Displays a list of news articles from JSONPlaceholder API
- Shows news details when clicked
- Pull-to-refresh for updated news
- Bookmark feature to save articles for later reading
- Swipe to delete bookmarks
- Persistent bookmarks storage
- Smart image handling with dynamic placeholders and error states

### UI Features
- Support for both Light and Dark mode
- Theme toggle button in the app bar
- Theme preference is saved locally
- Material Design 3 UI components
- Smooth animated transitions throughout the app:
  - Staggered list animations for news items
  - Page transitions between screens
  - Container transform animations for details
  - Theme toggle animation
  - Loading and status animations
  - Hero animations for images

## Getting Started

### Prerequisites
- Flutter SDK (version 3.7.0 or higher)
- Android SDK or Xcode (for iOS development)
- Editor: Visual Studio Code, Android Studio, or IntelliJ IDEA

### Installation & Running
Follow these steps to build and run the application:

1. Clone this repository
   ```
   git clone https://github.com/yourusername/geocam-news.git
   cd geocam-news
   ```

2. Install dependencies
   ```
   flutter pub get
   ```

3. Run on emulator or device
   ```
   flutter run
   ```

4. For release build
   ```
   flutter build apk --release    # Android
   flutter build ios --release    # iOS
   ```

## Libraries & Dependencies
The application uses the following libraries:

| Library | Purpose |
|---------|---------|
| geolocator (^11.0.0) | Get precise location data |
| permission_handler (^11.3.0) | Manage device permissions |
| camera (^0.10.5+9) | Access device camera |
| image_picker (^1.0.7) | Pick images from camera |
| path_provider (^2.1.2) | File system access |
| shared_preferences (^2.2.2) | Local data storage |
| provider (^6.1.2) | State management |
| http (^1.2.0) | API requests |
| intl (^0.19.0) | Formatting & internationalization |
| animations (^2.0.10) | Advanced transition animations |
| flutter_animate (^4.5.0) | Declarative animations |

## Development Workflow (SDLC)

This project follows an Agile development approach with the following workflow:

### 1. Requirements Analysis
- Feature identification: GeoCam and News features
- User story creation for each feature
- Non-functional requirements (permissions, error handling)

### 2. Design Phase
- Architecture design: Provider pattern with clean architecture
- UI/UX wireframing using Material Design principles
- Data model design for news and location data
- Animation planning for enhanced user experience

### 3. Development Phase
- Project setup and dependency configuration
- Models implementation for data structures
- Provider implementation for state management
- UI components development following Material Design
- API integration with JSONPlaceholder
- Camera & location service integration
- Local storage implementation
- Animation implementation for transitions and interactions

### 4. Testing Phase
- Unit testing for providers and models
- Widget testing for UI components
- Integration testing for API and device features
- Manual testing for user flows and edge cases
- Animation performance testing

### 5. Deployment
- Build configuration for release
- Performance optimization
- Documentation completion

### 6. Maintenance & Updates
- Bug fixes based on user feedback
- Feature enhancements
- Library updates

## Project Structure
```
lib/
├── models/         # Data models
│   ├── geocam_model.dart
│   └── news_model.dart
├── providers/      # State management
│   ├── geocam_provider.dart
│   ├── news_provider.dart
│   └── theme_provider.dart
├── screens/        # UI components
│   ├── geocam_screen.dart
│   ├── home_screen.dart
│   ├── news_detail_screen.dart
│   ├── news_list_screen.dart
│   └── bookmarks_screen.dart
├── utils/          # Utility classes
│   └── page_transitions.dart
└── main.dart       # Application entry point
```

## Required Permissions
- Location (Fine and Coarse)
- Camera
- Internet

## Error Handling
The application implements comprehensive error handling for:
- API failures with retry options
- Permission denials with user guidance
- Device feature unavailability
- Loading state management during async operations