# AuthFlow Implementation Plan - Updated
## Clean Architecture + Riverpod (Native Biometric Focus)

## 🏗️ **Project Structure**

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── storage_keys.dart
│   ├── errors/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   └── extensions.dart
│   └── types/
│       └── typedefs.dart
├── features/
│   └── auth/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── auth_remote_data_source.dart
│       │   │   └── biometric_local_data_source.dart
│       │   ├── models/
│       │   │   └── user_model.dart
│       │   └── repositories/
│       │       └── auth_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── user.dart
│       │   ├── repositories/
│       │   │   └── auth_repository.dart
│       │   └── usecases/
│       │       ├── sign_in_with_email.dart
│       │       ├── sign_up_with_email.dart
│       │       ├── reset_password.dart
│       │       ├── setup_biometric.dart
│       │       ├── authenticate_biometric.dart
│       │       ├── check_biometric_status.dart
│       │       └── sign_out.dart
│       └── presentation/
│           ├── providers/
│           │   ├── auth_provider.dart
│           │   └── biometric_provider.dart
│           ├── pages/
│           │   ├── login_page.dart
│           │   ├── home_page.dart
│           │   └── forgot_password_page.dart
│           └── widgets/
│               ├── custom_text_field.dart
│               ├── biometric_prompt.dart
│               ├── biometric_setup_card.dart
│               └── loading_overlay.dart
└── main.dart
```

## 📦 **Dependencies**

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9
  
  # Authentication & Security
  firebase_auth: ^4.15.3
  firebase_core: ^2.24.2
  local_auth: ^2.1.7
  
  # Storage & Preferences
  shared_preferences: ^2.2.2
  
  # Utilities
  dartz: ^0.10.1
  equatable: ^2.0.5
  
  # UI & Navigation
  go_router: ^12.1.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  mockito: ^5.4.4
  build_runner: ^2.4.7
```

## 🔧 **Implementation Phases**

### **Phase 1: Core Setup (Day 1)**

#### 1.1 Project Foundation
- [ ] Initialize Flutter project with clean architecture structure
- [ ] Setup Firebase configuration
- [ ] Configure Riverpod providers
- [ ] Create core utilities and constants

#### 1.2 Domain Layer
```dart
// lib/features/auth/domain/entities/user.dart
class User extends Equatable {
  final String id;
  final String email;
  final bool isBiometricSetup;
  final DateTime? lastLogin;
  
  const User({
    required this.id,
    required this.email,
    required this.isBiometricSetup,
    this.lastLogin,
  });
  
  @override
  List<Object?> get props => [id, email, isBiometricSetup, lastLogin];
}

// lib/features/auth/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithEmail(String email, String password);
  Future<Either<Failure, User>> signUpWithEmail(String email, String password);
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, bool>> isBiometricAvailable();
  Future<Either<Failure, bool>> isBiometricSetup();
  Future<Either<Failure, void>> setupBiometric();
  Future<Either<Failure, bool>> authenticateWithBiometric();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, User?>> getCurrentUser();
}
```

### **Phase 2: Data Layer (Day 1-2)**

#### 2.1 Data Sources
```dart
// lib/features/auth/data/datasources/auth_remote_data_source.dart
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String email, String password);
  Future<void> resetPassword(String email);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

// lib/features/auth/data/datasources/biometric_local_data_source.dart
abstract class BiometricLocalDataSource {
  Future<bool> isBiometricAvailable();
  Future<bool> isBiometricSetup();
  Future<void> setBiometricSetup(bool isSetup);
  Future<bool> authenticateWithBiometric();
  Future<void> clearBiometricData();
}

class BiometricLocalDataSourceImpl implements BiometricLocalDataSource {
  final LocalAuthentication _localAuth;
  final SharedPreferences _prefs;
  
  BiometricLocalDataSourceImpl({
    required LocalAuthentication localAuth,
    required SharedPreferences prefs,
  }) : _localAuth = localAuth, _prefs = prefs;
  
  @override
  Future<bool> isBiometricAvailable() async {
    final isAvailable = await _localAuth.canCheckBiometrics;
    final isDeviceSupported = await _localAuth.isDeviceSupported();
    return isAvailable && isDeviceSupported;
  }
  
  @override
  Future<bool> authenticateWithBiometric() async {
    return await _localAuth.authenticate(
      localizedReason: 'Please authenticate to access the app',
      options: const AuthenticationOptions(
        biometricOnly: false, // Allow PIN/Pattern fallback
        stickyAuth: true,
      ),
    );
  }
  
  // Other implementations...
}
```

