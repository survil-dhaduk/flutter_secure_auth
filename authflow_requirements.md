# AuthFlow Flutter Demo - Updated Requirements

## 🎯 **Objective**
Create a mobile-only Flutter demo app showcasing secure authentication with biometric setup and verification using native device features.

## 🔐 **Core Features**

### 1. Email/Password Authentication
- Firebase Auth integration for login/signup
- Email format validation
- Password strength requirements
- Error handling for invalid credentials

### 2. Biometric Setup & Authentication
- **First Login Flow**: After successful Firebase login → redirect to Home → prompt for biometric setup
- **Setup Options**: Fingerprint, Face ID, or device PIN/Pattern (whatever device supports)
- **Storage**: Save biometric preference using `shared_preferences`
- **Fallback**: If biometric setup skipped, allow manual setup later in settings

### 3. Biometric Verification Flow
- **Return Users**: Check if biometric is configured
  - **If Not Set**: Show biometric setup prompt
  - **If Set**: Show biometric authentication prompt
- **Authentication Options**: Use device's native biometric (fingerprint/Face ID/device PIN)
- **Failure Handling**: 3 failed attempts → redirect to Firebase login

### 4. Password Recovery
- "Forgot Password" flow via Firebase
- Email reset functionality
- Success/error feedback

## 🛠 **Technical Stack**

| Component | Package |
|-----------|---------|
| Authentication | `firebase_auth` |
| Biometrics | `local_auth` |
| Preferences | `shared_preferences` |
| UI | Material 3 Design |

## 🔄 **Updated User Flow**

```
Firebase Login → Home Screen → Biometric Setup Prompt
                      ↓               ↓
                 Skip (Later)    Enable Biometric
                      ↓               ↓
                  Home Content   Save Preference
                      ↓               ↓
                 [Next Launch]   [Next Launch]
                      ↓               ↓
                Setup Prompt ←  Biometric Auth
                      ↓               ↓
                 Home Content   Success → Home
                                 ↓
                            3 Fails → Firebase Login
```

## 📱 **Security & Storage Strategy**

### Data Storage:
- `shared_preferences`: Store biometric setup status (boolean)
- `local_auth`: Handle all biometric authentication natively
- Firebase session: Automatic session persistence
- **No custom PIN required** - use device's native security

### Security Flow:
1. **First Time**: Firebase login → biometric setup prompt
2. **Returning**: Check biometric status → authenticate or setup
3. **Fallback**: Failed biometric → Firebase re-authentication

## ✅ **Acceptance Criteria**

- [ ] Firebase authentication working
- [ ] Biometric setup prompt after first login
- [ ] Native biometric authentication (fingerprint/Face ID/device PIN)
- [ ] Preference storage for biometric status
- [ ] Proper fallback to Firebase login on failures
- [ ] Password reset flow complete
- [ ] Works on Android & iOS
- [ ] Clean Material 3 UI
- [ ] Graceful handling when device has no biometric support

## 🚀 **Key Changes from Original Plan**

1. **Removed Custom PIN**: Use device's native biometric/PIN instead
2. **Simplified Storage**: Only store biometric preference, not sensitive data
3. **Native Integration**: Leverage `local_auth` for all biometric handling
4. **Better UX**: Setup prompt appears naturally after first successful login
5. **Flexible Fallback**: Always allow Firebase re-authentication as backup

## 📱 **Screen Structure**

1. **Login Screen** - Firebase auth
2. **Home Screen** - Main content + biometric setup prompt (first time)
3. **Biometric Setup** - Native biometric enrollment prompt
4. **Biometric Auth** - Native authentication prompt (returning users)
5. **Settings** - Allow biometric toggle/setup later

**Timeline:** ~3-4 days  
**Platform:** Flutter (Android & iOS)  
**Type:** Demo/Portfolio Project

This approach is much cleaner and leverages native device security features while maintaining a smooth user experience!