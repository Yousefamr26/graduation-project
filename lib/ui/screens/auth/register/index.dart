// lib/ui/screens/auth/register/index.dart
// Export all registration-related screens and forms

export 'register_screen.dart';
export 'graduate_register_form.dart';
export 'student_register_form.dart';
export 'training_center_register_form.dart';
export 'university_register_form.dart';
export 'company_register_form.dart'; // ✅ FIXED: was missing from exports

/// Complete Registration System
///
/// Import this file to access all registration components:
///
/// ```dart
/// import 'package:SmartCareerHub/ui/screens/auth/register/index.dart';
///
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => const RegisterScreen()),
/// );
/// ```
///
/// Supported user types:
///   - student        → StudentAuth/register
///   - graduate       → GraduateAuth/register
///   - company        → CompanyAuth/register
///   - university     → UniversityAuth/register
///   - training_center → TrainingCenterAuth/register
// ✅ FIXED: removed duplicate `export 'register_screen.dart'` that was at the bottom