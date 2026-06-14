# 📌 API Examples - Request & Response Reference

## 🎖️ Graduate Registration Example

### Request
```
POST /api/GraduateAuth/register
Content-Type: multipart/form-data

email: "ahmed@example.com"
password: "SecurePass123!"
firstName: "Ahmed"
lastName: "Mohamed"
country: "Egypt"
city: "Cairo"
major: "Computer Science"
degree: "Bachelor"
university: "Cairo University"
graduationYear: 2020
yearsOfExperience: 3
experienceSummary: "Worked as Software Developer at TechCorp for 3 years"
GitHub: "https://github.com/ahmednull"
LinkedIn: "https://linkedin.com/in/ahmed"
ProfileImage: [file]
```

### Success Response (200)
```json
{
  "statusCode": 200,
  "message": "Graduate registered successfully",
  "success": true,
  "data": {
    "id": "grad-001",
    "email": "ahmed@example.com",
    "firstName": "Ahmed",
    "lastName": "Mohamed",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600,
    "profileImageUrl": "https://api.example.com/images/grad-001.jpg"
  }
}
```

### Error Response (400)
```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "success": false,
  "errors": {
    "email": "Email is already registered",
    "graduationYear": "Year must be in the past"
  }
}
```

---

## 👨‍🎓 Student Registration Example

### Request
```
POST /api/StudentAuth/register
Content-Type: multipart/form-data

email: "sara@example.com"
password: "SecurePass123!"
firstName: "Sara"
lastName: "Hassan"
country: "Egypt"
city: "Alexandria"
major: "Computer Engineering"
degree: "Bachelor"
university: "Alexandria University"
faculty: "Engineering"
expectedGraduation: "2025-06-15"
GitHub: "https://github.com/sarah"
LinkedIn: "https://linkedin.com/in/sara"
ProfileImage: [file]
```

### Success Response (200)
```json
{
  "statusCode": 200,
  "message": "Student registered successfully",
  "success": true,
  "data": {
    "id": "std-001",
    "email": "sara@example.com",
    "firstName": "Sara",
    "lastName": "Hassan",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600,
    "profileImageUrl": "https://api.example.com/images/std-001.jpg"
  }
}
```

### Error Response (400)
```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "success": false,
  "errors": {
    "expectedGraduation": "Expected graduation date must be in the future"
  }
}
```

---

## 🏢 Training Center Registration Example

### Request
```
POST /api/trainingcenterauth/register
Content-Type: multipart/form-data

name: "Tech Academy"
email: "info@techacademy.com"
password: "SecurePass123!"
confirmPassword: "SecurePass123!"
phoneNumber: "+20123456789"
country: "Egypt"
city: "Cairo"
OrganizationLogo: [file]
```

### Success Response (200)
```json
{
  "statusCode": 200,
  "message": "Training center registered successfully",
  "success": true,
  "data": {
    "id": "tc-001",
    "name": "Tech Academy",
    "email": "info@techacademy.com",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600,
    "logoUrl": "https://api.example.com/logos/tc-001.jpg"
  }
}
```

### Error Response (400)
```json
{
  "statusCode": 400,
  "message": "Registration failed",
  "success": false,
  "errors": {
    "email": "Email is already in use",
    "password": "Password confirmation does not match"
  }
}
```

---

## 🎓 University Registration Example

### Request
```
POST /api/UniversityAuth/register
Content-Type: multipart/form-data

name: "Cairo University"
email: "admissions@cu.edu.eg"
password: "SecurePass123!"
confirmPassword: "SecurePass123!"
phoneNumber: "+20227357131"
country: "Egypt"
city: "Cairo"
OrganizationLogo: [file]
```

### Success Response (200)
```json
{
  "statusCode": 200,
  "message": "University registered successfully",
  "success": true,
  "data": {
    "id": "uni-001",
    "name": "Cairo University",
    "email": "admissions@cu.edu.eg",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600,
    "logoUrl": "https://api.example.com/logos/uni-001.jpg"
  }
}
```

### Error Response (409 - Conflict)
```json
{
  "statusCode": 409,
  "message": "Email already exists",
  "success": false,
  "error": "A university with this email is already registered"
}
```

---

## 🚨 Common Error Responses

### 400 - Bad Request
```json
{
  "statusCode": 400,
  "message": "Bad request",
  "success": false,
  "errors": {
    "email": "Invalid email format",
    "password": "Password must be at least 8 characters"
  }
}
```

### 401 - Unauthorized
```json
{
  "statusCode": 401,
  "message": "Unauthorized",
  "success": false,
  "error": "Invalid credentials"
}
```

### 409 - Conflict
```json
{
  "statusCode": 409,
  "message": "Resource already exists",
  "success": false,
  "error": "Email is already registered"
}
```

### 413 - Payload Too Large
```json
{
  "statusCode": 413,
  "message": "File too large",
  "success": false,
  "error": "Image size must not exceed 5MB"
}
```

### 422 - Unprocessable Entity
```json
{
  "statusCode": 422,
  "message": "Validation error",
  "success": false,
  "errors": {
    "field1": ["Error message 1"],
    "field2": ["Error message 2"]
  }
}
```

### 500 - Internal Server Error
```json
{
  "statusCode": 500,
  "message": "Internal server error",
  "success": false,
  "error": "An unexpected error occurred"
}
```

---

## 📝 Dart Code Examples

