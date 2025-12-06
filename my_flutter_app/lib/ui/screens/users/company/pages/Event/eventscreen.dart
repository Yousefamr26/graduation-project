import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../../data/models/event-model.dart';
import '../../../../../widgets/CustomDropdown.dart';
import 'addnewevent.dart';
import 'eventhistory.dart';
import 'eventanalytics.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final List<EventModel> events = [];
  final List<EventModel> eventHistory = [];

  String searchText = "";
  String selectedFilter = "All";
  List<EventModel> filteredEvents = [];

  @override
  void initState() {
    super.initState();
    filteredEvents = events;
  }

  void applyFilters() {
    setState(() {
      filteredEvents = events.where((event) {
        final searchLower = searchText.toLowerCase();

        final matchesTitle = event.title.toLowerCase().contains(searchLower);
        final matchesDescription = event.description.toLowerCase().contains(searchLower);
        final matchesType = event.type?.toLowerCase().contains(searchLower) ?? false;
        final matchesMode = event.mode?.toLowerCase().contains(searchLower) ?? false;
        final matchesLocation = event.location.toLowerCase().contains(searchLower);

        final matchesFilter = selectedFilter == "All" ? true : event.status == selectedFilter;

        return (matchesTitle || matchesDescription || matchesType || matchesMode || matchesLocation) && matchesFilter;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newEvent = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateEditEventScreen(),
            ),
          );

          if (newEvent != null && newEvent is EventModel) {
            setState(() {
              events.add(newEvent);
              applyFilters();
            });
          }
        },
        backgroundColor: const Color(0xff1893ff),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xff1893ff),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  toolbarHeight: 130,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "My Events",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Manage your created events",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.history, color: Colors.white),
                      onPressed: () async {
                        final restoredEvent = await Navigator.push<EventModel>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventHistoryScreen(eventHistory: eventHistory),
                          ),
                        );

                        if (restoredEvent != null) {
                          setState(() {
                            events.add(restoredEvent);
                            eventHistory.remove(restoredEvent);
                            applyFilters();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: const Icon(Icons.search, color: Color(0xff1893ff)),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xff1893ff), width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      searchText = value;
                      applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 160,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: CustomDropdown(
                      items: const ["All", "Draft", "Published"],
                      value: selectedFilter,
                      onChanged: (value) {
                        setState(() {
                          selectedFilter = value!;
                          applyFilters();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];

                Widget imageWidget;
                if (event.coverImagePath != null && File(event.coverImagePath!).existsSync()) {
                  imageWidget = Image.file(
                    File(event.coverImagePath!),
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  );
                } else {
                  imageWidget = const SizedBox.shrink();
                }

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        child: imageWidget,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Description: ${event.description}",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff1893ff).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    event.type ?? 'Event',
                                    style: const TextStyle(
                                      color: Color(0xff1893ff),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        event.mode == 'Online'
                                            ? Icons.computer
                                            : event.mode == 'Onsite'
                                            ? Icons.location_on
                                            : Icons.hub,
                                        size: 14,
                                        color: Colors.purple,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        event.mode ?? 'N/A',
                                        style: const TextStyle(
                                          color: Colors.purple,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  "${event.startDate} - ${event.endDate}",
                                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  "${event.startTime} - ${event.endTime}",
                                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                ),
                              ],
                            ),
                            if (event.location.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.place, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      event.location,
                                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: event.status == "Published"
                                    ? Colors.green.withOpacity(0.15)
                                    : Colors.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                event.status,
                                style: TextStyle(
                                  color: event.status == "Published" ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.people, size: 20, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Capacity: ${event.capacity}",
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                                if (event.minPoints > 0)
                                  Row(
                                    children: [
                                      const Icon(Icons.stars, size: 20, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${event.minPoints.round()} pts",
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _actionBtn(Icons.edit, "Edit",
                                    color: const Color(0xff1893ff), onTap: () async {
                                      final updatedEvent = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => CreateEditEventScreen(event: event),
                                        ),
                                      );

                                      if (updatedEvent != null && updatedEvent is EventModel) {
                                        setState(() {
                                          final originalIndex = events.indexWhere((e) => e.id == event.id);
                                          if (originalIndex != -1) {
                                            events[originalIndex] = updatedEvent;
                                          }
                                          applyFilters();
                                        });
                                      }
                                    }),
                                _actionBtn(Icons.delete, "Delete", color: Colors.red, onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Delete Event"),
                                      content: const Text("Are you sure you want to delete this event?"),
                                      actions: [
                                        TextButton(
                                          child: const Text(
                                            "Cancel",
                                            style: TextStyle(color: Color(0xff1893ff)),
                                          ),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                        TextButton(
                                          child: const Text(
                                            "Delete",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              eventHistory.add(event);
                                              events.remove(event);
                                              applyFilters();
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                _actionBtn(Icons.visibility, "View", color: Colors.lime[900], onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("View Event - Coming Soon")),
                                  );
                                }),
                                _actionBtn(Icons.analytics_outlined, "Analytics",
                                    color: Colors.green, onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EventAnalyticsScreen(event: event),
                                        ),
                                      );
                                    }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String text, {Color? color, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color ?? Colors.black),
          const SizedBox(height: 4),
          Text(text, style: TextStyle(color: color ?? Colors.black, fontSize: 12)),
        ],
      ),
    );
  }
}