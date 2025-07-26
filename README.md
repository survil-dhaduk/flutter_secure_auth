# AuthFlow - Secure Authentication Demo

A Flutter demo app showcasing secure authentication flows with local data management, featuring Firebase Auth, PIN protection, and biometric authentication.

---

**⚠️ Firebase Configuration Notice**

> **This repository does NOT include Firebase configuration files.**
>
> To run this project, you must create your own Firebase project and add the required configuration files as described below.
>
> This is a demo showcase. For security and privacy, no Firebase credentials or configuration files are included in the repository.

---

## 🚀 Features

### Core Authentication
- **Firebase Authentication**: Email/password sign up and sign in
- **Password Reset**: Forgot password functionality via email
- **Form Validation**: Real-time email and password validation

### Security Features
- **4-Digit PIN Protection**: Secure PIN setup and verification
- **Biometric Authentication**: Fingerprint/Face ID support
- **Secure Storage**: All sensitive data stored using `flutter_secure_storage`
- **Session Management**: Persistent authentication across app restarts

### User Experience
- **Material 3 Design**: Modern, beautiful UI with dark/light themes
- **Loading States**: Smooth loading overlays and progress indicators
- **Error Handling**: Comprehensive error messages and validation
- **Responsive Design**: Works on both Android and iOS

## 🏗️ Architecture

This project follows **Clean Architecture** principles with **Riverpod** for state management:

```
lib/
├── core/                    # Core utilities and constants
│   ├── constants/          # App constants and storage keys
│   ├── errors/             # Failure and exception classes
│   ├── utils/              # Validators and extensions
│   └── types/              # Type definitions
├── features/auth/          # Authentication feature
│   ├── data/               # Data layer
│   │   ├── datasources/    # Remote and local data sources
│   │   ├── models/         # Data models
│   │   └── repositories/   # Repository implementations
│   ├── domain/             # Domain layer
│   │   ├── entities/       # Business entities
│   │   ├── repositories/   # Repository interfaces
│   │   └── usecases/       # Business logic use cases
│   └── presentation/       # Presentation layer
│       ├── providers/      # Riverpod state providers
│       ├── pages/          # UI pages
│       └── widgets/        # Reusable widgets
└── main.dart               # App entry point
```

## 🛠️ Tech Stack

| Component           | Package                   | Purpose                        |
|---------------------|--------------------------|--------------------------------|
| **State Management**| `flutter_riverpod`       | Reactive state management      |
| **Authentication**  | `firebase_auth`          | Firebase authentication        |
| **Secure Storage**  | `flutter_secure_storage` | Encrypted local storage        |
| **Biometrics**      | `local_auth`             | Fingerprint/Face ID            |
| **Navigation**      | `go_router`              | Declarative routing            |
| **Utilities**       | `dartz`, `equatable`     | Functional programming         |

## 📱 User Flow

```
Login → Enable Biometrics? → Home
    ↑                                    ↓
    ← 3 Failed PIN ← PIN Entry ← Biometric Prompt
```

### Authentication Flow
1. **Login/Sign Up**: Email and password authentication via Firebase
2. **PIN Setup**: First-time users set up a 4-digit PIN
3. **Biometric Setup**: Optional biometric authentication setup
4. **Home**: Main app interface with security status

### Security Features
- **PIN Protection**: 3 failed attempts → redirect to login
- **Biometric Fallback**: PIN entry if biometric fails
- **Session Persistence**: Stay logged in across app restarts
- **Secure Storage**: All sensitive data encrypted locally

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.0 or higher)
- Android Studio / Xcode for mobile development

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd flutter_secure_auth
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup (Required for Authentication)**
   - Go to [Firebase Console](https://console.firebase.google.com/) and create a new project.
   - Enable **Authentication** (Email/Password) in your Firebase project.
   - Add your Android and/or iOS app to the Firebase project.
   - Download the configuration files:
     - `google-services.json` for Android
     - `GoogleService-Info.plist` for iOS
   - **Add these files to your project:**
     - Place `google-services.json` in `android/app/`
     - Place `GoogleService-Info.plist` in `ios/Runner/`
   - **Note:** These files are NOT included in this repository. You must add your own.

4. **Run the app**
   ```bash
   flutter run
   ```

### Firebase Configuration

1. **Android Setup**
   - Place `google-services.json` in `android/app/`
   - Update `android/build.gradle` with Google Services plugin

2. **iOS Setup**
   - Place `GoogleService-Info.plist` in `ios/Runner/`
   - Add to Xcode project

## 🧪 Testing

The project includes a comprehensive testing structure:

```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget_test.dart
```

## 📁 Project Structure

### Core Layer
- **Constants**: App-wide constants and storage keys
- **Errors**: Failure and exception handling
- **Utils**: Validation and extension utilities
- **Types**: Type definitions for functional programming

### Domain Layer
- **Entities**: Business objects (User)
- **Repositories**: Abstract interfaces for data access
- **Use Cases**: Business logic implementation

### Data Layer
- **Data Sources**: Firebase and local storage implementations
- **Models**: Data transfer objects
- **Repositories**: Concrete implementations

### Presentation Layer
- **Providers**: Riverpod state management
- **Pages**: Main UI screens
- **Widgets**: Reusable UI components

## 🔐 Security Features

### Data Protection
- **Encrypted Storage**: All sensitive data encrypted using `flutter_secure_storage`
- **PIN Security**: PIN attempts limited with timeout
- **Biometric Integration**: Platform-specific biometric authentication
- **Session Management**: Secure session persistence

### Authentication Flow
- **Multi-Factor**: Email + PIN + Optional Biometric
- **Fallback Mechanisms**: PIN if biometric fails
- **Rate Limiting**: Failed attempt protection
- **Secure Logout**: Complete data cleanup

## 🎨 UI/UX Features

### Design System
- **Material 3**: Latest Material Design guidelines
- **Dark/Light Themes**: Automatic theme switching
- **Responsive Layout**: Works on all screen sizes
- **Loading States**: Smooth loading indicators

### User Experience
- **Intuitive Navigation**: Clear user flow
- **Error Feedback**: Helpful error messages
- **Accessibility**: Screen reader support
- **Performance**: Optimized for smooth interactions

## 📊 State Management

### Riverpod Providers
```dart
// Main providers hierarchy
authRepositoryProvider
├── authRemoteDataSourceProvider (Firebase)
├── authLocalDataSourceProvider (Secure Storage)
└── authStateProvider (Main auth state)
    ├── pinStateProvider (PIN management)
    ├── biometricStateProvider (Biometric auth)
    └── appRouterProvider (Navigation)
```

### State Flow
1. **Auth State**: Manages authentication status
2. **PIN State**: Handles PIN setup and verification
3. **Biometric State**: Manages biometric authentication
4. **Router**: Handles navigation based on auth state

## 🚀 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **Firebase**: Authentication and backend services
- **Riverpod**: State management solution
- **Flutter Team**: Amazing framework
- **Material Design**: Design system

---

**AuthFlow** - Secure, modern authentication for Flutter apps.
