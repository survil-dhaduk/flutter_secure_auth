import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_keys.dart';

abstract class AuthLocalDataSource {
  Future<void> setPin(String pin);
  Future<bool> verifyPin(String pin);
  Future<void> setBiometricEnabled(bool enabled);
  Future<bool> isBiometricEnabled();
  Future<bool> authenticateWithBiometric();
  Future<void> clearLocalData();
  Future<void> setUserEmail(String email);
  Future<String?> getUserEmail();
  Future<void> setPinAttempts(int attempts);
  Future<int> getPinAttempts();
  Future<void> setLastPinAttempt(DateTime time);
  Future<DateTime?> getLastPinAttempt();
  Future<void> setAuthenticated(bool authenticated);
  Future<bool> isAuthenticated();
  Future<void> setPinEnabled(bool enabled);
  Future<bool> isPinEnabled();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;
  final SharedPreferences _prefs;

  AuthLocalDataSourceImpl({
    required FlutterSecureStorage secureStorage,
    required LocalAuthentication localAuth,
    required SharedPreferences prefs,
  }) : _secureStorage = secureStorage,
       _localAuth = localAuth,
       _prefs = prefs;

  @override
  Future<void> setPin(String pin) async {
    try {
      await _secureStorage.write(key: StorageKeys.userPin, value: pin);
    } catch (e) {
      throw Exception('Failed to store PIN');
    }
  }

  @override
  Future<bool> verifyPin(String pin) async {
    try {
      final storedPin = await _secureStorage.read(key: StorageKeys.userPin);
      return storedPin == pin;
    } catch (e) {
      throw Exception('Failed to verify PIN');
    }
  }

  @override
  Future<void> setPinEnabled(bool enabled) async {
    try {
      await _secureStorage.write(
        key: StorageKeys.isPinSet,
        value: enabled.toString(),
      );
    } catch (e) {
      throw Exception('Failed to set PIN enabled status');
    }
  }

  @override
  Future<bool> isPinEnabled() async {
    try {
      final enabled = await _secureStorage.read(key: StorageKeys.isPinSet);
      return enabled == 'true';
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _secureStorage.write(
        key: StorageKeys.biometricEnabled,
        value: enabled.toString(),
      );
    } catch (e) {
      throw Exception('Failed to set biometric status');
    }
  }

  @override
  Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _secureStorage.read(
        key: StorageKeys.biometricEnabled,
      );
      return enabled == 'true';
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> authenticateWithBiometric() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!isAvailable || !isDeviceSupported) {
        throw Exception('Biometric authentication not available');
      }

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        throw Exception('No biometric authentication available');
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      return authenticated;
    } catch (e) {
      throw Exception('Biometric authentication failed: ${e.toString()}');
    }
  }

  @override
  Future<void> clearLocalData() async {
    try {
      await _secureStorage.deleteAll();
      await _prefs.clear();
    } catch (e) {
      throw Exception('Failed to clear local data');
    }
  }

  @override
  Future<void> setUserEmail(String email) async {
    try {
      await _prefs.setString(StorageKeys.userEmail, email);
    } catch (e) {
      throw Exception('Failed to store user email');
    }
  }

  @override
  Future<String?> getUserEmail() async {
    try {
      return _prefs.getString(StorageKeys.userEmail);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> setPinAttempts(int attempts) async {
    try {
      await _prefs.setInt(StorageKeys.pinAttempts, attempts);
    } catch (e) {
      throw Exception('Failed to store PIN attempts');
    }
  }

  @override
  Future<int> getPinAttempts() async {
    try {
      return _prefs.getInt(StorageKeys.pinAttempts) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<void> setLastPinAttempt(DateTime time) async {
    try {
      await _prefs.setString(
        StorageKeys.lastPinAttempt,
        time.toIso8601String(),
      );
    } catch (e) {
      throw Exception('Failed to store last PIN attempt');
    }
  }

  @override
  Future<DateTime?> getLastPinAttempt() async {
    try {
      final timeString = _prefs.getString(StorageKeys.lastPinAttempt);
      if (timeString == null) return null;
      return DateTime.parse(timeString);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> setAuthenticated(bool authenticated) async {
    try {
      await _prefs.setBool(StorageKeys.isAuthenticated, authenticated);
    } catch (e) {
      throw Exception('Failed to set authentication status');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return _prefs.getBool(StorageKeys.isAuthenticated) ?? false;
    } catch (e) {
      return false;
    }
  }
}
