import 'package:flutter/material.dart';
import 'company_register_form.dart';
import 'graduate_register_form.dart';
import 'student_register_form.dart';
import 'training_center_register_form.dart';
import 'university_register_form.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ✅ FIXED: default stays 'student', and 'instructor' tab removed —
  // the API has no InstructorAuth/register in Postman.
  // 'training_center' is now a proper tab with its own icon.
  String selectedUserType = 'student';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── User-type selector tabs ───────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: const Color(0xff1676C4).withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildIconSelector(
                    icon: Icons.school_outlined,
                    userType: 'student',
                    tooltip: 'Student',
                  ),
                  const SizedBox(width: 16),
                  _buildIconSelector(
                    icon: Icons.workspace_premium_outlined,
                    userType: 'graduate',
                    tooltip: 'Graduate',
                  ),
                  const SizedBox(width: 16),
                  _buildIconSelector(
                    icon: Icons.business_outlined,
                    userType: 'company',
                    tooltip: 'Company',
                  ),
                  const SizedBox(width: 16),
                  _buildIconSelector(
                    icon: Icons.account_balance_outlined,
                    userType: 'university',
                    tooltip: 'University',
                  ),
                  const SizedBox(width: 16),
                  // ✅ FIXED: was 'instructor' (no register endpoint) →
                  // now 'training_center' which has TrainingCenterAuth/register
                  _buildIconSelector(
                    icon: Icons.cast_for_education_outlined,
                    userType: 'training_center',
                    tooltip: 'Training Center',
                  ),
                ],
              ),
            ),
          ),
        ),
        // ── Form area ────────────────────────────────────────────────────────
        Expanded(
          child: _getFormWidget(),
        ),
      ],
    );
  }

  Widget _buildIconSelector({
    required IconData icon,
    required String userType,
    required String tooltip,
  }) {
    final isSelected = selectedUserType == userType;
    return GestureDetector(
      onTap: () => setState(() => selectedUserType = userType),
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xff1676C4)
                : const Color(0xff1676C4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xff1676C4),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : const Color(0xff1676C4),
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _getFormWidget() {
    // ✅ FIXED: titles and forms now match userType exactly
    final titles = {
      'student': 'Student Registration',
      'graduate': 'Graduate Registration',
      'company': 'Company Registration',
      'university': 'University Registration',
      'training_center': 'Training Center Registration',
    };

    Widget getForm() {
      switch (selectedUserType) {
        case 'graduate':
          return const GraduateRegisterForm();
        case 'student':
          return const StudentRegisterForm();
        case 'company':
          return const CompanyRegisterForm();
        case 'university':
          return const UniversityRegisterForm();
        case 'training_center':
          return const TrainingCenterRegisterForm();
        default:
          return const StudentRegisterForm();
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Text(
            titles[selectedUserType] ?? 'Registration',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff1676C4),
            ),
          ),
        ),
        Expanded(child: getForm()),
      ],
    );
  }
}