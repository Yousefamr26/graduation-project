// ============================================================
// 📁 Mock data.dart
// بيانات وهمية للتجربة قبل ربط الـ Backend
// ✅ Dynamic: بيتأثر بأي Create / Edit في الـ runtime
// ============================================================

class RoadmapMockData {
  // ✅ Static mutable list — بتتعدل في الـ runtime
  static final List<Map<String, dynamic>> _roadmaps = [
    // ─── Roadmap 1 — Free + Published ───────────────────
    {
      "id": "mock-001",
      "title": "Flutter Developer Roadmap",
      "description":
      "A complete roadmap to become a professional Flutter developer from scratch to advanced level.",
      "targetRole": "Graduate",
      "target": ["Graduate"],
      "coverImage": null,
      "status": "Published",
      "isPublished": true,
      "isFree": true,
      "price": null,
      "startDate": "2025-01-01",
      "endDate": "2025-06-30",
      "date": "2024-12-15T10:00:00Z",
      "enrolled": 128,
      "completion": 74,
      "skills": [
        {"id": "s1", "name": "Dart Programming", "level": "Beginner",     "points": 100},
        {"id": "s2", "name": "Flutter Widgets",  "level": "Intermediate", "points": 150},
        {"id": "s3", "name": "State Management", "level": "Advanced",     "points": 200},
        {"id": "s4", "name": "REST APIs",        "level": "Intermediate", "points": 120},
      ],
      "learningMaterials": [
        {"id": "lm1", "title": "Dart Basics",             "type": "Video", "duration": "Medium", "points": 50, "filePath": null},
        {"id": "lm2", "title": "Flutter UI Fundamentals", "type": "Video", "duration": "Long",   "points": 80, "filePath": null},
        {"id": "lm3", "title": "State Management Guide",  "type": "PDF",   "duration": "Short",  "points": 40, "filePath": null},
      ],
      "materials": [],
      "videos": [],
      "projects": [
        {"id": "p1", "title": "Todo App",       "description": "Build a complete todo app with local storage",      "difficulty": "Easy", "points": 100},
        {"id": "p2", "title": "E-Commerce App", "description": "Build a full e-commerce app with cart and payment", "difficulty": "Hard", "points": 300},
      ],
      "quizzes": [
        {
          "id": "q1",
          "title": "Dart Basics Quiz",
          "type": "MCQ",
          "points": 50,
          "questions": [
            {"id": "qq1", "text": "What is Dart?",           "type": "MCQ",       "options": ["A language", "A framework", "A library", "An OS"], "correctAnswer": "A language", "points": 10},
            {"id": "qq2", "text": "Is Flutter open source?", "type": "TrueFalse", "options": ["True", "False"],                                   "correctAnswer": "True",       "points": 10},
          ],
        },
        {
          "id": "q2",
          "title": "Flutter Widgets Quiz",
          "type": "MCQ",
          "points": 60,
          "questions": [
            {"id": "qq3", "text": "Which widget is used for scrolling?", "type": "MCQ", "options": ["ListView", "Container", "Row", "Stack"], "correctAnswer": "ListView", "points": 15},
          ],
        },
      ],
    },

    // ─── Roadmap 2 — Paid + Published ───────────────────
    {
      "id": "mock-002",
      "title": "Backend Development with Node.js",
      "description":
      "Master backend development using Node.js, Express, and MongoDB for building scalable APIs.",
      "targetRole": "Student",
      "target": ["Student"],
      "coverImage": null,
      "status": "Published",
      "isPublished": true,
      "isFree": false,
      "price": 49.99,
      "startDate": "2025-02-01",
      "endDate": "2025-07-31",
      "date": "2024-12-20T08:00:00Z",
      "enrolled": 85,
      "completion": 60,
      "skills": [
        {"id": "s5", "name": "JavaScript",           "level": "Intermediate", "points": 150},
        {"id": "s6", "name": "Node.js",              "level": "Intermediate", "points": 180},
        {"id": "s7", "name": "MongoDB",              "level": "Beginner",     "points": 120},
        {"id": "s8", "name": "REST API Design",      "level": "Advanced",     "points": 200},
        {"id": "s9", "name": "Authentication & JWT", "level": "Advanced",     "points": 180},
      ],
      "learningMaterials": [
        {"id": "lm4", "title": "Node.js Crash Course",        "type": "Video", "duration": "Long",   "points": 80, "filePath": null},
        {"id": "lm5", "title": "MongoDB Fundamentals",        "type": "Video", "duration": "Medium", "points": 60, "filePath": null},
        {"id": "lm6", "title": "API Security Best Practices", "type": "PDF",   "duration": "Short",  "points": 30, "filePath": null},
      ],
      "materials": [],
      "videos": [],
      "projects": [
        {"id": "p3", "title": "REST API for Blog", "description": "Create a full CRUD API for a blog application",   "difficulty": "Medium", "points": 150},
        {"id": "p4", "title": "Auth System",       "description": "Build a complete authentication system with JWT", "difficulty": "Hard",   "points": 250},
      ],
      "quizzes": [
        {
          "id": "q3",
          "title": "Node.js Concepts",
          "type": "MCQ",
          "points": 70,
          "questions": [
            {"id": "qq4", "text": "What is the event loop in Node.js?", "type": "MCQ", "options": ["A loop for events", "Single-threaded mechanism", "A database loop", "None"], "correctAnswer": "Single-threaded mechanism", "points": 20},
          ],
        },
      ],
    },

    // ─── Roadmap 3 — Paid + Draft ────────────────────────
    {
      "id": "mock-003",
      "title": "UI/UX Design Fundamentals",
      "description":
      "Learn the principles of user interface and user experience design using Figma and industry best practices.",
      "targetRole": "Both",
      "target": ["Both"],
      "coverImage": null,
      "status": "Draft",
      "isPublished": false,
      "isFree": false,
      "price": 29.99,
      "startDate": "2025-03-01",
      "endDate": "2025-05-31",
      "date": "2025-01-05T12:00:00Z",
      "enrolled": 0,
      "completion": 0,
      "skills": [
        {"id": "s10", "name": "Figma",        "level": "Beginner",     "points": 100},
        {"id": "s11", "name": "Color Theory", "level": "Beginner",     "points": 80},
        {"id": "s12", "name": "Prototyping",  "level": "Intermediate", "points": 140},
      ],
      "learningMaterials": [
        {"id": "lm7", "title": "Figma Basics",   "type": "Video", "duration": "Medium", "points": 60, "filePath": null},
        {"id": "lm8", "title": "Design Systems", "type": "PDF",   "duration": "Short",  "points": 30, "filePath": null},
      ],
      "materials": [],
      "videos": [],
      "projects": [
        {"id": "p5", "title": "Mobile App Redesign", "description": "Redesign an existing mobile app with better UX", "difficulty": "Medium", "points": 200},
      ],
      "quizzes": [
        {
          "id": "q4",
          "title": "Design Principles Quiz",
          "type": "MCQ",
          "points": 40,
          "questions": [
            {"id": "qq5", "text": "What does UX stand for?", "type": "MCQ", "options": ["User Experience", "User Exam", "Ultra Experience", "Unique Exchange"], "correctAnswer": "User Experience", "points": 10},
          ],
        },
      ],
    },

    // ─── Roadmap 4 — Free + Draft ────────────────────────
    {
      "id": "mock-004",
      "title": "Python for Data Science",
      "description":
      "Explore Python programming with a focus on data analysis, visualization, and machine learning basics.",
      "targetRole": "Student",
      "target": ["Student"],
      "coverImage": null,
      "status": "Draft",
      "isPublished": false,
      "isFree": true,
      "price": null,
      "startDate": "2025-04-01",
      "endDate": "2025-09-30",
      "date": "2025-01-10T09:00:00Z",
      "enrolled": 0,
      "completion": 0,
      "skills": [
        {"id": "s13", "name": "Python Basics", "level": "Beginner",     "points": 100},
        {"id": "s14", "name": "Pandas",        "level": "Intermediate", "points": 150},
        {"id": "s15", "name": "Matplotlib",    "level": "Beginner",     "points": 80},
        {"id": "s16", "name": "Scikit-learn",  "level": "Advanced",     "points": 220},
      ],
      "learningMaterials": [
        {"id": "lm9",  "title": "Python Crash Course",        "type": "Video", "duration": "Long",   "points": 90, "filePath": null},
        {"id": "lm10", "title": "Data Wrangling with Pandas", "type": "Video", "duration": "Medium", "points": 70, "filePath": null},
        {"id": "lm11", "title": "ML Cheat Sheet",             "type": "PDF",   "duration": "Short",  "points": 20, "filePath": null},
      ],
      "materials": [],
      "videos": [],
      "projects": [
        {"id": "p6", "title": "Sales Data Analysis", "description": "Analyze a real sales dataset and create visualizations", "difficulty": "Medium", "points": 180},
        {"id": "p7", "title": "ML Classifier",       "description": "Build a simple classification model using Scikit-learn",  "difficulty": "Hard",   "points": 280},
      ],
      "quizzes": [
        {
          "id": "q5",
          "title": "Python Basics Quiz",
          "type": "MCQ",
          "points": 45,
          "questions": [
            {"id": "qq6", "text": "Which library is used for data manipulation?", "type": "MCQ",       "options": ["Pandas", "NumPy", "Matplotlib", "Flask"], "correctAnswer": "Pandas", "points": 15},
            {"id": "qq7", "text": "Python is an interpreted language.",           "type": "TrueFalse", "options": ["True", "False"],                          "correctAnswer": "True",   "points": 15},
          ],
        },
      ],
    },
  ];

