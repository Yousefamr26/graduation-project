// // ignore_for_file: avoid_print
// import 'package:flutter/material.dart';
//
// import '../../../../../../data/models/university/PartnershipModel.dart';
// import '../../../../../../data/repositories/PartnershipRepository.dart';
// import 'partnership_detail_screen.dart';
// import 'partnership_form_sheet.dart';
//
// class PartnershipsScreen extends StatefulWidget {
//   const PartnershipsScreen({super.key});
//
//   @override
//   State<PartnershipsScreen> createState() => _PartnershipsScreenState();
// }
//
// class _PartnershipsScreenState extends State<PartnershipsScreen> {
//   static const Color _blue = Color(0xff1676C4);
//   static const Color _bg = Color(0xffF5F7FB);
//
//   final PartnershipRepository _repo = PartnershipRepository();
//   final TextEditingController _searchCtrl = TextEditingController();
//
//   List<PartnershipModel> _all = [];
//   List<PartnershipModel> _filtered = [];
//   bool _loading = true;
//   String _activeFilter = 'All';
//
//   final List<String> _filters = [
//     'All',
//     'Pending',
//     'Approved',
//     'Academic',
//     'Industry',
//     'Research',
//     'Government',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _load();
//     _searchCtrl.addListener(_applyFilter);
//   }
//
//   @override
//   void dispose() {
//     _searchCtrl.dispose();
//     super.dispose();
//   }
//
//   Future<void> _load() async {
//     if (!mounted) return;
//     setState(() => _loading = true);
//     try {
//       final data = await _repo.getAll();
//       if (!mounted) return;
//       setState(() {
//         _all = data;
//         _loading = false;
//       });
//       _applyFilter();
//     } catch (e) {
//       print('❌ [Partnerships] load error: $e');
//       if (!mounted) return;
//       setState(() => _loading = false);
//       _showSnack('Failed to load partnerships');
//     }
//   }
//
//   void _applyFilter() {
//     final q = _searchCtrl.text.toLowerCase();
//     setState(() {
//       _filtered = _all.where((p) {
//         final matchQ = q.isEmpty ||
//             p.companyName.toLowerCase().contains(q) ||
//             p.industry.toLowerCase().contains(q) ||
//             p.location.toLowerCase().contains(q);
//         final matchF = _activeFilter == 'All' ||
//             (_activeFilter == 'Pending' && (p.status ?? '') == 'pending') ||
//             (_activeFilter == 'Approved' && (p.status ?? '') == 'approved') ||
//             p.partnershipType == _activeFilter;
//         return matchQ && matchF;
//       }).toList();
//     });
//   }
//
//   Future<void> _approve(PartnershipModel p) async {
//     try {
//       await _repo.approve(p.id!);
//       _showSnack('Partnership approved ✓');
//       _load();
//     } catch (_) {
//       _showSnack('Failed to approve');
//     }
//   }
//
//   Future<void> _delete(PartnershipModel p) async {
//     final confirm = await _confirmDelete();
//     if (!confirm) return;
//     try {
//       await _repo.delete(p.id!);
//       _showSnack('Partnership deleted');
//       _load();
//     } catch (_) {
//       _showSnack('Failed to delete');
//     }
//   }
//
//   Future<bool> _confirmDelete() async {
//     return await showDialog<bool>(
//           context: context,
//           builder: (_) => AlertDialog(
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             title: const Text('Delete Partnership'),
//             content:
//                 const Text('Are you sure you want to delete this partnership?'),
//             actions: [
//               TextButton(
//                   onPressed: () => Navigator.pop(context, false),
//                   child: const Text('Cancel')),
//               TextButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: const Text('Delete',
//                     style: TextStyle(color: Colors.red)),
//               ),
//             ],
//           ),
//         ) ??
//         false;
//   }
//
//   void _showSnack(String msg) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(msg)));
//   }
//
//   void _openAdd() async {
//     final added = await showModalBottomSheet<bool>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => const PartnershipFormSheet(),
//     );
//     if (added == true) _load();
//   }
//
//   void _openEdit(PartnershipModel p) async {
//     final edited = await showModalBottomSheet<bool>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => PartnershipFormSheet(partnership: p),
//     );
//     if (edited == true) _load();
//   }
//
//   // ─────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _bg,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Partnerships',
//                 style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black)),
//             Text('${_all.length} partner organizations',
//                 style:
//                     const TextStyle(fontSize: 12, color: Colors.grey)),
//           ],
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 16),
//             child: GestureDetector(
//               onTap: _openAdd,
//               child: Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                     color: _blue,
//                     borderRadius: BorderRadius.circular(10)),
//                 child: const Icon(Icons.add, color: Colors.white, size: 20),
//               ),
//             ),
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(110),
//           child: Column(
//             children: [
//               // Search bar
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(14),
//                     border: Border.all(color: const Color(0xffE2E8F0)),
//                   ),
//                   child: TextField(
//                     controller: _searchCtrl,
//                     decoration: const InputDecoration(
//                       hintText: 'Search partners...',
//                       hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
//                       prefixIcon: Icon(Icons.search,
//                           color: Colors.grey, size: 20),
//                       border: InputBorder.none,
//                       contentPadding:
//                           EdgeInsets.symmetric(vertical: 12),
//                     ),
//                   ),
//                 ),
//               ),
//               // Filter chips
//               SizedBox(
//                 height: 42,
//                 child: ListView.separated(
//                   scrollDirection: Axis.horizontal,
//                   padding: const EdgeInsets.only(left: 16, right: 16, bottom: 6),
//                   itemCount: _filters.length,
//                   separatorBuilder: (_, __) => const SizedBox(width: 8),
//                   itemBuilder: (_, i) {
//                     final f = _filters[i];
//                     final active = _activeFilter == f;
//                     return GestureDetector(
//                       onTap: () {
//                         setState(() => _activeFilter = f);
//                         _applyFilter();
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: active ? _blue : Colors.white,
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                               color: active ? _blue : const Color(0xffE2E8F0),
//                               width: 1.5),
//                         ),
//                         child: Text(f,
//                             style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                                 color: active ? Colors.white : Colors.grey)),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: _loading
//           ? const Center(
//               child: CircularProgressIndicator(color: _blue))
//           : RefreshIndicator(
//               onRefresh: _load,
//               color: _blue,
//               child: _filtered.isEmpty
//                   ? _buildEmpty()
//                   : ListView.separated(
//                       padding: const EdgeInsets.all(16),
//                       itemCount: _filtered.length,
//                       separatorBuilder: (_, __) =>
//                           const SizedBox(height: 10),
//                       itemBuilder: (_, i) =>
//                           _buildCard(_filtered[i]),
//                     ),
//             ),
//     );
//   }
//
//   // ─────────────────────────────────────────────────────────────
//   Widget _buildCard(PartnershipModel p) {
//     return GestureDetector(
//       onTap: () async {
//         final result = await Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (_) => PartnershipDetailScreen(partnership: p)),
//         );
//         if (result == true) _load();
//       },
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4)),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 _avatar(p.companyName),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(p.companyName,
//                           style: const TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w700,
//                               color: Colors.black87),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis),
//                       const SizedBox(height: 2),
//                       Text('${p.industry} · ${p.partnershipType}',
//                           style: const TextStyle(
//                               fontSize: 12, color: Colors.grey),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis),
//                     ],
//                   ),
//                 ),
//                 _statusBadge(p.status),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Divider(color: Colors.grey.shade100, height: 1),
//             const SizedBox(height: 10),
//             Row(
//               children: [
//                 const Icon(Icons.location_on_outlined,
//                     size: 13, color: Colors.grey),
//                 const SizedBox(width: 4),
//                 Expanded(
//                   child: Text(p.location,
//                       style: const TextStyle(
//                           fontSize: 12, color: Colors.grey),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis),
//                 ),
//                 // Action buttons
//                 Row(
//                   children: [
//                     if ((p.status ?? '') == 'pending')
//                       _iconBtn(
//                         icon: Icons.check_circle_outline,
//                         color: const Color(0xff16C47F),
//                         onTap: () => _approve(p),
//                         tooltip: 'Approve',
//                       ),
//                     const SizedBox(width: 6),
//                     _iconBtn(
//                       icon: Icons.edit_outlined,
//                       color: const Color(0xff1676C4),
//                       onTap: () => _openEdit(p),
//                       tooltip: 'Edit',
//                     ),
//                     const SizedBox(width: 6),
//                     _iconBtn(
//                       icon: Icons.delete_outline,
//                       color: Colors.red,
//                       onTap: () => _delete(p),
//                       tooltip: 'Delete',
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmpty() {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.handshake_outlined,
//               size: 64, color: Colors.grey.shade300),
//           const SizedBox(height: 12),
//           const Text('No partnerships found',
//               style: TextStyle(
//                   color: Colors.grey,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }
//
//   Widget _avatar(String name) {
//     final initials = name
//         .trim()
//         .split(' ')
//         .take(2)
//         .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
//         .join();
//     return Container(
//       width: 44,
//       height: 44,
//       decoration: BoxDecoration(
//           color: const Color(0xff1676C4).withOpacity(0.1),
//           borderRadius: BorderRadius.circular(14)),
//       alignment: Alignment.center,
//       child: Text(initials,
//           style: const TextStyle(
//               color: Color(0xff1676C4),
//               fontWeight: FontWeight.w700,
//               fontSize: 15)),
//     );
//   }
//
//   Widget _statusBadge(String? status) {
//     Color bg, fg;
//     String label;
//     switch ((status ?? '').toLowerCase()) {
//       case 'approved':
//         bg = const Color(0xffE8F8F0);
//         fg = const Color(0xff0d8a5c);
//         label = 'Approved';
//         break;
//       case 'rejected':
//         bg = const Color(0xffFDECEA);
//         fg = Colors.red;
//         label = 'Rejected';
//         break;
//       default:
//         bg = const Color(0xffFEF3CD);
//         fg = const Color(0xff9a6c00);
//         label = 'Pending';
//     }
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration:
//           BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
//       child: Text(label,
//           style: TextStyle(
//               color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
//     );
//   }
//
//   Widget _iconBtn({
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//     required String tooltip,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Tooltip(
//         message: tooltip,
//         child: Container(
//           width: 30,
//           height: 30,
//           decoration: BoxDecoration(
//               color: color.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(8)),
//           child: Icon(icon, color: color, size: 16),
//         ),
//       ),
//     );
//   }
// }
