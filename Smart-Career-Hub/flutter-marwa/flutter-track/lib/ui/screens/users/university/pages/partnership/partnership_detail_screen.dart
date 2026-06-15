// // ignore_for_file: avoid_print
// import 'package:flutter/material.dart';
// import '../../../../../../data/models/university/PartnershipModel.dart';
// import '../../../../../../data/repositories/PartnershipRepository.dart';
// import 'partnership_form_sheet.dart';
//
// class PartnershipDetailScreen extends StatefulWidget {
//   final PartnershipModel partnership;
//
//   const PartnershipDetailScreen({super.key, required this.partnership});
//
//   @override
//   State<PartnershipDetailScreen> createState() =>
//       _PartnershipDetailScreenState();
// }
//
// class _PartnershipDetailScreenState extends State<PartnershipDetailScreen> {
//   static const Color _blue = Color(0xff1676C4);
//   static const Color _bg = Color(0xffF5F7FB);
//
//   final PartnershipRepository _repo = PartnershipRepository();
//   late PartnershipModel _p;
//   bool _loading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _p = widget.partnership;
//   }
//
//   Future<void> _approve() async {
//     setState(() => _loading = true);
//     try {
//       await _repo.approve(_p.id!);
//       setState(() {
//         _p = _p.copyWith(status: 'approved');
//         _loading = false;
//       });
//       _showSnack('Partnership approved ✓');
//     } catch (_) {
//       setState(() => _loading = false);
//       _showSnack('Failed to approve');
//     }
//   }
//
//   Future<void> _delete() async {
//     final confirm = await showDialog<bool>(
//           context: context,
//           builder: (_) => AlertDialog(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20)),
//             title: const Text('Delete Partnership'),
//             content: const Text(
//                 'Are you sure you want to delete this partnership?'),
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
//
//     if (!confirm) return;
//     setState(() => _loading = true);
//     try {
//       await _repo.delete(_p.id!);
//       if (mounted) Navigator.pop(context, true);
//     } catch (_) {
//       setState(() => _loading = false);
//       _showSnack('Failed to delete');
//     }
//   }
//
//   void _openEdit() async {
//     final edited = await showModalBottomSheet<bool>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => PartnershipFormSheet(partnership: _p),
//     );
//     if (edited == true && mounted) Navigator.pop(context, true);
//   }
//
//   void _showSnack(String msg) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(msg)));
//   }
//
//   // ─────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final isPending = (_p.status ?? '').toLowerCase() == 'pending';
//
//     return Scaffold(
//       backgroundColor: _bg,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new,
//               color: Colors.black, size: 18),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text('Partnership Details',
//             style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.black)),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit_outlined,
//                 color: Color(0xff1676C4)),
//             onPressed: _openEdit,
//             tooltip: 'Edit',
//           ),
//         ],
//       ),
//       body: _loading
//           ? const Center(child: CircularProgressIndicator(color: _blue))
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ── Header card ───────────────────────────
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4)),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         _avatar(_p.companyName, size: 64, fontSize: 22),
//                         const SizedBox(height: 12),
//                         Text(_p.companyName,
//                             style: const TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w800,
//                                 color: Colors.black87),
//                             textAlign: TextAlign.center),
//                         const SizedBox(height: 4),
//                         Text('${_p.industry} · ${_p.partnershipType}',
//                             style: const TextStyle(
//                                 fontSize: 13, color: Colors.grey)),
//                         const SizedBox(height: 10),
//                         _statusBadge(_p.status),
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 16),
//
//                   // ── Info card ─────────────────────────────
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4)),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         _infoRow(Icons.person_outline, 'Contact',
//                             _p.contactPerson),
//                         _divider(),
//                         _infoRow(
//                             Icons.email_outlined, 'Email', _p.email),
//                         _divider(),
//                         _infoRow(
//                             Icons.phone_outlined, 'Phone', _p.phone),
//                         _divider(),
//                         _infoRow(
//                             Icons.language_outlined, 'Website', _p.website,
//                             isLink: true),
//                         _divider(),
//                         _infoRow(Icons.location_on_outlined, 'Location',
//                             _p.location),
//                         _divider(),
//                         _infoRow(Icons.category_outlined, 'Type',
//                             _p.partnershipType),
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 16),
//
//                   // ── Details card ──────────────────────────
//                   if (_p.details.isNotEmpty)
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                               color: Colors.black.withOpacity(0.05),
//                               blurRadius: 10,
//                               offset: const Offset(0, 4)),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text('Details',
//                               style: TextStyle(
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w700,
//                                   color: Colors.grey)),
//                           const SizedBox(height: 8),
//                           Text(_p.details,
//                               style: const TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.black87,
//                                   height: 1.5)),
//                         ],
//                       ),
//                     ),
//
//                   const SizedBox(height: 24),
//
//                   // ── Action buttons ────────────────────────
//                   Row(
//                     children: [
//                       if (isPending) ...[
//                         Expanded(
//                           child: _actionBtn(
//                             label: 'Approve',
//                             icon: Icons.check_circle_outline,
//                             bg: const Color(0xffE8F8F0),
//                             fg: const Color(0xff0d8a5c),
//                             onTap: _approve,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                       ],
//                       Expanded(
//                         child: _actionBtn(
//                           label: 'Delete',
//                           icon: Icons.delete_outline,
//                           bg: const Color(0xffFDECEA),
//                           fg: Colors.red,
//                           onTap: _delete,
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   const SizedBox(height: 24),
//                 ],
//               ),
//             ),
//     );
//   }
//
//   // ─────────────────────────────────────────────────────────────
//   // Small widgets
//   // ─────────────────────────────────────────────────────────────
//
//   Widget _avatar(String name,
//       {double size = 44, double fontSize = 15}) {
//     final initials = name
//         .trim()
//         .split(' ')
//         .take(2)
//         .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
//         .join();
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//           color: const Color(0xff1676C4).withOpacity(0.1),
//           borderRadius: BorderRadius.circular(size * 0.3)),
//       alignment: Alignment.center,
//       child: Text(initials,
//           style: TextStyle(
//               color: const Color(0xff1676C4),
//               fontWeight: FontWeight.w700,
//               fontSize: fontSize)),
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
//       padding:
//           const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
//       decoration:
//           BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
//       child: Text(label,
//           style: TextStyle(
//               color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
//     );
//   }
//
//   Widget _infoRow(IconData icon, String label, String value,
//       {bool isLink = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
//       child: Row(
//         children: [
//           Container(
//             width: 34,
//             height: 34,
//             decoration: BoxDecoration(
//                 color: const Color(0xff1676C4).withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(10)),
//             child: Icon(icon,
//                 color: const Color(0xff1676C4), size: 17),
//           ),
//           const SizedBox(width: 12),
//           SizedBox(
//             width: 80,
//             child: Text(label,
//                 style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey)),
//           ),
//           Expanded(
//             child: Text(value,
//                 style: TextStyle(
//                     fontSize: 13,
//                     color:
//                         isLink ? const Color(0xff1676C4) : Colors.black87,
//                     decoration: isLink
//                         ? TextDecoration.underline
//                         : TextDecoration.none),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 textAlign: TextAlign.end),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _divider() =>
//       Divider(color: Colors.grey.shade100, height: 1, indent: 16, endIndent: 16);
//
//   Widget _actionBtn({
//     required String label,
//     required IconData icon,
//     required Color bg,
//     required Color fg,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 14),
//         decoration: BoxDecoration(
//             color: bg, borderRadius: BorderRadius.circular(16)),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: fg, size: 18),
//             const SizedBox(width: 8),
//             Text(label,
//                 style: TextStyle(
//                     color: fg,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w700)),
//           ],
//         ),
//       ),
//     );
//   }
// }