  // ✅ Read: جيب كل الـ roadmaps (نسخة جديدة عشان ما تتعدلش الـ original list)
  static List<Map<String, dynamic>> getRoadmaps() {
    return List<Map<String, dynamic>>.from(_roadmaps);
  }

  // ✅ Create: ضيف roadmap جديد للـ list
  static void addRoadmap(Map<String, dynamic> roadmap) {
    _roadmaps.add(roadmap);
  }

  // ✅ Update: عدّل roadmap موجود بالـ id
  static bool updateRoadmap(String id, Map<String, dynamic> updatedData) {
    final index = _roadmaps.indexWhere((r) => r['id']?.toString() == id);
    if (index == -1) return false;

    // احتفظ بالبيانات الـ read-only زي enrolled و completion
    final existing = _roadmaps[index];
    _roadmaps[index] = {
      ...existing,       // ابدأ بالبيانات القديمة
      ...updatedData,    // override بالبيانات الجديدة
      // ✅ احتفظ بالقيم دي من الـ original
      "enrolled":   existing['enrolled']   ?? 0,
      "completion": existing['completion'] ?? 0,
      "date":       existing['date']       ?? updatedData['date'],
    };
    return true;
  }

  // ✅ Delete: احذف roadmap بالـ id (مش مستخدمة دلوقتي، موجودة للمستقبل)
  static bool removeRoadmap(String id) {
    final index = _roadmaps.indexWhere((r) => r['id']?.toString() == id);
    if (index == -1) return false;
    _roadmaps.removeAt(index);
    return true;
  }

  // ✅ Helper: ولّد ID وهمي فريد
  static String generateMockId() {
    return 'mock-${DateTime.now().millisecondsSinceEpoch}';
  }
}