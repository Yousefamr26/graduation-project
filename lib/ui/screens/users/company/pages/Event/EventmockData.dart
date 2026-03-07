// ============================================================
// 📁 event_mock_data.dart
// بيانات وهمية للـ Events — ديناميكية تتأثر بأي Create/Edit/Delete
// ============================================================

import '../../../../../../data/models/company/event-model.dart';

class EventMockData {
  // ✅ Static mutable list — بتتعدل في الـ runtime
  static final List<EventModel> _events = [
    // ─── Event 1 — Published / Onsite ──────────────────────
    EventModel(
      id: 'event-001',
      title: 'Vodafone Tech Tour',
      description:
      'An exclusive tour inside Vodafone headquarters to explore their tech infrastructure, meet engineers, and understand real-world telecom systems.',
      coverImagePath: null,
      type: 'Company Tour',
      mode: 'Onsite',
      location: 'Vodafone HQ, Cairo',
      startDate: '2025-03-10',
      endDate: '2025-03-10',
      startTime: '10:00 AM',
      endTime: '2:00 PM',
      minPoints: 500,
      eligibilityFilters: ['Completed Roadmap', 'High Technical Skills'],
      inviteOnly: true,
      eligibleStudents: 80,
      capacity: 50,
      allowWaitingList: true,
      sendAutoEmail: true,
      pointsAttendance: 100,
      pointsParticipation: 200,
      status: 'Published',
      date: '2025-01-15',
    ),

    // ─── Event 2 — Published / Online ──────────────────────
    EventModel(
      id: 'event-002',
      title: 'Flutter Workshop: Build Your First App',
      description:
      'A hands-on online workshop where participants will build a complete Flutter app from scratch, guided by senior Flutter engineers.',
      coverImagePath: null,
      type: 'Workshop',
      mode: 'Online',
      location: '',
      startDate: '2025-04-05',
      endDate: '2025-04-06',
      startTime: '9:00 AM',
      endTime: '5:00 PM',
      minPoints: 200,
      eligibilityFilters: ['≥50% Courses'],
      inviteOnly: false,
      eligibleStudents: 320,
      capacity: 200,
      allowWaitingList: true,
      sendAutoEmail: false,
      pointsAttendance: 50,
      pointsParticipation: 150,
      status: 'Published',
      date: '2025-01-20',
    ),

    // ─── Event 3 — Draft / Hybrid ───────────────────────────
    EventModel(
      id: 'event-003',
      title: 'AI & Machine Learning Bootcamp Preview',
      description:
      'A preview session for our upcoming AI bootcamp. Attendees will get a taste of the curriculum, meet instructors, and ask questions.',
      coverImagePath: null,
      type: 'Bootcamp Preview',
      mode: 'Hybrid',
      location: 'STEM University, Alexandria',
      startDate: '2025-05-01',
      endDate: '2025-05-01',
      startTime: '2:00 PM',
      endTime: '6:00 PM',
      minPoints: 0,
      eligibilityFilters: [],
      inviteOnly: false,
      eligibleStudents: 500,
      capacity: 150,
      allowWaitingList: false,
      sendAutoEmail: false,
      pointsAttendance: 30,
      pointsParticipation: 80,
      status: 'Draft',
      date: '2025-02-01',
    ),

    // ─── Event 4 — Published / Onsite ──────────────────────
    EventModel(
      id: 'event-004',
      title: 'Tech Networking Night',
      description:
      'An evening of networking with top tech professionals, recruiters, and fellow students. Connect, share ideas, and explore career opportunities.',
      coverImagePath: null,
      type: 'Networking Event',
      mode: 'Onsite',
      location: 'Grand Nile Tower, Cairo',
      startDate: '2025-03-25',
      endDate: '2025-03-25',
      startTime: '6:00 PM',
      endTime: '10:00 PM',
      minPoints: 300,
      eligibilityFilters: ['Top 20% Progress', 'High Communication Skills'],
      inviteOnly: true,
      eligibleStudents: 120,
      capacity: 100,
      allowWaitingList: false,
      sendAutoEmail: true,
      pointsAttendance: 75,
      pointsParticipation: 120,
      status: 'Published',
      date: '2025-01-28',
    ),
  ];

  // ✅ Read — بترجع نسخة من الـ list
  static List<EventModel> getEvents() {
    return List<EventModel>.from(_events);
  }

  // ✅ Create — ضيف event جديد
  static void addEvent(EventModel event) {
    _events.add(event);
  }

  // ✅ Update — عدّل event بالـ id
  static bool updateEvent(String? id, EventModel updatedEvent) {
    if (id == null) return false;
    final index = _events.indexWhere((e) => e.id == id);
    if (index == -1) return false;
    _events[index] = updatedEvent;
    return true;
  }

  // ✅ Delete — احذف event بالـ id
  static bool removeEvent(String? id) {
    if (id == null) return false;
    final index = _events.indexWhere((e) => e.id == id);
    if (index == -1) return false;
    _events.removeAt(index);
    return true;
  }

  // ✅ Helper — ولّد ID وهمي فريد
  static String generateMockId() {
    return 'event-${DateTime.now().millisecondsSinceEpoch}';
  }
}