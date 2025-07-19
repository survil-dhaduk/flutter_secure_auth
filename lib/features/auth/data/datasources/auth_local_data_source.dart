import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_keys.dart';

abstract class AuthLocalDataSource {
  Future<void> setBiometricEnabled(bool enabled);
  Future<bool> isBiometricEnabled();
  Future<bool> authenticateWithBiometric();
  Future<void> clearLocalData();
  Future<void> setUserEmail(String email);
  Future<String?> getUserEmail();
  Future<void> setAuthenticated(bool authenticated);
  Future<bool> isAuthenticated();
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
      throw Exception('Biometric authentication failed:  [${e.toString()}');
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
