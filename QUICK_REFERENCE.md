# 🚀 QUICK REFERENCE - Registration System

## Import Statement
```dart
import 'package:SmartCareerHub/ui/screens/auth/register/index.dart';
```

## Quick Navigation
```dart
// Navigate to registration screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const RegisterScreen()),
);

// Or using named routes
Navigator.pushNamed(context, '/register');
```

---

## 📝 Form Summary

| User Type | Endpoint | Fields | Image | Required |
|-----------|----------|--------|-------|----------|
| 🎖️ Graduate | `/api/GraduateAuth/register` | 14 | Yes | 12/14 |
| 👨‍🎓 Student | `/api/StudentAuth/register` | 13 | Yes | 11/13 |
| 🏢 Training Center | `/api/trainingcenterauth/register` | 8 | Yes | 8/8 |
| 🎓 University | `/api/UniversityAuth/register` | 8 | Yes | 8/8 |

---

## 🔌 API Call Example

```dart
final authRepo = AuthRepository();

// Graduate Registration
final response = await authRepo.registerGraduate(
  email: 'user@example.com',
  password: 'SecurePass123!',
  firstName: 'John',
  lastName: 'Doe',
  country: 'Egypt',
  city: 'Cairo',
  major: 'Computer Science',
  degree: 'Bachelor',
  university: 'Cairo University',
  graduationYear: 2020,
  yearsOfExperience: 3,
  experienceSummary: 'Senior Developer',
  profileImage: imageFile,
);

// Handle Response
if (authRepo.isSuccessResponse(response)) {
  final token = response.data['data']['token'];
  // Save token and navigate
} else {
  final error = authRepo.getErrorMessage(response);
  // Show error message
}
```

---

## 📂 File Structure

```
lib/ui/screens/auth/register/
├── register_screen.dart                    # Main screen
├── graduate_register_form.dart             # Graduate form
├── student_register_form.dart              # Student form
├── training_center_register_form.dart      # TC form
├── university_register_form.dart           # University form
└── index.dart                              # Exports

lib/data/repositories/
└── auth_repository.dart                    # API layer
```

---

## 🎨 Colors

```dart
const Color primary = Color(0xff1676C4);    // Blue
const Color error = Color(0xFFFF4444);      // Red
const Color success = Color(0xFF00AA00);    // Green
```

---

## 📋 Dependencies

```yaml
dio: ^5.0.0
image_picker: ^1.0.0
intl: ^0.19.0
```

---

## ✅ Form Validation

- Email: Valid format required
- Password: Minimum 8 characters
- Numbers: Valid integers only
- Dates: YYYY-MM-DD format
- Required fields: Cannot be empty

---

## 🔐 Password Toggle

Each password field includes eye icon for visibility toggle:
```dart
obscureText: _obscurePassword
// Toggle with: _obscurePassword = !_obscurePassword
```

---

## 📸 Image Upload

```dart
// Pick image
final pickedFile = await _imagePicker.pickImage(
  source: ImageSource.gallery,
);

// Upload with form
if (_profileImage != null) {
  'ProfileImage': await MultipartFile.fromFile(_profileImage!.path)
}
```

---

## 🔄 Error Handling

```dart
// Check if successful
if (authRepo.isSuccessResponse(response)) { }

// Extract error
final errorMsg = authRepo.getErrorMessage(response);
```

---

## 📱 Screen Sizes

- Mobile: 375x667 ✅
- Large Mobile: 414x896 ✅
- Tablet: 768x1024 ✅
- Landscape: Full width responsive ✅

---

## 💾 Save Token

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('auth_token', token);

// Use in requests
_dio.options.headers['Authorization'] = 'Bearer $token';
```

---

## 🧪 Test URLs

```
POST http://smartcareerhub.runasp.net/api/GraduateAuth/register
POST http://smartcareerhub.runasp.net/api/StudentAuth/register
POST http://smartcareerhub.runasp.net/api/trainingcenterauth/register
POST http://smartcareerhub.runasp.net/api/UniversityAuth/register
```

---

## 🚨 Common Errors

| Error | Solution |
|-------|----------|
| Image picker not working | Check permissions in manifest |
| API connection failed | Verify base URL |
| Form validation error | Check all required fields |
| Token not saved | Implement SharedPreferences |

---

## 📚 Documentation Files

- `REGISTRATION_SYSTEM_GUIDE.md` - Full documentation
- `SETUP_GUIDE.md` - Setup instructions
- `VISUAL_OVERVIEW.md` - UI diagrams
- `API_EXAMPLES.md` - Request/response examples
- `INTEGRATION_CHECKLIST.md` - Integration steps

---

## ⚡ Quick Setup

```bash
# 1. Add dependencies
flutter pub add dio image_picker intl

# 2. Add permissions to manifests

# 3. Update routes
routes: {
  '/register': (context) => const RegisterScreen(),
}

# 4. Navigate
Navigator.pushNamed(context, '/register');

# 5. Test all 4 user types
```

---

## 🎯 Key Methods

```dart
// In AuthRepository
registerGraduate(...)
registerStudent(...)
registerTrainingCenter(...)
registerUniversity(...)
isSuccessResponse(response)
getErrorMessage(response)
```

---

## 📊 Success Response

```json
{
  "statusCode": 200,
  "data": {
    "id": "user-id",
    "email": "user@example.com",
    "token": "jwt-token",
    "refreshToken": "refresh-token"
  }
}
```

---

## ❌ Error Response

```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "errors": {
    "email": "Email already exists"
  }
}
```

---

## 🔗 Related Screens

- LoginScreen: `/login`
- RegisterScreen: `/register` ← You are here
- HomeScreen: `/home`

---

## 🎉 Status

✅ Complete & Ready  
✅ Well Documented  
✅ Production Ready  
✅ API Integrated  

---

*For more details, see the full documentation files*

