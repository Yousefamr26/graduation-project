// ============================================================
// 📁 job_mock_data.dart
// بيانات وهمية للـ Jobs — ديناميكية تتأثر بأي Create/Edit/Delete
// ============================================================

import '../../../../../../data/models/company/job-model.dart';

class JobMockData {
  // ✅ Static mutable list — بتتعدل في الـ runtime
  static final List<JobModel> _jobs = [
    // ─── Job 1 — Published / Remote ────────────────────────
    JobModel(
      id: 'job-001',
      title: 'Senior Flutter Developer',
      description:
      'We are looking for an experienced Flutter developer to build high-quality cross-platform mobile apps. You will work closely with our design and backend teams.',
      logoPath: null,
      companyName: 'TechCorp Solutions',
      locationType: 'Remote',
      location: '',
      salaryMin: '\$80,000',
      salaryMax: '\$120,000',
      experienceLevel: 'Senior (5+ years)',
      requirements: [
        '5+ years of mobile development experience',
        'Strong knowledge of Flutter & Dart',
        'Experience with REST APIs and state management',
        'Good understanding of CI/CD pipelines',
      ],
      skills: ['Flutter', 'Dart', 'Firebase', 'REST API', 'Git'],
      employmentType: 'Full-time',
      postedDate: '2025-01-10',
      deadline: '2025-06-30',
      applicantsCount: 42,
      status: 'Published',
      isFeatured: true,
    ),

    // ─── Job 2 — Published / Hybrid ────────────────────────
    JobModel(
      id: 'job-002',
      title: 'Backend Engineer (Node.js)',
      description:
      'Join our engineering team to design and maintain scalable backend services using Node.js and MongoDB.',
      logoPath: null,
      companyName: 'CloudBase Inc.',
      locationType: 'Hybrid',
      location: 'Cairo, Egypt',
      salaryMin: '\$50,000',
      salaryMax: '\$75,000',
      experienceLevel: 'Mid-level (2-5 years)',
      requirements: [
        '3+ years with Node.js and Express',
        'Solid understanding of MongoDB and SQL',
        'Experience with microservices architecture',
      ],
      skills: ['Node.js', 'Express', 'MongoDB', 'Docker', 'AWS'],
      employmentType: 'Full-time',
      postedDate: '2025-01-15',
      deadline: '2025-05-31',
      applicantsCount: 28,
      status: 'Published',
      isFeatured: false,
    ),

    // ─── Job 3 — Draft / Onsite ─────────────────────────────
    JobModel(
      id: 'job-003',
      title: 'UI/UX Designer',
      description:
      'We need a creative designer to craft beautiful and intuitive interfaces for our web and mobile products using Figma.',
      logoPath: null,
      companyName: 'DesignHub',
      locationType: 'Onsite',
      location: 'Alexandria, Egypt',
      salaryMin: '\$30,000',
      salaryMax: '\$50,000',
      experienceLevel: 'Junior (0-2 years)',
      requirements: [
        'Portfolio showing UI/UX projects',
        'Proficiency in Figma or Adobe XD',
        'Understanding of user-centered design principles',
      ],
      skills: ['Figma', 'Adobe XD', 'Prototyping', 'User Research'],
      employmentType: 'Full-time',
      postedDate: '2025-02-01',
      deadline: '2025-04-30',
      applicantsCount: 0,
      status: 'Draft',
      isFeatured: false,
    ),

    // ─── Job 4 — Closed / Remote ────────────────────────────
    JobModel(
      id: 'job-004',
      title: 'Data Analyst',
      description:
      'Analyze business data and create dashboards and reports to support data-driven decision making across the company.',
      logoPath: null,
      companyName: 'DataVision',
      locationType: 'Remote',
      location: '',
      salaryMin: '\$45,000',
      salaryMax: '\$65,000',
      experienceLevel: 'Mid-level (2-5 years)',
      requirements: [
        'Proficiency in Python and SQL',
        'Experience with Tableau or Power BI',
        'Strong analytical and communication skills',
      ],
      skills: ['Python', 'SQL', 'Power BI', 'Excel', 'Pandas'],
      employmentType: 'Contract',
      postedDate: '2024-11-01',
      deadline: '2025-01-31',
      applicantsCount: 65,
      status: 'Closed',
      isFeatured: false,
    ),
  ];

  // ✅ Read — بترجع نسخة من الـ list
  static List<JobModel> getJobs() {
    return List<JobModel>.from(_jobs);
  }

  // ✅ Create — ضيف job جديد
  static void addJob(JobModel job) {
    _jobs.add(job);
  }

  // ✅ Update — عدّل job بالـ id
  static bool updateJob(String id, JobModel updatedJob) {
    final index = _jobs.indexWhere((j) => j.id == id);
    if (index == -1) return false;
    _jobs[index] = updatedJob;
    return true;
  }

  // ✅ Delete — احذف job بالـ id
  static bool removeJob(String id) {
    final index = _jobs.indexWhere((j) => j.id == id);
    if (index == -1) return false;
    _jobs.removeAt(index);
    return true;
  }

  // ✅ Helper — ولّد ID وهمي فريد
  static String generateMockId() {
    return 'job-${DateTime.now().millisecondsSinceEpoch}';
  }
}