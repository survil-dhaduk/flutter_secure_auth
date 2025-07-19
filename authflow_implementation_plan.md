# AuthFlow Implementation Plan
## Clean Architecture + Riverpod

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
│       │   │   └── auth_local_data_source.dart
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
│       │       ├── set_pin.dart
│       │       ├── verify_pin.dart
│       │       ├── enable_biometric.dart
│       │       ├── authenticate_biometric.dart
│       │       └── sign_out.dart
│       └── presentation/
│           ├── providers/
│           │   ├── auth_provider.dart
│           │   ├── pin_provider.dart
│           │   └── biometric_provider.dart
│           ├── pages/
│           │   ├── login_page.dart
│           │   ├── pin_setup_page.dart
│           │   ├── pin_entry_page.dart
│           │   ├── biometric_setup_page.dart
│           │   ├── forgot_password_page.dart
│           │   └── home_page.dart
│           └── widgets/
│               ├── custom_text_field.dart
│               ├── pin_input.dart
│               ├── biometric_prompt.dart
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
  flutter_secure_storage: ^9.0.0
  local_auth: ^2.1.7
  
  # Storage & Preferences
  shared_preferences: ^2.2.2
  
  # Utilities
  dartz: ^0.10.1
  equatable: ^2.0.5
  
  # UI
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
  final bool isPinSet;
  final bool isBiometricEnabled;
  
  // Implementation
}

// lib/features/auth/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithEmail(String email, String password);
  Future<Either<Failure, User>> signUpWithEmail(String email, String password);
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, void>> setPin(String pin);
  Future<Either<Failure, bool>> verifyPin(String pin);
  Future<Either<Failure, void>> enableBiometric();
  Future<Either<Failure, bool>> authenticateWithBiometric();
  Future<Either<Failure, void>> signOut();
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
}

// lib/features/auth/data/datasources/auth_local_data_source.dart
abstract class AuthLocalDataSource {
  Future<void> setPin(String pin);
  Future<bool> verifyPin(String pin);
  Future<void> setBiometricEnabled(bool enabled);
  Future<bool> isBiometricEnabled();
  Future<bool> authenticateWithBiometric();
  Future<void> clearLocalData();
}
```

#### 2.2 Repository Implementation
```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  
  // Implement all methods with proper error handling
}
```

### **Phase 3: Use Cases (Day 2)**

#### 3.1 Authentication Use Cases
```dart
// lib/features/auth/domain/usecases/sign_in_with_email.dart
class SignInWithEmail {
  final AuthRepository repository;
  
  SignInWithEmail(this.repository);
  
  Future<Either<Failure, User>> call(SignInParams params) {
    return repository.signInWithEmail(params.email, params.password);
  }
}

// Similar pattern for other use cases
```

### **Phase 4: State Management (Day 2-3)**

#### 4.1 Riverpod Providers
```dart
// lib/features/auth/presentation/providers/auth_provider.dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    localDataSource: ref.read(authLocalDataSourceProvider),
  );
});

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
  
  // Other methods...
}
```

#### 4.2 Auth State Model
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
  
  // Factory constructors and copyWith method
}
```

### **Phase 5: UI Layer (Day 3-4)**

#### 5.1 Login Page
```dart
// lib/features/auth/presentation/pages/login_page.dart
class LoginPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        // Navigate to PIN setup or home
      } else if (next.status == AuthStatus.error) {
        // Show error
      }
    });
    
    return Scaffold(
      // UI implementation
    );
  }
}
```

#### 5.2 PIN Components
```dart
// lib/features/auth/presentation/providers/pin_provider.dart
final pinStateProvider = StateNotifierProvider<PinNotifier, PinState>((ref) {
  return PinNotifier(ref.read(authRepositoryProvider));
});

// lib/features/auth/presentation/pages/pin_setup_page.dart
class PinSetupPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // PIN setup UI
  }
}
```

### **Phase 6: Biometric Integration (Day 4)**

#### 6.1 Biometric Provider
```dart
// lib/features/auth/presentation/providers/biometric_provider.dart
final biometricProvider = StateNotifierProvider<BiometricNotifier, BiometricState>((ref) {
  return BiometricNotifier(ref.read(authRepositoryProvider));
});

class BiometricNotifier extends StateNotifier<BiometricState> {
  final AuthRepository _repository;
  
  BiometricNotifier(this._repository) : super(BiometricState.initial());
  
  Future<void> checkBiometricAvailability() async {
    // Implementation
  }
  
  Future<void> authenticateWithBiometric() async {
    // Implementation
  }
}
```

### **Phase 7: Navigation & Routing (Day 4-5)**

#### 7.1 App Router
```dart
// lib/core/router/app_router.dart
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isPinSet = authState.user?.isPinSet ?? false;
      
      // Navigation logic based on auth state
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => LoginPage()),
      GoRoute(path: '/pin-setup', builder: (context, state) => PinSetupPage()),
      GoRoute(path: '/pin-entry', builder: (context, state) => PinEntryPage()),
      GoRoute(path: '/home', builder: (context, state) => HomePage()),
    ],
  );
});
```

## 🧪 **Testing Strategy**

### Unit Tests
- [ ] Domain entities and use cases
- [ ] Repository implementations
- [ ] Validators and utilities

### Widget Tests
- [ ] Individual page components
- [ ] Custom widgets
- [ ] Form validation

### Integration Tests
- [ ] Complete authentication flow
- [ ] PIN and biometric flows
- [ ] Navigation scenarios

## 🔄 **Daily Breakdown**

| Day | Focus | Deliverables |
|-----|-------|-------------|
| 1 | Core Setup + Domain | Project structure, entities, repositories |
| 2 | Data Layer + Use Cases | Data sources, repository impl, use cases |
| 3 | State Management + Login | Riverpod providers, login UI |
| 4 | PIN + Biometric | PIN flows, biometric integration |
| 5 | Polish + Testing | Navigation, error handling, testing |

## 🎯 **Key Providers Structure**

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

This implementation plan follows clean architecture principles with proper separation of concerns, comprehensive state management with Riverpod, and a clear development timeline.