### **Phase 3: Use Cases (Day 2)**

#### 3.1 Updated Use Cases
```dart
// lib/features/auth/domain/usecases/setup_biometric.dart
class SetupBiometric {
  final AuthRepository repository;
  
  SetupBiometric(this.repository);
  
  Future<Either<Failure, void>> call() async {
    // Check if biometric is available first
    final availabilityResult = await repository.isBiometricAvailable();
    
    return availabilityResult.fold(
      (failure) => Left(failure),
      (isAvailable) async {
        if (!isAvailable) {
          return Left(BiometricFailure('Biometric authentication not available'));
        }
        return await repository.setupBiometric();
      },
    );
  }
}

// lib/features/auth/domain/usecases/authenticate_biometric.dart
class AuthenticateBiometric {
  final AuthRepository repository;
  
  AuthenticateBiometric(this.repository);
  
  Future<Either<Failure, bool>> call() async {
    // Check if biometric is setup first
    final setupResult = await repository.isBiometricSetup();
    
    return setupResult.fold(
      (failure) => Left(failure),
      (isSetup) async {
        if (!isSetup) {
          return Left(BiometricFailure('Biometric not setup'));
        }
        return await repository.authenticateWithBiometric();
      },
    );
  }
}

// lib/features/auth/domain/usecases/check_biometric_status.dart
class CheckBiometricStatus {
  final AuthRepository repository;
  
  CheckBiometricStatus(this.repository);
  
  Future<Either<Failure, BiometricStatus>> call() async {
    final availabilityResult = await repository.isBiometricAvailable();
    
    return availabilityResult.fold(
      (failure) => Left(failure),
      (isAvailable) async {
        if (!isAvailable) {
          return Right(BiometricStatus.notAvailable);
        }
        
        final setupResult = await repository.isBiometricSetup();
        return setupResult.fold(
          (failure) => Left(failure),
          (isSetup) => Right(
            isSetup ? BiometricStatus.setupComplete : BiometricStatus.availableNotSetup
          ),
        );
      },
    );
  }
}

enum BiometricStatus {
  notAvailable,
  availableNotSetup,
  setupComplete,
}
```

### **Phase 4: State Management (Day 2-3)**

#### 4.1 Updated Riverpod Providers
```dart
// lib/features/auth/presentation/providers/auth_provider.dart
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  
  AuthNotifier(this._repository) : super(AuthState.initial());
  
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    
    final result = await _repository.signInWithEmail(email, password);
    
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ),
    );
  }
  
  Future<void> checkAuthStatus() async {
    final result = await _repository.getCurrentUser();
    
    result.fold(
      (failure) => state = state.copyWith(status: AuthStatus.unauthenticated),
      (user) {
        if (user != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
        } else {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      },
    );
  }
}

// lib/features/auth/presentation/providers/biometric_provider.dart
final biometricStateProvider = StateNotifierProvider<BiometricNotifier, BiometricState>((ref) {
  return BiometricNotifier(ref.read(authRepositoryProvider));
});

class BiometricNotifier extends StateNotifier<BiometricState> {
  final AuthRepository _repository;
  
  BiometricNotifier(this._repository) : super(BiometricState.initial());
  
  Future<void> checkBiometricStatus() async {
    state = state.copyWith(status: BiometricAuthStatus.checking);
    
    final checkBiometricUseCase = CheckBiometricStatus(_repository);
    final result = await checkBiometricUseCase();
    
    result.fold(
      (failure) => state = state.copyWith(
        status: BiometricAuthStatus.error,
        errorMessage: failure.message,
      ),
      (biometricStatus) => state = state.copyWith(
        status: BiometricAuthStatus.checked,
        biometricStatus: biometricStatus,
      ),
    );
  }
  
  Future<void> setupBiometric() async {
    state = state.copyWith(status: BiometricAuthStatus.settingUp);
    
    final setupBiometricUseCase = SetupBiometric(_repository);
    final result = await setupBiometricUseCase();
    
    result.fold(
      (failure) => state = state.copyWith(
        status: BiometricAuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: BiometricAuthStatus.setupComplete,
        biometricStatus: BiometricStatus.setupComplete,
      ),
    );
  }
  
  Future<void> authenticateWithBiometric() async {
    state = state.copyWith(status: BiometricAuthStatus.authenticating);
    
    final authenticateBiometricUseCase = AuthenticateBiometric(_repository);
    final result = await authenticateBiometricUseCase();
    
    result.fold(
      (failure) {
        final currentAttempts = state.failedAttempts + 1;
        state = state.copyWith(
          status: BiometricAuthStatus.authenticationFailed,
          failedAttempts: currentAttempts,
          errorMessage: failure.message,
        );
        
        // Redirect to login after 3 failed attempts
        if (currentAttempts >= 3) {
          state = state.copyWith(status: BiometricAuthStatus.maxAttemptsReached);
        }
      },
      (success) {
        if (success) {
          state = state.copyWith(
            status: BiometricAuthStatus.authenticated,
            failedAttempts: 0,
          );
        } else {
          final currentAttempts = state.failedAttempts + 1;
          state = state.copyWith(
            status: BiometricAuthStatus.authenticationFailed,
            failedAttempts: currentAttempts,
          );
        }
      },
    );
  }
}
```

