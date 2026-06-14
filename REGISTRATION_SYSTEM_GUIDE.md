# 📋 Smart Career Hub - Registration System Documentation

## Overview
This registration system supports 4 user types with different registration requirements and endpoints:
- **Student** - Currently studying
- **Graduate** - Completed studies with experience
- **Training Center** - Educational organization
- **University** - Academic institution

---

## 🏗️ File Structure

```
lib/
├── ui/
│   └── screens/
│       └── auth/
│           └── register/
│               ├── register_screen.dart              # Main screen with user type selection
│               ├── graduate_register_form.dart       # Graduate registration form
│               ├── student_register_form.dart        # Student registration form
│               ├── training_center_register_form.dart # Training center form
│               └── university_register_form.dart     # University registration form
│
└── data/
    └── repositories/
        └── auth_repository.dart                     # API calls repository
```

---

## 🎯 User Type Selection

The main entry point is `RegisterScreen` which shows 4 options:
1. **Student** - For current students
2. **Graduate** - For job seekers with experience
3. **Training Center** - For training organizations
4. **University** - For educational institutions

Users can switch between forms using the **Back** button.

---

## 📝 Graduate Registration

**Endpoint:** `POST /api/GraduateAuth/register`

### Required Fields:
- ✅ Email
- ✅ Password (min 8 chars)
- ✅ First Name
- ✅ Last Name
- ✅ Country
- ✅ City
- ✅ Major (e.g., Computer Science)
- ✅ Degree (Bachelor, Master, PhD)
- ✅ University
- ✅ Graduation Year
- ✅ Years of Experience
- ✅ Experience Summary

### Optional Fields:
- 📎 GitHub Profile URL
- 📎 LinkedIn Profile URL
- 🖼️ Profile Image (jpg, png)

### Form Structure:
```
[Section 1] Basic Information
  - Email
  - First Name
  - Last Name
  - Password

[Section 2] Location
  - Country
  - City

[Section 3] Education
  - Major
  - Degree (dropdown)
  - University
  - Graduation Year

[Section 4] Experience
  - Years of Experience
  - Experience Summary

[Section 5] Optional Information
  - GitHub Profile
  - LinkedIn Profile
  - Profile Image Upload
```

---

## 👨‍🎓 Student Registration

**Endpoint:** `POST /api/StudentAuth/register`

### Required Fields:
- ✅ Email
- ✅ Password (min 8 chars)
- ✅ First Name
- ✅ Last Name
- ✅ Country
- ✅ City
- ✅ Major
- ✅ Degree (Diploma, Bachelor, Master)
- ✅ University
- ✅ Faculty (e.g., Engineering)
- ✅ Expected Graduation (YYYY-MM-DD)

### Optional Fields:
- 📎 GitHub Profile URL
- 📎 LinkedIn Profile URL
- 🖼️ Profile Image

### Form Structure:
```
[Section 1] Basic Information
  - Email
  - First Name
  - Last Name
  - Password

[Section 2] Location
  - Country
  - City

[Section 3] Education
  - Major
  - Degree (dropdown)
  - University
  - Faculty
  - Expected Graduation

[Section 4] Links
  - GitHub Profile
  - LinkedIn Profile
  - Profile Image Upload
```

---

## 🏢 Training Center Registration

**Endpoint:** `POST /api/trainingcenterauth/register`

### Required Fields:
- ✅ Organization Name
- ✅ Email
- ✅ Password (min 8 chars)
- ✅ Confirm Password (must match)
- ✅ Phone Number
- ✅ Country
- ✅ City
- ✅ Organization Logo

### Form Structure:
```
[Section 1] Organization Information
  - Organization Name
  - Email
  - Password
  - Confirm Password

[Section 2] Additional Information
  - Phone Number
  - Country
  - City

[Section 3] Organization Logo
  - Logo Upload
```

---

## 🎓 University Registration

**Endpoint:** `POST /api/UniversityAuth/register`

### Required Fields:
- ✅ University Name
- ✅ Email
- ✅ Password (min 8 chars)
- ✅ Confirm Password (must match)
- ✅ Phone Number
- ✅ Country
- ✅ City
- ✅ University Logo

### Form Structure:
```
[Section 1] University Information
  - University Name
  - Email
  - Password
  - Confirm Password

[Section 2] Contact Information
  - Phone Number
  - Country
  - City

[Section 3] University Logo
  - Logo Upload
```

---

## 🔌 API Integration

### AuthRepository (`auth_repository.dart`)

The repository handles all API calls with proper error handling.

#### Methods:

```dart
// Graduate Registration
Future<Response> registerGraduate({
  required String email,
  required String password,
  required String firstName,
  required String lastName,
  required String country,
  required String city,
  required String major,
  required String degree,
  required String university,
  required int graduationYear,
  required int yearsOfExperience,
  required String experienceSummary,
  String? github,
  String? linkedIn,
  File? profileImage,
})

// Student Registration
Future<Response> registerStudent({
  required String email,
  required String password,
  required String firstName,
  required String lastName,
  required String country,
  required String city,
  required String major,
  required String degree,
  required String university,
  required String faculty,
  required String expectedGraduation,
  String? github,
  String? linkedIn,
  File? profileImage,
})

// Training Center Registration
Future<Response> registerTrainingCenter({
  required String name,
  required String email,
  required String password,
  required String confirmPassword,
  required String phoneNumber,
  required String country,
  required String city,
  File? organizationLogo,
})

// University Registration
Future<Response> registerUniversity({
  required String name,
  required String email,
  required String password,
  required String confirmPassword,
  required String phoneNumber,
  required String country,
  required String city,
  File? organizationLogo,
})
```

#### Helper Methods:

```dart
// Check if response is successful
bool isSuccessResponse(Response response)

// Get error message from response
String getErrorMessage(Response response)
```

---

## 🛠️ Usage

### 1. Navigate to Registration Screen

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const RegisterScreen()),
);
```

### 2. User selects account type (Student/Graduate/Training Center/University)

### 3. Form is displayed based on selection

### 4. User fills all required fields

### 5. Submit registration

---

## ✅ Form Validation

All forms include:
- ✅ Required field validation
- ✅ Email validation
- ✅ Password strength validation (min 8 chars)
- ✅ Password confirmation matching (for org registration)
- ✅ Date format validation
- ✅ Number validation

---

## 🎨 UI Features

### Design System:
- **Primary Color:** `#1676C4` (Blue)
- **Font Size:** Responsive
- **Border Radius:** 12px (buttons), 12px (inputs)
- **Spacing:** Consistent 12-16px spacing

### Components:
- Custom TextField with validation
- Custom Dropdown
- Image upload with preview
- Loading indicator during submission
- SnackBar for success/error messages

---

## 📦 Dependencies Required

Add to `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.0.0
  image_picker: ^1.0.0
  intl: ^0.19.0
```

---

## 🚀 Next Steps

### To Implement:

1. **Update Navigation** in your app's main navigation/routing
2. **Update pubspec.yaml** if dependencies are missing
3. **Test each registration endpoint** with actual API
4. **Handle response tokens** - Save auth tokens after successful registration
5. **Add password reset flow** - Forgot password functionality
6. **Add email verification** - Send verification email after registration

---

## 🐛 Error Handling

The system handles:
- ✅ Network errors
- ✅ Server errors (4xx, 5xx)
- ✅ Form validation errors
- ✅ Image upload errors
- ✅ Timeout errors

All errors are displayed to the user via SnackBar.

---

## 📞 Support

For API endpoint details, check the Postman collection provided in the project files.

Last Updated: April 12, 2026

