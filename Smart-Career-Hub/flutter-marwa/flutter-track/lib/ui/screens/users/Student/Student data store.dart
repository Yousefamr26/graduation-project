class StudentDataStore {
  static final StudentDataStore _instance =
      StudentDataStore._internal();

  factory StudentDataStore() => _instance;

  StudentDataStore._internal();

  // ───────────────── ROADMAPS ─────────────────

  final List<Map<String, dynamic>> enrolledRoadmaps = [];

  void enrollRoadmap(Map<String, dynamic> roadmap) {
    if (!enrolledRoadmaps.any((r) => r['title'] == roadmap['title'])) {
      enrolledRoadmaps.add(Map<String, dynamic>.from(roadmap));
    }
  }

  void unenrollRoadmap(String title) {
    enrolledRoadmaps.removeWhere((r) => r['title'] == title);
  }

  bool isEnrolled(String title) {
    return enrolledRoadmaps.any((r) => r['title'] == title);
  }

  // ───────────────── EVENTS ─────────────────

  final List<Map<String, dynamic>> registeredEvents = [];

  void registerEvent(Map<String, dynamic> event) {
    if (!registeredEvents.any((e) => e['title'] == event['title'])) {
      registeredEvents.add(Map<String, dynamic>.from(event));
    }
  }

  void unregisterEvent(String title) {
    registeredEvents.removeWhere((e) => e['title'] == title);
  }

  bool isEventRegistered(String title) {
    return registeredEvents.any((e) => e['title'] == title);
  }

  // ───────────────── WORKSHOPS ─────────────────

  final List<Map<String, dynamic>> registeredWorkshops = [];

  void registerWorkshop(Map<String, dynamic> workshop) {
    if (!registeredWorkshops.any((w) => w['title'] == workshop['title'])) {
      registeredWorkshops.add(Map<String, dynamic>.from(workshop));
    }
  }

  void unregisterWorkshop(String title) {
    registeredWorkshops.removeWhere((w) => w['title'] == title);
  }

  bool isWorkshopRegistered(String title) {
    return registeredWorkshops.any((w) => w['title'] == title);
  }
}