#### 4.2 Updated State Models
```dart
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  
  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });
  
  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
  
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
  
  @override
  List<Object?> get props => [status, user, errorMessage];
}

enum BiometricAuthStatus {
  initial,
  checking,
  checked,
  settingUp,
  setupComplete,
  authenticating,
  authenticated,
  authenticationFailed,
  maxAttemptsReached,
  error,
}

class BiometricState extends Equatable {
  final BiometricAuthStatus status;
  final BiometricStatus? biometricStatus;
  final int failedAttempts;
  final String? errorMessage;
  
  const BiometricState({
    required this.status,
    this.biometricStatus,
    this.failedAttempts = 0,
    this.errorMessage,
  });
  
  factory BiometricState.initial() => const BiometricState(
    status: BiometricAuthStatus.initial,
  );
  
  @override
  List<Object?> get props => [status, biometricStatus, failedAttempts, errorMessage];
}
```

### **Phase 5: UI Layer (Day 3-4)**

#### 5.1 Updated Home Page with Biometric Setup
```dart
// lib/features/auth/presentation/pages/home_page.dart
class HomePage extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Check biometric status on home page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(biometricStateProvider.notifier).checkBiometricStatus();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final biometricState = ref.watch(biometricStateProvider);
    final authState = ref.watch(authStateProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${authState.user?.email ?? ''}'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Show biometric setup card if not setup
            if (biometricState.biometricStatus == BiometricStatus.availableNotSetup)
              BiometricSetupCard(),
            
            // Main content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home, size: 100, color: Colors.blue),
                    SizedBox(height: 20),
                    Text(
                      'Welcome to AuthFlow Demo!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 10),
                    Text('You are successfully authenticated'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/features/auth/presentation/widgets/biometric_setup_card.dart
class BiometricSetupCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.fingerprint, size: 50, color: Colors.green),
            SizedBox(height: 10),
            Text(
              'Secure your account',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              'Enable biometric authentication for quick and secure access',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      // Skip setup - just dismiss the card
                      ref.read(biometricStateProvider.notifier).state = 
                          ref.read(biometricStateProvider).copyWith(
                        biometricStatus: BiometricStatus.notAvailable, // Hide card
                      );
                    },
                    child: Text('Maybe Later'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => ref.read(biometricStateProvider.notifier).setupBiometric(),
                    child: Text('Enable'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

#### 5.2 Biometric Authentication Page
```dart
// lib/features/auth/presentation/pages/biometric_auth_page.dart
class BiometricAuthPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<BiometricAuthPage> createState() => _BiometricAuthPageState();
}

