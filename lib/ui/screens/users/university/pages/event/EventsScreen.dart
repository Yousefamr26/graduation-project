// import 'dart:io';
// import 'package:flutter/material.dart';
// import '../../../../../../data/models/company/event-model.dart';
// import '../../../../../widgets/common/CustomDropdown.dart';
// import '../../../../../widgets/common/action_button.dart';
// import '../../../company/pages/Event/EventmockData.dart';
// import '../../../company/pages/Event/addnewevent.dart';
// import '../../../company/pages/Event/eventanalytics.dart';
// import '../../../company/pages/Event/eventhistory.dart';
//
//
//
// class EventsScreen extends StatefulWidget {
//   const EventsScreen({super.key});
//
//   @override
//   State<EventsScreen> createState() => _EventsScreenState();
// }
//
// class _EventsScreenState extends State<EventsScreen> {
//   final List<EventModel> events = [];
//   final List<EventModel> eventHistory = [];
//
//   String searchText = "";
//   String selectedFilter = "All";
//   List<EventModel> filteredEvents = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchEvents();
//   }
//
//   // ✅ MOCK: جيب البيانات من الـ static list
//   Future<void> _fetchEvents() async {
//     if (!mounted) return;
//     setState(() => isLoading = true);
//
//     // ✅ MOCK
//     await Future.delayed(const Duration(milliseconds: 400));
//     final fetched = EventMockData.getEvents();
//
//     // ❌ BACKEND:
//     // final fetched = await _eventRepo.getAllEvents();
//
//     if (!mounted) return;
//
//     final historyIds = eventHistory.map((e) => e.id).toSet();
//
//     setState(() {
//       events.clear();
//       for (var event in fetched) {
//         if (!historyIds.contains(event.id)) events.add(event);
//       }
//       applyFilters();
//       isLoading = false;
//     });
//   }
//
//   void applyFilters() {
//     setState(() {
//       filteredEvents = events.where((event) {
//         if (selectedFilter != "All" && event.status != selectedFilter) return false;
//         if (searchText.isEmpty) return true;
//         return _matchesSearch(event, searchText.toLowerCase());
//       }).toList();
//     });
//   }
//
//   bool _matchesSearch(EventModel event, String q) {
//     return event.title.toLowerCase().contains(q) ||
//         event.description.toLowerCase().contains(q) ||
//         (event.type?.toLowerCase().contains(q) ?? false) ||
//         (event.mode?.toLowerCase().contains(q) ?? false) ||
//         event.location.toLowerCase().contains(q);
//   }
//
//   void _deleteEvent(int index) {
//     final eventToDelete = filteredEvents[index];
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Row(
//           children: [
//             Icon(Icons.delete_outline, color: Colors.red),
//             SizedBox(width: 8),
//             Text("Delete Event"),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Are you sure you want to delete this event?"),
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.red[50],
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.red[200]!),
//               ),
//               child: Text(eventToDelete.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//             ),
//             const SizedBox(height: 8),
//             Text("You can restore it from History later.", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel", style: TextStyle(color: Color(0xff1676C4))),
//           ),
//           ElevatedButton.icon(
//             onPressed: () {
//               Navigator.pop(context);
//               _performDelete(eventToDelete);
//             },
//             icon: const Icon(Icons.delete),
//             label: const Text("Delete"),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _performDelete(EventModel event) {
//     // ✅ MOCK: بنحركه للـ history في الـ runtime فقط
//     setState(() {
//       eventHistory.add(event);
//       events.remove(event);
//       applyFilters();
//     });
//
//     // ❌ BACKEND:
//     // await _eventRepo.deleteEvent(event.id);
//
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('Event moved to History'),
//         action: SnackBarAction(
//           label: 'Undo',
//           textColor: Colors.white,
//           onPressed: () {
//             setState(() {
//               final last = eventHistory.removeLast();
//               events.add(last);
//               applyFilters();
//             });
//           },
//         ),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }
//
//   Widget _buildImageWidget(EventModel event) {
//     if (event.coverImagePath == null || event.coverImagePath!.isEmpty) return const SizedBox.shrink();
//     if (event.coverImagePath!.startsWith("http")) {
//       return Image.network(event.coverImagePath!, width: double.infinity, height: 150, fit: BoxFit.cover,
//           errorBuilder: (_, __, ___) => Container(height: 150, color: Colors.grey[300], child: const Icon(Icons.broken_image, size: 50)));
//     }
//     if (File(event.coverImagePath!).existsSync()) {
//       return Image.file(File(event.coverImagePath!), width: double.infinity, height: 150, fit: BoxFit.cover,
//           errorBuilder: (_, __, ___) => Container(height: 150, color: Colors.grey[300], child: const Icon(Icons.broken_image, size: 50)));
//     }
//     return const SizedBox.shrink();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final newEvent = await Navigator.push<EventModel>(
//             context,
//             MaterialPageRoute(builder: (_) => const CreateEditEventScreen()),
//           );
//           if (newEvent != null && mounted) {
//             // ✅ MOCK: ضيف في الـ static list وبعدين fetch
//             EventMockData.addEvent(newEvent);
//             await _fetchEvents();
//
//             if (mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Event created successfully!'), backgroundColor: Colors.green),
//               );
//             }
//           }
//         },
//         backgroundColor: const Color(0xff1676C4),
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//       body: Column(
//         children: [_buildAppBar(), _buildSearchAndFilter(), _buildEventsList()],
//       ),
//     );
//   }
//
//   Widget _buildAppBar() {
//     return Container(
//       width: double.infinity,
//       decoration: const BoxDecoration(
//         color: Color(0xff1676C4),
//         borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
//       ),
//       child: SafeArea(
//         bottom: false,
//         child: Padding(
//           padding: const EdgeInsets.only(bottom: 16),
//           child: AppBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             toolbarHeight: 130,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back, color: Colors.white),
//               onPressed: () => Navigator.pop(context),
//             ),
//             title: const Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("My Events", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500)),
//                 SizedBox(height: 4),
//                 Text("Manage your created events", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w300)),
//               ],
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.refresh, color: Colors.white),
//                 onPressed: _fetchEvents,
//                 tooltip: 'Refresh',
//               ),
//               IconButton(
//                 icon: Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     const Icon(Icons.history, color: Colors.white),
//                     if (eventHistory.isNotEmpty)
//                       Positioned(
//                         right: -2,
//                         top: -2,
//                         child: Container(
//                           padding: const EdgeInsets.all(4),
//                           decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
//                           constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
//                           child: Center(
//                             child: Text(
//                               '${eventHistory.length > 99 ? '99+' : eventHistory.length}',
//                               style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//                 onPressed: () async {
//                   final restoredEvent = await Navigator.push<EventModel>(
//                     context,
//                     MaterialPageRoute(builder: (_) => EventHistoryScreen(eventHistory: eventHistory)),
//                   );
//                   if (restoredEvent != null && mounted) {
//                     setState(() {
//                       events.add(restoredEvent);
//                       eventHistory.remove(restoredEvent);
//                       applyFilters();
//                     });
//                     if (mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Event restored successfully!'), backgroundColor: Colors.green),
//                       );
//                     }
//                   }
//                 },
//                 tooltip: 'History',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSearchAndFilter() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: "Search...",
//                 prefixIcon: const Icon(Icons.search, color: Color(0xff1676C4)),
//                 filled: true,
//                 fillColor: Colors.white,
//                 enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
//                 focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff1676C4), width: 2)),
//               ),
//               onChanged: (value) {
//                 setState(() { searchText = value; applyFilters(); });
//               },
//             ),
//           ),
//           const SizedBox(width: 10),
//           SizedBox(
//             width: 160,
//             child: Container(
//               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
//               child: CustomDropdown(
//                 items: const ["All", "Draft", "Published"],
//                 value: selectedFilter,
//                 onChanged: (value) {
//                   setState(() { selectedFilter = value!; applyFilters(); });
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEventsList() {
//     return Expanded(
//       child: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : filteredEvents.isEmpty
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.event_outlined, size: 80, color: Colors.grey[400]),
//             const SizedBox(height: 16),
//             Text(searchText.isEmpty ? "No events yet" : "No events found",
//                 style: TextStyle(fontSize: 18, color: Colors.grey[600])),
//             const SizedBox(height: 8),
//             Text(searchText.isEmpty ? "Create your first event!" : "Try a different search",
//                 style: TextStyle(fontSize: 14, color: Colors.grey[500])),
//           ],
//         ),
//       )
//           : RefreshIndicator(
//         onRefresh: _fetchEvents,
//         child: ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: filteredEvents.length,
//           itemBuilder: (context, index) => _buildEventCard(index),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEventCard(int index) {
//     final event = filteredEvents[index];
//
//     return Card(
//       elevation: 3,
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
//             child: _buildImageWidget(event),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(event.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 6),
//                 Text("Description: ${event.description}", style: TextStyle(color: Colors.grey[700])),
//                 const SizedBox(height: 6),
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(color: const Color(0xff1676C4).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
//                       child: Text(event.type ?? 'Event', style: const TextStyle(color: Color(0xff1676C4), fontWeight: FontWeight.w600, fontSize: 12)),
//                     ),
//                     const SizedBox(width: 8),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
//                       child: Row(
//                         children: [
//                           Icon(event.mode == 'Online' ? Icons.computer : event.mode == 'Onsite' ? Icons.location_on : Icons.hub, size: 14, color: Colors.purple),
//                           const SizedBox(width: 4),
//                           Text(event.mode ?? 'N/A', style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.w600, fontSize: 12)),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 6),
//                 Row(children: [
//                   const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
//                   const SizedBox(width: 4),
//                   Text("${event.startDate} - ${event.endDate}", style: TextStyle(color: Colors.grey[700], fontSize: 13)),
//                 ]),
//                 const SizedBox(height: 6),
//                 Row(children: [
//                   const Icon(Icons.access_time, size: 16, color: Colors.grey),
//                   const SizedBox(width: 4),
//                   Text("${event.startTime} - ${event.endTime}", style: TextStyle(color: Colors.grey[700], fontSize: 13)),
//                 ]),
//                 if (event.location.isNotEmpty) ...[
//                   const SizedBox(height: 6),
//                   Row(children: [
//                     const Icon(Icons.place, size: 16, color: Colors.grey),
//                     const SizedBox(width: 4),
//                     Expanded(child: Text(event.location, style: TextStyle(color: Colors.grey[700], fontSize: 13))),
//                   ]),
//                 ],
//                 const SizedBox(height: 10),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: event.status == "Published" ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(event.status,
//                       style: TextStyle(color: event.status == "Published" ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(children: [
//                       const Icon(Icons.people, size: 20, color: Colors.grey),
//                       const SizedBox(width: 4),
//                       Text("Capacity: ${event.capacity}", style: const TextStyle(fontSize: 13)),
//                     ]),
//                     if (event.minPoints > 0)
//                       Row(children: [
//                         const Icon(Icons.stars, size: 20, color: Colors.amber),
//                         const SizedBox(width: 4),
//                         Text("${event.minPoints.round()} pts", style: const TextStyle(fontSize: 13)),
//                       ]),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     ActionButton(
//                       icon: Icons.edit,
//                       text: "Edit",
//                       color: const Color(0xff1676C4),
//                       onTap: () async {
//                         final updatedEvent = await Navigator.push<EventModel>(
//                           context,
//                           MaterialPageRoute(builder: (_) => CreateEditEventScreen(event: event)),
//                         );
//                         if (updatedEvent != null && mounted) {
//                           // ✅ MOCK: عدّل في الـ static list وبعدين fetch
//                           EventMockData.updateEvent(updatedEvent.id, updatedEvent);
//                           await _fetchEvents();
//
//                           // ❌ BACKEND: الـ CreateEditEventScreen هو اللي بيعمل API call
//                         }
//                       },
//                     ),
//                     ActionButton(
//                       icon: Icons.delete,
//                       text: "Delete",
//                       color: Colors.red,
//                       onTap: () => _deleteEvent(index),
//                     ),
//                     ActionButton(
//                       icon: Icons.analytics_outlined,
//                       text: "Analytics",
//                       color: Colors.green,
//                       onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventAnalyticsScreen(event: event))),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }