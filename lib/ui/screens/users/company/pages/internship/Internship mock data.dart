// ============================================================
// 📁 internship_mock_data.dart
// بيانات وهمية للـ Internships — ديناميكية تتأثر بأي Create/Edit/Delete
// ============================================================

import '../../../../../../data/models/company/internship-model.dart';

class InternshipMockData {
  // ✅ Static mutable list — بتتعدل في الـ runtime
  static final List<InternshipModel> _internships = [
    // ─── Internship 1 — Published / On-site ────────────────
    InternshipModel(
      id: 'intern-001',
      title: 'Flutter Mobile Developer Intern',
      description:
      'Join our mobile team and gain hands-on experience building real Flutter apps used by thousands of users. You will work alongside senior engineers on feature development, bug fixes, and UI improvements.',
      companyName: 'TechCorp Solutions',
      logoPath: null,
      type: 'On-site 🏢',
      location: 'Cairo, Egypt',
      isPaid: true,
      duration: '3 months',
      maxTrainees: 5,
      skills: ['Flutter', 'Dart', 'Firebase', 'Git'],
      requirements: [
        'Basic knowledge of Flutter or any mobile framework',
        'Familiarity with OOP concepts',
        'Good communication skills',
        'Ability to work in a team',
      ],
      postedDate: '2025-01-10',
      deadline: '2025-03-31',
      applicantsCount: 34,
      status: 'Published',
      isFeatured: true,
    ),

    // ─── Internship 2 — Published / Remote ─────────────────
    InternshipModel(
      id: 'intern-002',
      title: 'Backend Node.js Intern',
      description:
      'Work remotely with our backend team to develop and maintain APIs using Node.js and MongoDB. Great opportunity to learn industry best practices in API design and database management.',
      companyName: 'CloudBase Inc.',
      logoPath: null,
      type: 'Remote 🌐',
      location: '',
      isPaid: true,
      duration: '2 months',
      maxTrainees: 3,
      skills: ['Node.js', 'Express', 'MongoDB', 'REST API'],
      requirements: [
        'Knowledge of JavaScript fundamentals',
        'Basic understanding of REST APIs',
        'Familiarity with databases (SQL or NoSQL)',
      ],
      postedDate: '2025-01-20',
      deadline: '2025-04-15',
      applicantsCount: 21,
      status: 'Published',
      isFeatured: false,
    ),

    // ─── Internship 3 — Draft / Hybrid ─────────────────────
    InternshipModel(
      id: 'intern-003',
      title: 'UI/UX Design Intern',
      description:
      'Help our design team create beautiful and user-friendly interfaces using Figma. You will participate in design sprints, user research sessions, and prototype testing.',
      companyName: 'DesignHub',
      logoPath: null,
      type: 'Hybrid 🔄',
      location: 'Alexandria, Egypt',
      isPaid: false,
      duration: '1 month',
      maxTrainees: 2,
      skills: ['Figma', 'Adobe XD', 'Prototyping', 'User Research'],
      requirements: [
        'Portfolio showing design projects',
        'Proficiency in Figma or Adobe XD',
        'Understanding of design principles',
      ],
      postedDate: '2025-02-01',
      deadline: '2025-05-01',
      applicantsCount: 0,
      status: 'Draft',
      isFeatured: false,
    ),

    // ─── Internship 4 — Closed / Remote ────────────────────
    InternshipModel(
      id: 'intern-004',
      title: 'Data Science Intern',
      description:
      'Analyze real business datasets, build machine learning models, and create dashboards to support data-driven decisions. A perfect opportunity for students passionate about AI and data.',
      companyName: 'DataVision',
      logoPath: null,
      type: 'Remote 🌐',
      location: '',
      isPaid: true,
      duration: '6 months',
      maxTrainees: 4,
      skills: ['Python', 'Pandas', 'Scikit-learn', 'SQL', 'Matplotlib'],
      requirements: [
        'Proficiency in Python',
        'Knowledge of statistics and probability',
        'Experience with data manipulation libraries',
        'Strong analytical thinking',
      ],
      postedDate: '2024-10-01',
      deadline: '2025-01-15',
      applicantsCount: 58,
      status: 'Closed',
      isFeatured: false,
    ),
  ];

  // ✅ Read — بترجع نسخة من الـ list
  static List<InternshipModel> getInternships() {
    return List<InternshipModel>.from(_internships);
  }

  // ✅ Create — ضيف internship جديد
  static void addInternship(InternshipModel internship) {
    _internships.add(internship);
  }

  // ✅ Update — عدّل internship بالـ id
  static bool updateInternship(String? id, InternshipModel updated) {
    if (id == null) return false;
    final index = _internships.indexWhere((i) => i.id == id);
    if (index == -1) return false;
    _internships[index] = updated;
    return true;
  }

  // ✅ Delete — احذف internship بالـ id
  static bool removeInternship(String? id) {
    if (id == null) return false;
    final index = _internships.indexWhere((i) => i.id == id);
    if (index == -1) return false;
    _internships.removeAt(index);
    return true;
  }

  // ✅ Helper — ولّد ID وهمي فريد
  static String generateMockId() {
    return 'intern-${DateTime.now().millisecondsSinceEpoch}';
  }
}