class _BiometricAuthPageState extends ConsumerState<BiometricAuthPage> {
  @override
  void initState() {
    super.initState();
    // Auto-trigger biometric authentication
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(biometricStateProvider.notifier).authenticateWithBiometric();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final biometricState = ref.watch(biometricStateProvider);
    
    ref.listen<BiometricState>(biometricStateProvider, (previous, next) {
      if (next.status == BiometricAuthStatus.authenticated) {
        context.go('/home');
      } else if (next.status == BiometricAuthStatus.maxAttemptsReached) {
        context.go('/login');
      }
    });
    
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fingerprint,
                size: 100,
                color: _getIconColor(biometricState.status),
              ),
              SizedBox(height: 30),
              Text(
                _getStatusText(biometricState.status),
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              if (biometricState.status == BiometricAuthStatus.authenticationFailed) ...[
                Text(
                  'Attempts remaining: ${3 - biometricState.failedAttempts}',
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => ref.read(biometricStateProvider.notifier).authenticateWithBiometric(),
                  child: Text('Try Again'),
                ),
              ],
              SizedBox(height: 20),
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text('Use Email & Password Instead'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getIconColor(BiometricAuthStatus status) {
    switch (status) {
      case BiometricAuthStatus.authenticated:
        return Colors.green;
      case BiometricAuthStatus.authenticationFailed:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
  
  String _getStatusText(BiometricAuthStatus status) {
    switch (status) {
      case BiometricAuthStatus.authenticating:
        return 'Authenticating...';
      case BiometricAuthStatus.authenticated:
        return 'Authentication Successful!';
      case BiometricAuthStatus.authenticationFailed:
        return 'Authentication Failed';
      case BiometricAuthStatus.maxAttemptsReached:
        return 'Too many failed attempts';
      default:
        return 'Touch sensor or use device authentication';
    }
  }
}
```

### **Phase 6: Navigation & Routing (Day 4)**

#### 6.1 Updated App Router
```dart
// lib/core/router/app_router.dart
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final biometricState = ref.watch(biometricStateProvider);
  
  return GoRouter(
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isLoading = authState.status == AuthStatus.loading;
      final biometricStatus = biometricState.biometricStatus;
      
      // Show loading if auth is checking
      if (isLoading) return null;
      
      // If not authenticated, go to login
      if (!isAuthenticated) {
        return '/login';
      }
      
      // If authenticated and biometric is setup, require biometric auth
      if (biometricStatus == BiometricStatus.setupComplete && 
          biometricState.status != BiometricAuthStatus.authenticated) {
        return '/biometric-auth';
      }
      
      // If authenticated but no biometric setup, go to home (will show setup card)
      if (state.location == '/login' || state.location == '/biometric-auth') {
        return '/home';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => HomePage(),
      ),
      GoRoute(
        path: '/biometric-auth',
        builder: (context, state) => BiometricAuthPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => ForgotPasswordPage(),
      ),
    ],
  );
});
```

## 🔄 **Updated Daily Breakdown**

| Day | Focus | Deliverables |
|-----|-------|-------------|
| 1 | Core Setup + Domain | Project structure, entities, repositories, Firebase setup |
| 2 | Data Layer + Use Cases | Biometric data sources, repository impl, use cases |
| 3 | State Management + UI | Riverpod providers, login, home with biometric setup |
| 4 | Biometric Flow + Navigation | Biometric auth page, routing logic, testing |

## 🎯 **Key Changes from Original Plan**

1. **Removed PIN System**: No custom PIN implementation
2. **Native Biometric Focus**: All security handled by `local_auth`
3. **Simplified Storage**: Only `shared_preferences` for biometric setup status
4. **Streamlined Flow**: Login → Home (with setup prompt) → Biometric Auth
5. **Better UX**: Setup prompt naturally appears on home screen
6. **Fallback Strategy**: 3 failed biometric attempts → redirect to login

## 🧪 **Testing Scenarios**

- [ ] Fresh install → Firebase login → biometric setup prompt
- [ ] Returning user with biometric → direct biometric auth
- [ ] Returning user without biometric → setup prompt on home
- [ ] Failed biometric attempts → fallback to login
- [ ] Device without biometric support → normal login flow

This updated plan focuses entirely on native biometric authentication using device features, eliminating the complexity of custom PIN management while maintaining security and great UX.