### Graduate Registration Call
```dart
final authRepo = AuthRepository();

try {
  final response = await authRepo.registerGraduate(
    email: 'ahmed@example.com',
    password: 'SecurePass123!',
    firstName: 'Ahmed',
    lastName: 'Mohamed',
    country: 'Egypt',
    city: 'Cairo',
    major: 'Computer Science',
    degree: 'Bachelor',
    university: 'Cairo University',
    graduationYear: 2020,
    yearsOfExperience: 3,
    experienceSummary: 'Worked as Software Developer at TechCorp for 3 years',
    github: 'https://github.com/ahmednull',
    linkedIn: 'https://linkedin.com/in/ahmed',
    profileImage: imageFile,
  );

  if (authRepo.isSuccessResponse(response)) {
    // Extract data
    final data = response.data['data'];
    final token = data['token'];
    
    // Save token
    await _saveToken(token);
    
    // Navigate
    Navigator.pushReplacementNamed(context, '/home');
  } else {
    // Show error
    final error = authRepo.getErrorMessage(response);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.red),
    );
  }
} catch (e) {
  debugPrint('Error: $e');
}
```

### Handling Token Response
```dart
Future<void> _handleSuccessfulRegistration(Response response) async {
  final data = response.data['data'];
  
  // Extract tokens
  final accessToken = data['token'];
  final refreshToken = data['refreshToken'];
  final expiresIn = data['expiresIn'] ?? 3600;
  
  // Save tokens
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('access_token', accessToken);
  await prefs.setString('refresh_token', refreshToken);
  await prefs.setInt('token_expires_in', expiresIn);
  
  // Set Dio authorization header
  _dio.options.headers['Authorization'] = 'Bearer $accessToken';
  
  // Navigate to home
  Navigator.pushReplacementNamed(context, '/home');
}
```

### Error Response Handling
```dart
Future<void> _handleErrorResponse(Response response) async {
  final statusCode = response.statusCode;
  final data = response.data;
  
  String errorMessage = 'An error occurred';
  
  // Extract error message
  if (data is Map) {
    if (data['message'] != null) {
      errorMessage = data['message'];
    } else if (data['errors'] is Map) {
      // Format validation errors
      final errors = data['errors'] as Map;
      errorMessage = errors.values.join('\n');
    }
  }
  
  // Show error based on status code
  switch (statusCode) {
    case 400:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Validation error: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
      break;
    case 409:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This email is already registered'),
          backgroundColor: Colors.orange,
        ),
      );
      break;
    case 413:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File size is too large'),
          backgroundColor: Colors.red,
        ),
      );
      break;
    default:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
  }
}
```

---

## 🔐 Authentication Token Usage

### After Successful Registration

1. **Save Token**
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('token', response.data['data']['token']);
```

2. **Use Token in Subsequent Requests**
```dart
_dio.options.headers['Authorization'] = 'Bearer $token';
```

3. **Refresh Token When Expired**
```dart
Future<String?> refreshToken() async {
  try {
    final response = await _dio.post(
      '/auth/refresh',
      data: {'refreshToken': oldToken},
    );
    
    if (response.statusCode == 200) {
      final newToken = response.data['token'];
      await prefs.setString('token', newToken);
      _dio.options.headers['Authorization'] = 'Bearer $newToken';
      return newToken;
    }
  } catch (e) {
    // Handle refresh error - logout user
    await logout();
  }
  return null;
}
```

---

## 📊 Response Status Codes

| Code | Status | Meaning |
|------|--------|---------|
| 200 | OK | Registration successful |
| 201 | Created | Resource created |
| 400 | Bad Request | Validation error |
| 401 | Unauthorized | Invalid credentials |
| 409 | Conflict | Email already exists |
| 413 | Payload Too Large | File too large |
| 422 | Unprocessable | Validation failed |
| 500 | Internal Error | Server error |

---

## 🧪 Testing the API

### Using Postman

1. **Create Request**
   - Method: POST
   - URL: `http://smartcareerhub.runasp.net/api/GraduateAuth/register`
   - Body: form-data

2. **Add Form Fields**
   - email: test@example.com
   - password: TestPass123!
   - firstName: John
   - lastName: Doe
   - [... other fields]

3. **Add File**
   - ProfileImage: (select file)

4. **Send Request**
   - View response
   - Check headers
   - Validate token

---

## 💾 Database Schema (Expected)

### Graduate User
```sql
CREATE TABLE Graduates (
  id INT PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  passwordHash VARCHAR(255) NOT NULL,
  firstName VARCHAR(100) NOT NULL,
  lastName VARCHAR(100) NOT NULL,
  country VARCHAR(100),
  city VARCHAR(100),
  major VARCHAR(100),
  degree VARCHAR(50),
  university VARCHAR(255),
  graduationYear INT,
  yearsOfExperience INT,
  experienceSummary TEXT,
  github VARCHAR(255),
  linkedin VARCHAR(255),
  profileImageUrl VARCHAR(255),
  createdAt DATETIME,
  updatedAt DATETIME
);
```

---

## 🚀 Integration Checklist

- [ ] Create registration forms ✅
- [ ] Implement API repository ✅
- [ ] Handle success responses ✅
- [ ] Handle error responses ✅
- [ ] Save authentication token ✅
- [ ] Set authorization headers ✅
- [ ] Implement token refresh ✅
- [ ] Redirect on success ✅
- [ ] Show validation errors ✅
- [ ] Handle network errors ✅

---

*API Examples Generated: April 12, 2026*

