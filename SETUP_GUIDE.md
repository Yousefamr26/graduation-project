# ⚡ Quick Setup Guide - Registration System

## Step 1: Check Dependencies

Verify these dependencies exist in your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.0.0
  image_picker: ^1.0.0
  intl: ^0.19.0
```

If missing, add them and run:
```bash
flutter pub get
```

---

## Step 2: Add Permissions (Android)

Edit `android/app/src/main/AndroidManifest.xml` and add:

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />
```

---

## Step 3: Add Permissions (iOS)

Edit `ios/Runner/Info.plist` and add:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library for profile images</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for profile pictures</string>
```

---

## Step 4: Update Your Routes

In your main app navigation file, add the route to RegisterScreen:

### Option A: Using Named Routes (Recommended)

In your routes configuration:

```dart
routes: {
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),  // ← Add this
  '/home': (context) => const HomeScreen(),
  // ... other routes
}
```

Then navigate using:
```dart
Navigator.pushNamed(context, '/register');
```

### Option B: Direct Navigation

```dart
import 'package:SmartCareerHub/ui/screens/auth/register/index.dart';

// Navigate to registration
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const RegisterScreen()),
);
```

---

## Step 5: Test the System

### Test Student Registration:
1. Launch the app
2. Navigate to RegisterScreen
3. Select "Student"
4. Fill all fields
5. Tap "REGISTER"

### Test Graduate Registration:
1. Select "Graduate"
2. Fill all fields including experience
3. Optionally upload profile image
4. Tap "REGISTER"

### Test Training Center Registration:
1. Select "Training Center"
2. Fill organization details
3. Upload organization logo
4. Tap "REGISTER"

### Test University Registration:
1. Select "University"
2. Fill university details
3. Upload university logo
4. Tap "REGISTER"

---

## Step 6: Handle Response

After successful registration, you should:

1. **Save the Auth Token** (if provided in response)
2. **Navigate to Home/Dashboard**
3. **Update User State** (using Provider, BLoC, etc.)

Example:

```dart
// In your registration form's _register() method
if (authRepo.isSuccessResponse(response)) {
  // Extract token if provided
  final token = response.data['token'];
  
  // Save token (example with shared_preferences)
  // await _saveToken(token);
  
  // Navigate to home
  Navigator.pushReplacementNamed(context, '/home');
} else {
  final error = authRepo.getErrorMessage(response);
  _showSnackBar(error, Colors.red);
}
```

---

## Step 7: Customize API Base URL (Optional)

Edit `lib/data/repositories/auth_repository.dart`:

```dart
// Change this URL
static const String _baseUrl = 'http://smartcareerhub.runasp.net/api';

// To your production URL
// static const String _baseUrl = 'https://your-production-api.com/api';
```

---

## Step 8: Add Loading Screen (Optional)

Enhance user experience by showing loading state:

```dart
// Add this to your RegisterScreen's build method
if (_isLoading) {
  return Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Creating your account...'),
        ],
      ),
    ),
  );
}
```

---

## Common Issues & Solutions

### ❌ Image Picker Not Working
**Solution:** Ensure permissions are added to AndroidManifest.xml and Info.plist

### ❌ API Connection Error
**Solution:** 
- Check internet connection
- Verify API base URL is correct
- Check firewall/proxy settings

### ❌ Form Validation Fails
**Solution:**
- Check all required fields (marked with *)
- Ensure password is minimum 8 characters
- Verify email format is correct

### ❌ File Upload Failed
**Solution:**
- Check image file size (keep under 5MB)
- Ensure file permissions are granted
- Verify file path is valid

---

## Environment Variables (Optional)

Create `.env` file in project root:

```
API_BASE_URL=http://smartcareerhub.runasp.net/api
API_TIMEOUT=30000
```

Then update auth_repository.dart:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

static const String _baseUrl = String.fromEnvironment('API_BASE_URL', 
  defaultValue: 'http://smartcareerhub.runasp.net/api');
```

---

## Production Checklist

Before deploying to production:

- [ ] Update API_BASE_URL to production URL
- [ ] Enable HTTPS/SSL
- [ ] Add request signing/authentication
- [ ] Implement error tracking (Sentry, Firebase Crashlytics)
- [ ] Add analytics logging
- [ ] Test with real API endpoints
- [ ] Implement rate limiting
- [ ] Add request caching
- [ ] Set up proper error logging
- [ ] Test on multiple devices

---

## API Response Handling

### Success Response (2xx)
```json
{
  "statusCode": 200,
  "message": "Registration successful",
  "data": {
    "id": "user-id",
    "email": "user@example.com",
    "token": "jwt-token-here",
    "refreshToken": "refresh-token"
  }
}
```

### Error Response (4xx, 5xx)
```json
{
  "statusCode": 400,
  "message": "Invalid email format",
  "errors": {
    "email": "Email is already registered"
  }
}
```

---

## Integration Example

Complete example of integrating with your app:

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:SmartCareerHub/ui/screens/auth/register/index.dart';
import 'package:SmartCareerHub/ui/screens/login/login_screen.dart';
import 'package:SmartCareerHub/ui/screens/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Career Hub',
      theme: ThemeData(
        primaryColor: const Color(0xff1676C4),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),  // ← Add this
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
```

---

## Firebase Analytics Integration (Optional)

Track registration events:

```dart
Future<void> _register() async {
  // ... existing code ...
  
  try {
    final authRepo = AuthRepository();
    final response = await authRepo.registerGraduate(...);

    if (authRepo.isSuccessResponse(response)) {
      // Track successful registration
      // await FirebaseAnalytics.instance.logSignUp(
      //   signUpMethod: 'graduate_registration',
      // );
      
      Navigator.pop(context);
    }
  } catch (e) {
    // Track registration error
    // await FirebaseAnalytics.instance.logEvent(
    //   name: 'registration_error',
    //   parameters: {'error': e.toString()},
    // );
  }
}
```

---

## Need Help?

- 📖 Check REGISTRATION_SYSTEM_GUIDE.md for detailed documentation
- 📋 Review individual form files for specific field mappings
- 🔧 Update auth_repository.dart for API customization
- 💬 Add logging with debugPrint() for debugging

---

## Summary

Your registration system is now ready to use! 🎉

### Files Created:
- ✅ register_screen.dart - User type selection
- ✅ graduate_register_form.dart - Graduate form
- ✅ student_register_form.dart - Student form
- ✅ training_center_register_form.dart - Training center form
- ✅ university_register_form.dart - University form
- ✅ auth_repository.dart - API integration
- ✅ REGISTRATION_SYSTEM_GUIDE.md - Complete documentation

### Next Steps:
1. Add dependencies ✅
2. Add permissions ✅
3. Update routes ✅
4. Test the system ✅
5. Deploy to production ✅

Happy coding! 🚀

