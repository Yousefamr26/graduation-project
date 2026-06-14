import 'package:flutter/material.dart';

class InternshipDetailsFromMap extends StatelessWidget {
  final Map<String, dynamic> internship;

  const InternshipDetailsFromMap({required this.internship, super.key});

  @override
  Widget build(BuildContext context) {
    final d = internship;
    final skills = List<String>.from(d['requiredSkills'] ?? []);
    final reqs = List<String>.from(d['requirements'] ?? []);
    final status = d['status'] ?? 'Published';
    final isPaid = d['isPaid'] ?? false;
    final type = d['type'] ?? '';
    final duration = d['duration'] ?? '';

    final statusColor = status == 'Published'
        ? Colors.green
        : status == 'Closed'
        ? Colors.grey
        : Colors.green; // Draft → يتعرض كـ Published

    final statusLabel = status == 'Closed' ? 'Closed' : 'Published';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Internship Details",
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff1676C4),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header card ─────────────────────────
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xff1676C4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.school,
                            color: Color(0xff1676C4), size: 30),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d['title'] ?? 'Untitled',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            if ((d['companyName'] ?? '').toString().isNotEmpty)
                              Text(d['companyName'].toString(),
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 13)),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(statusLabel,
                          style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Info chips ───────────────────────────
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  _infoRow(Icons.work_outline, "Type", type),
                  _infoRow(Icons.schedule, "Duration", duration),
                  _infoRow(
                    isPaid ? Icons.attach_money : Icons.money_off,
                    "Compensation",
                    isPaid ? "Paid" : "Unpaid",
                  ),
                  if ((d['location'] ?? '').toString().isNotEmpty)
                    _infoRow(Icons.location_on_outlined, "Location",
                        d['location'].toString()),
                ]),
              ),
            ),

            const SizedBox(height: 12),

            // ── Description ──────────────────────────
            if ((d['description'] ?? '').toString().isNotEmpty)
              _sectionCard(
                title: "Description",
                child: Text(d['description'].toString(),
                    style: TextStyle(
                        color: Colors.grey[800], fontSize: 14, height: 1.5)),
              ),

            if (skills.isNotEmpty) ...[
              const SizedBox(height: 12),
              _sectionCard(
                title: "Required Skills",
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills
                      .map((s) => Chip(
                    label: Text(s),
                    backgroundColor:
                    const Color(0xff1676C4).withOpacity(0.1),
                    labelStyle: const TextStyle(
                        color: Color(0xff1676C4),
                        fontWeight: FontWeight.w600),
                  ))
                      .toList(),
                ),
              ),
            ],

            if (reqs.isNotEmpty) ...[
              const SizedBox(height: 12),
              _sectionCard(
                title: "Requirements",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: reqs
                      .map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("• ",
                            style:
                            TextStyle(color: Color(0xff1676C4))),
                        Expanded(
                            child: Text(r,
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 14))),
                      ],
                    ),
                  ))
                      .toList(),
                ),
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 20, color: const Color(0xff1676C4)),
        const SizedBox(width: 10),
        Text("$label: ",
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
        Expanded(
          child: Text(value,
              style: TextStyle(color: Colors.grey[700], fontSize: 14)),
        ),
      ]),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1676C4))),
            const Divider(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}