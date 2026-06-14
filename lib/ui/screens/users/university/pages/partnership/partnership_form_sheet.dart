// // ignore_for_file: avoid_print
// import 'package:flutter/material.dart';
//
// import '../../../../../../data/models/university/PartnershipModel.dart';
// import '../../../../../../data/repositories/PartnershipRepository.dart';
//
//
// class PartnershipFormSheet extends StatefulWidget {
//   /// Pass [partnership] to open in edit mode; null = add mode
//   final PartnershipModel? partnership;
//
//   const PartnershipFormSheet({super.key, this.partnership});
//
//   @override
//   State<PartnershipFormSheet> createState() => _PartnershipFormSheetState();
// }
//
// class _PartnershipFormSheetState extends State<PartnershipFormSheet> {
//   static const Color _blue = Color(0xff1676C4);
//   static const Color _bg = Color(0xffF5F7FB);
//
//   final _formKey = GlobalKey<FormState>();
//   final PartnershipRepository _repo = PartnershipRepository();
//   bool _saving = false;
//
//   // Controllers
//   late final TextEditingController _companyName;
//   late final TextEditingController _industry;
//   late final TextEditingController _contactPerson;
//   late final TextEditingController _email;
//   late final TextEditingController _phone;
//   late final TextEditingController _website;
//   late final TextEditingController _location;
//   late final TextEditingController _details;
//   String _partnershipType = 'Academic';
//
//   bool get _isEdit => widget.partnership != null;
//
//   final List<String> _types = [
//     'Academic',
//     'Industry',
//     'Research',
//     'Government',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     final p = widget.partnership;
//     _companyName = TextEditingController(text: p?.companyName ?? '');
//     _industry = TextEditingController(text: p?.industry ?? '');
//     _contactPerson = TextEditingController(text: p?.contactPerson ?? '');
//     _email = TextEditingController(text: p?.email ?? '');
//     _phone = TextEditingController(text: p?.phone ?? '');
//     _website = TextEditingController(text: p?.website ?? '');
//     _location = TextEditingController(text: p?.location ?? '');
//     _details = TextEditingController(text: p?.details ?? '');
//     _partnershipType = p?.partnershipType ?? 'Academic';
//   }
//
//   @override
//   void dispose() {
//     for (final c in [
//       _companyName,
//       _industry,
//       _contactPerson,
//       _email,
//       _phone,
//       _website,
//       _location,
//       _details,
//     ]) {
//       c.dispose();
//     }
//     super.dispose();
//   }
//
//   // ── URL validator ──────────────────────────────────────────
//   String? _validateUrl(String? value) {
//     if (value == null || value.trim().isEmpty) return null; // optional field
//     final trimmed = value.trim();
//     // Check for spaces inside the URL
//     if (trimmed.contains(' ')) {
//       return 'URL must not contain spaces';
//     }
//     // Must start with http:// or https://
//     if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
//       return 'URL must start with http:// or https://';
//     }
//     // Basic URI parse check
//     try {
//       final uri = Uri.parse(trimmed);
//       if (!uri.hasAuthority || uri.host.isEmpty) {
//         return 'Enter a valid URL (e.g. https://example.com)';
//       }
//     } catch (_) {
//       return 'Enter a valid URL (e.g. https://example.com)';
//     }
//     return null;
//   }
//
//   // ── Parse server-side validation errors ───────────────────
//   /// Extracts a human-readable message from the API 400 error body.
//   /// The body looks like:
//   /// {"errors":{"Website":["Invalid website URL"],...},...}
//   String _extractServerError(dynamic error) {
//     final msg = error.toString();
//     // Try to find field-level errors in the message string
//     // Pattern: Failed to create/update partnership: 400
//     // The detailed body was already printed; show a friendly summary.
//     if (msg.contains('400')) {
//       // Try to detect known field patterns in the raw exception string
//       if (msg.toLowerCase().contains('website')) {
//         return 'Website URL is invalid. Please enter a full valid URL (e.g. https://example.com)';
//       }
//       return 'Validation failed. Please check your inputs and try again.';
//     }
//     return _isEdit ? 'Failed to update partnership' : 'Failed to add partnership';
//   }
//
//   Future<void> _save() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _saving = true);
//
//     // Sanitize website: trim whitespace/spaces that user might have typed
//     final rawWebsite = _website.text.trim();
//
//     final model = PartnershipModel(
//       id: widget.partnership?.id,
//       companyId: widget.partnership?.companyId ?? '',
//       companyName: _companyName.text.trim(),
//       industry: _industry.text.trim(),
//       partnershipType: _partnershipType,
//       contactPerson: _contactPerson.text.trim(),
//       email: _email.text.trim(),
//       phone: _phone.text.trim(),
//       website: rawWebsite,
//       location: _location.text.trim(),
//       details: _details.text.trim(),
//     );
//
//     try {
//       if (_isEdit) {
//         await _repo.update(widget.partnership!.id!, model);
//       } else {
//         await _repo.create(model);
//       }
//       if (mounted) Navigator.pop(context, true);
//     } catch (e) {
//       print('❌ [Form] save error: $e');
//       if (mounted) {
//         setState(() => _saving = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(_extractServerError(e)),
//             backgroundColor: Colors.red.shade700,
//             behavior: SnackBarBehavior.floating,
//             duration: const Duration(seconds: 4),
//           ),
//         );
//       }
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding:
//       EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//       child: Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Handle
//             Container(
//               margin: const EdgeInsets.only(top: 10),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(2)),
//             ),
//             // Title row
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 14, 16, 4),
//               child: Row(
//                 children: [
//                   Text(
//                     _isEdit ? 'Edit Partnership' : 'New Partnership',
//                     style: const TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.black87),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     icon: const Icon(Icons.close, size: 20),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//             ),
//             const Divider(height: 1),
//             // Form
//             Flexible(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _row([
//                         _field('Company Name', _companyName,
//                             required: true,
//                             hint: 'Tech Corp'),
//                         _field('Industry', _industry,
//                             hint: 'Software'),
//                       ]),
//                       const SizedBox(height: 12),
//                       _row([
//                         _dropdownField(),
//                         _field('Location', _location,
//                             hint: 'Cairo, Egypt'),
//                       ]),
//                       const SizedBox(height: 12),
//                       _row([
//                         _field('Contact Person', _contactPerson,
//                             hint: 'Ahmed Ali'),
//                         _field('Phone', _phone,
//                             hint: '01012345678',
//                             keyboardType: TextInputType.phone),
//                       ]),
//                       const SizedBox(height: 12),
//                       _field('Email', _email,
//                           hint: 'ahmed@example.com',
//                           keyboardType: TextInputType.emailAddress,
//                           validator: (v) {
//                             if (v != null &&
//                                 v.isNotEmpty &&
//                                 !v.contains('@')) {
//                               return 'Enter a valid email';
//                             }
//                             return null;
//                           }),
//                       const SizedBox(height: 12),
//                       _field(
//                         'Website',
//                         _website,
//                         hint: 'https://example.com',
//                         keyboardType: TextInputType.url,
//                         validator: _validateUrl,
//                       ),
//                       const SizedBox(height: 12),
//                       _textareaField(),
//                       const SizedBox(height: 20),
//                       _buildButtons(),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ─────────────────────────────────────────────────────────────
//   // Form helpers
//   // ─────────────────────────────────────────────────────────────
//
//   Widget _row(List<Widget> children) {
//     return Row(
//       children: children
//           .expand((w) => [Expanded(child: w), const SizedBox(width: 10)])
//           .toList()
//         ..removeLast(),
//     );
//   }
//
//   Widget _field(
//       String label,
//       TextEditingController ctrl, {
//         String hint = '',
//         bool required = false,
//         TextInputType? keyboardType,
//         String? Function(String?)? validator,
//       }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _label(label),
//         const SizedBox(height: 5),
//         TextFormField(
//           controller: ctrl,
//           keyboardType: keyboardType,
//           style: const TextStyle(fontSize: 14, color: Colors.black87),
//           decoration: _inputDec(hint),
//           validator: validator ??
//               (required
//                   ? (v) => (v == null || v.trim().isEmpty)
//                   ? '$label is required'
//                   : null
//                   : null),
//         ),
//       ],
//     );
//   }
//
//   Widget _dropdownField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _label('Type'),
//         const SizedBox(height: 5),
//         DropdownButtonFormField<String>(
//           value: _partnershipType,
//           decoration: _inputDec(''),
//           style: const TextStyle(
//               fontSize: 14, color: Colors.black87),
//           items: _types
//               .map((t) => DropdownMenuItem(value: t, child: Text(t)))
//               .toList(),
//           onChanged: (v) => setState(() => _partnershipType = v ?? 'Academic'),
//         ),
//       ],
//     );
//   }
//
//   Widget _textareaField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _label('Details'),
//         const SizedBox(height: 5),
//         TextFormField(
//           controller: _details,
//           maxLines: 3,
//           style: const TextStyle(fontSize: 14, color: Colors.black87),
//           decoration: _inputDec('Describe the partnership...'),
//         ),
//       ],
//     );
//   }
//
//   Widget _label(String text) {
//     return Text(text,
//         style: const TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.w700,
//             color: Colors.grey,
//             letterSpacing: 0.4));
//   }
//
//   InputDecoration _inputDec(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle:
//       const TextStyle(color: Colors.grey, fontSize: 13),
//       filled: true,
//       fillColor: _bg,
//       contentPadding:
//       const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xffE2E8F0), width: 1.5)),
//       enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xffE2E8F0), width: 1.5)),
//       focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: _blue, width: 1.5)),
//       errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.red, width: 1.5)),
//       focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.red, width: 1.5)),
//     );
//   }
//
//   Widget _buildButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: OutlinedButton(
//             onPressed: _saving ? null : () => Navigator.pop(context),
//             style: OutlinedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14)),
//               side: const BorderSide(color: Color(0xffE2E8F0)),
//             ),
//             child: const Text('Cancel',
//                 style: TextStyle(
//                     color: Colors.grey, fontWeight: FontWeight.w700)),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: ElevatedButton(
//             onPressed: _saving ? null : _save,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _blue,
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14)),
//               elevation: 0,
//             ),
//             child: _saving
//                 ? const SizedBox(
//                 width: 18,
//                 height: 18,
//                 child: CircularProgressIndicator(
//                     color: Colors.white, strokeWidth: 2))
//                 : Text(
//               _isEdit ? 'Save Changes' : 'Add Partnership',
//               style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w700),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }