// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../../../widgets/common/CustomDropdown.dart';
// import '../../../../../widgets/common/_buildDateField.dart';
// import '../../../../../widgets/common/_buildSection.dart';
// import '../../../../../widgets/common/_buildTextArea.dart';
// import '../../../../../widgets/common/_buildTextField.dart';
// import '../../../../../widgets/common/_buildUploadContainer.dart';
// import '../../../company/pages/workshops/Workshop mock data.dart';
//
// class crate_editWorkshop extends StatefulWidget {
//   final Map<String, dynamic>? workshopData;
//   final bool isEdit;
//
//   const crate_editWorkshop(
//       {super.key, this.workshopData, this.isEdit = false});
//
//   @override
//   State<crate_editWorkshop> createState() => _crate_editWorkshopState();
// }
//
// class _crate_editWorkshopState extends State<crate_editWorkshop> {
//   final _formKey = GlobalKey<FormState>();
//
//   // ─── Controllers ─────────────────────────────────────────────────────────
//   late TextEditingController _titleController;
//   late TextEditingController _descController;
//   late TextEditingController _startDateController;
//   late TextEditingController _endDateController;
//   late TextEditingController _startTimeController;
//   late TextEditingController _endTimeController;
//   late TextEditingController _locationController;
//   late TextEditingController _capacityController;
//
//   String? _workshopType;
//   String? _selectedUniversity;
//
//   bool requireCv = false;
//   bool requireRoadmap = false;
//   double minimumProgress = 0;
//
//   List<Map<String, dynamic>> materials = [];
//   List<Map<String, dynamic>> activities = [];
//
//   // ─── Universities pulled from mock data ──────────────────────────────────
//   final List<String> _universities = workshopMockData
//       .map((w) => w['university'] as String)
//       .toSet()
//       .toList()
//     ..sort();
//
//   String? _bannerImagePath;
//
//   Map<String, String?> _errors = {};
//   bool _isSubmitting = false;
//
//   // ─── Init ─────────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     _initializeControllers();
//   }
//
//   void _initializeControllers() {
//     _titleController =
//         TextEditingController(text: widget.workshopData?['title'] ?? '');
//     _descController =
//         TextEditingController(text: widget.workshopData?['description'] ?? '');
//     _startDateController =
//         TextEditingController(text: widget.workshopData?['startDate'] ?? '');
//     _endDateController =
//         TextEditingController(text: widget.workshopData?['endDate'] ?? '');
//     _startTimeController =
//         TextEditingController(text: widget.workshopData?['startTime'] ?? '');
//     _endTimeController =
//         TextEditingController(text: widget.workshopData?['endTime'] ?? '');
//     _locationController =
//         TextEditingController(text: widget.workshopData?['location'] ?? '');
//     _capacityController = TextEditingController(
//         text: widget.workshopData?['capacity']?.toString() ?? '');
//
//     _workshopType = widget.workshopData?['workshopType'] ?? "Online";
//     _selectedUniversity = widget.workshopData?['university'];
//     _bannerImagePath = widget.workshopData?['coverImagePath'];
//
//     requireCv = widget.workshopData?['requireCv'] ?? false;
//     requireRoadmap = widget.workshopData?['requireRoadmap'] ?? false;
//     minimumProgress =
//         widget.workshopData?['minimumProgress']?.toDouble() ?? 0;
//
//     if (widget.isEdit) {
//       _initMaterials();
//       _initActivities();
//     }
//   }
//
//   void _initMaterials() {
//     materials = [];
//     for (var m in (widget.workshopData?['materials'] ?? [])) {
//       materials.add({
//         "titleController":
//         TextEditingController(text: m['title'] ?? ''),
//         "pointsController":
//         TextEditingController(text: m['points']?.toString() ?? '0'),
//         "fileName": m['fileName'],
//         "points": m['points'] ?? 0,
//         "file": null,
//       });
//     }
//   }
//
//   void _initActivities() {
//     activities = [];
//     for (var a in (widget.workshopData?['activities'] ?? [])) {
//       activities.add({
//         "titleController":
//         TextEditingController(text: a['title'] ?? ''),
//         "descController":
//         TextEditingController(text: a['description'] ?? ''),
//         "pointsController":
//         TextEditingController(text: a['points']?.toString() ?? '0'),
//         "points": a['points'] ?? 0,
//       });
//     }
//   }
//
//   // ─── Materials ────────────────────────────────────────────────────────────
//   void _addMaterialRow() {
//     setState(() {
//       materials.add({
//         "titleController": TextEditingController(),
//         "pointsController": TextEditingController(text: '0'),
//         "fileName": null,
//         "points": 0,
//         "file": null,
//       });
//     });
//   }
//
//   void _removeMaterialRow(int i) {
//     setState(() {
//       materials[i]["titleController"]?.dispose();
//       materials[i]["pointsController"]?.dispose();
//       materials.removeAt(i);
//     });
//   }
//
//   // ─── Activities ───────────────────────────────────────────────────────────
//   void _addActivityRow() {
//     setState(() {
//       activities.add({
//         "titleController": TextEditingController(),
//         "descController": TextEditingController(),
//         "pointsController": TextEditingController(text: '0'),
//         "points": 0,
//       });
//     });
//   }
//
//   void _removeActivityRow(int i) {
//     setState(() {
//       activities[i]["titleController"]?.dispose();
//       activities[i]["descController"]?.dispose();
//       activities[i]["pointsController"]?.dispose();
//       activities.removeAt(i);
//     });
//   }
//
//   // ─── Dispose ──────────────────────────────────────────────────────────────
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descController.dispose();
//     _startDateController.dispose();
//     _endDateController.dispose();
//     _startTimeController.dispose();
//     _endTimeController.dispose();
//     _locationController.dispose();
//     _capacityController.dispose();
//     for (var m in materials) {
//       m["titleController"]?.dispose();
//       m["pointsController"]?.dispose();
//     }
//     for (var a in activities) {
//       a["titleController"]?.dispose();
//       a["descController"]?.dispose();
//       a["pointsController"]?.dispose();
//     }
//     super.dispose();
//   }
//
//   // ─── Validation ───────────────────────────────────────────────────────────
//   bool _validateForm({required bool isDraft}) {
//     setState(() => _errors = {});
//     if (isDraft) return true;
//
//     bool ok = true;
//
//     void err(String key, String msg) {
//       _errors[key] = msg;
//       ok = false;
//     }
//
//     if (_titleController.text.trim().isEmpty)
//       err('title', 'Workshop title is required');
//     if (_descController.text.trim().isEmpty)
//       err('description', 'Description is required');
//     if (_startDateController.text.trim().isEmpty)
//       err('startDate', 'Start date is required');
//     if (_endDateController.text.trim().isEmpty)
//       err('endDate', 'End date is required');
//     if (_startTimeController.text.trim().isEmpty)
//       err('startTime', 'Start time is required');
//     if (_endTimeController.text.trim().isEmpty)
//       err('endTime', 'End time is required');
//     if (_locationController.text.trim().isEmpty)
//       err('location', 'Location is required');
//
//     final capacity = int.tryParse(_capacityController.text);
//     if (capacity == null || capacity <= 0)
//       err('capacity', 'Valid capacity is required');
//
//     if (_selectedUniversity == null)
//       err('university', 'University partner is required');
//
//     if (_startDateController.text.isNotEmpty &&
//         _endDateController.text.isNotEmpty) {
//       try {
//         final start =
//         DateFormat('yyyy-MM-dd').parse(_startDateController.text);
//         final end =
//         DateFormat('yyyy-MM-dd').parse(_endDateController.text);
//         if (end.isBefore(start))
//           err('endDate', 'End date must be after start date');
//       } catch (_) {
//         err('startDate', 'Invalid date format');
//       }
//     }
//
//     if (!ok) {
//       setState(() {});
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please fill in all required fields'),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//     return ok;
//   }
//
//   Map<String, dynamic> _buildPayload({required String status}) => {
//     "title": _titleController.text.trim(),
//     "description": _descController.text.trim(),
//     "startDate": _startDateController.text,
//     "endDate": _endDateController.text,
//     "startTime": _startTimeController.text,
//     "endTime": _endTimeController.text,
//     "location": _locationController.text.trim(),
//     "capacity": int.tryParse(_capacityController.text) ?? 0,
//     "workshopType": _workshopType,
//     "university": _selectedUniversity,
//     "requireCv": requireCv,
//     "requireRoadmap": requireRoadmap,
//     "minimumProgress": minimumProgress,
//     "coverImagePath": _bannerImagePath,
//     "materials": materials
//         .map((m) => {
//       "title": m["titleController"].text.trim(),
//       "fileName": m["fileName"],
//       "points": m["points"],
//       "file": m["file"],
//     })
//         .toList(),
//     "activities": activities
//         .map((a) => {
//       "title": a["titleController"].text.trim(),
//       "description": a["descController"].text.trim(),
//       "points": a["points"],
//     })
//         .toList(),
//     "status": status,
//     "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
//   };
//
//   Future<void> _handleSubmit({required bool isDraft}) async {
//     if (_isSubmitting) return;
//     if (!_validateForm(isDraft: isDraft)) return;
//     setState(() => _isSubmitting = true);
//     try {
//       await Future.delayed(const Duration(milliseconds: 400));
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text(isDraft
//               ? 'Draft saved successfully!'
//               : 'Workshop published successfully!'),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//         ));
//         Navigator.pop(
//             context, _buildPayload(status: isDraft ? "Draft" : "Published"));
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text('Error: ${e.toString()}'),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//         ));
//       }
//     } finally {
//       if (mounted) setState(() => _isSubmitting = false);
//     }
//   }
//
//   // ─── Date / Time pickers ──────────────────────────────────────────────────
//   Future<void> _pickDate(
//       TextEditingController ctrl, String field) async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2100),
//       builder: (ctx, child) => Theme(
//         data: Theme.of(ctx).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xff3B82F6),
//             onPrimary: Colors.white,
//             onSurface: Colors.black,
//           ),
//         ),
//         child: child!,
//       ),
//     );
//     if (picked != null) {
//       setState(() {
//         ctrl.text = DateFormat('yyyy-MM-dd').format(picked);
//         _errors[field] = null;
//       });
//     }
//   }
//
//   Future<void> _pickTime(
//       TextEditingController ctrl, String field) async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//       builder: (ctx, child) => Theme(
//         data: Theme.of(ctx).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: Color(0xff3B82F6),
//             onPrimary: Colors.white,
//             onSurface: Colors.black,
//           ),
//         ),
//         child: child!,
//       ),
//     );
//     if (picked != null) {
//       setState(() {
//         ctrl.text = picked.format(context);
//         _errors[field] = null;
//       });
//     }
//   }
//
//   // ─── Helpers ──────────────────────────────────────────────────────────────
//   Widget _errorText(String field) {
//     if (_errors[field] == null) return const SizedBox.shrink();
//     return Padding(
//       padding: const EdgeInsets.only(top: 4),
//       child: Text(_errors[field]!,
//           style: const TextStyle(color: Colors.red, fontSize: 12)),
//     );
//   }
//
//   // ─── Build ────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.isEdit ? "Edit Workshop" : "Create Workshop",
//           style: const TextStyle(color: Colors.white),
//         ),
//         backgroundColor: const Color(0xff1893ff),
//         iconTheme: const IconThemeData(color: Colors.white),
//         elevation: 0,
//       ),
//       backgroundColor: Colors.grey[100],
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               // ── Basic Information ────────────────────────────────────────
//               SectionWidget(
//                 title: "Basic Information",
//                 children: [
//                   TextFieldWidget(
//                     controller: _titleController,
//                     label: "Workshop Title",
//                     hint: "e.g., AI Career Bootcamp",
//                   ),
//                   _errorText('title'),
//                   const SizedBox(height: 12),
//                   TextAreaWidget(
//                     controller: _descController,
//                     label: "Description",
//                     hint:
//                     "Describe the goals and activities of this workshop...",
//                   ),
//                   _errorText('description'),
//                   const SizedBox(height: 12),
//                   UploadContainerWidget(
//                     title: "Upload Workshop Banner",
//                     selectedImagePath: _bannerImagePath,
//                     onImageChanged: (path) =>
//                         setState(() => _bannerImagePath = path),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 16),
//
//               // ── Collaboration Details ────────────────────────────────────
//               SectionWidget(
//                 title: "Collaboration Details",
//                 children: [
//                   CustomDropdown(
//                     label: "Select University Partner",
//                     items: _universities,
//                     value: _selectedUniversity,
//                     onChanged: (v) => setState(() {
//                       _selectedUniversity = v;
//                       _errors['university'] = null;
//                     }),
//                     hint: "Select University",
//                   ),
//                   _errorText('university'),
//                   const SizedBox(height: 12),
//                   TextFieldWidget(
//                     controller: _locationController,
//                     label: "Location",
//                     hint: "Online / Onsite (Campus Hall, Building…)",
//                   ),
//                   _errorText('location'),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: DateFieldWidget(
//                           controller: _startDateController,
//                           label: "Start Date",
//                           hint: "Select Date",
//                           errorText: _errors['startDate'],
//                           onTap: () =>
//                               _pickDate(_startDateController, 'startDate'),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: DateFieldWidget(
//                           controller: _endDateController,
//                           label: "End Date",
//                           hint: "Select Date",
//                           errorText: _errors['endDate'],
//                           onTap: () =>
//                               _pickDate(_endDateController, 'endDate'),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextFieldWidget(
//                           controller: _startTimeController,
//                           label: "Start Time",
//                           hint: "Select time",
//                           suffixIcon: const Icon(Icons.access_time,
//                               color: Color(0xff1893ff)),
//                           onTap: () =>
//                               _pickTime(_startTimeController, 'startTime'),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: TextFieldWidget(
//                           controller: _endTimeController,
//                           label: "End Time",
//                           hint: "Select time",
//                           suffixIcon: const Icon(Icons.access_time,
//                               color: Color(0xff1893ff)),
//                           onTap: () =>
//                               _pickTime(_endTimeController, 'endTime'),
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (_errors['startTime'] != null ||
//                       _errors['endTime'] != null)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 4),
//                       child: Text(
//                         _errors['startTime'] ?? _errors['endTime'] ?? '',
//                         style: const TextStyle(
//                             color: Colors.red, fontSize: 12),
//                       ),
//                     ),
//                 ],
//               ),
//
//               const SizedBox(height: 16),
//
//               // ── Capacity & Type ──────────────────────────────────────────
//               SectionWidget(
//                 title: "Capacity & Type",
//                 children: [
//                   TextFieldWidget(
//                     controller: _capacityController,
//                     label: "Max Capacity",
//                     hint: "e.g., 100 attendees",
//                     keyboardType: TextInputType.number,
//                   ),
//                   _errorText('capacity'),
//                   const SizedBox(height: 12),
//                   CustomDropdown(
//                     label: "Workshop Type",
//                     items: const ["Online", "Onsite", "Hybrid"],
//                     value: _workshopType,
//                     onChanged: (v) =>
//                         setState(() => _workshopType = v ?? "Online"),
//                     hint: "Select Workshop Type",
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 16),
//
//               // ── Materials ────────────────────────────────────────────────
//               SectionWidget(
//                 title: "Materials Provided",
//                 children: [
//                   ...materials.asMap().entries.map((entry) {
//                     final i = entry.key;
//                     final m = entry.value;
//                     return Container(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(12),
//                         color: Colors.grey[50],
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment:
//                             MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text("Material ${i + 1}",
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 16)),
//                               IconButton(
//                                 onPressed: () => _removeMaterialRow(i),
//                                 icon: const Icon(Icons.delete,
//                                     color: Colors.red),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           TextField(
//                             controller: m["titleController"],
//                             decoration: InputDecoration(
//                               labelText: "Material Title",
//                               filled: true,
//                               fillColor: Colors.white,
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12)),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               Expanded(
//                                 flex: 3,
//                                 child: GestureDetector(
//                                   onTap: () => setState(() =>
//                                   m["fileName"] =
//                                   "example_material.pdf"),
//                                   child: Container(
//                                     height: 50,
//                                     decoration: BoxDecoration(
//                                       color: Colors.blue.shade50,
//                                       borderRadius:
//                                       BorderRadius.circular(12),
//                                       border: Border.all(
//                                           color: const Color(0xff1893ff)),
//                                     ),
//                                     child: Center(
//                                       child: Row(
//                                         mainAxisAlignment:
//                                         MainAxisAlignment.center,
//                                         children: [
//                                           const Icon(Icons.upload_file,
//                                               color: Color(0xff1893ff),
//                                               size: 20),
//                                           const SizedBox(width: 8),
//                                           Text(
//                                             m["fileName"] ?? "Upload File",
//                                             style: TextStyle(
//                                               color: m["fileName"] == null
//                                                   ? const Color(0xff1893ff)
//                                                   : Colors.green,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               SizedBox(
//                                 width: 80,
//                                 child: TextField(
//                                   controller: m["pointsController"],
//                                   keyboardType: TextInputType.number,
//                                   textAlign: TextAlign.center,
//                                   decoration: InputDecoration(
//                                     labelText: "Points",
//                                     filled: true,
//                                     fillColor: Colors.white,
//                                     border: OutlineInputBorder(
//                                         borderRadius:
//                                         BorderRadius.circular(12)),
//                                   ),
//                                   onChanged: (val) => setState(
//                                           () => m["points"] =
//                                           int.tryParse(val) ?? 0),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//                   const SizedBox(height: 8),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 44,
//                     child: ElevatedButton.icon(
//                       onPressed: _addMaterialRow,
//                       icon: const Icon(Icons.add, color: Colors.white),
//                       label: const Text("Add Material",
//                           style: TextStyle(color: Colors.white)),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xff1893ff),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 16),
//
//               // ── Activities ───────────────────────────────────────────────
//               SectionWidget(
//                 title: "Activities Inside Workshop",
//                 children: [
//                   ...activities.asMap().entries.map((entry) {
//                     final i = entry.key;
//                     final a = entry.value;
//                     return Container(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(12),
//                         color: Colors.grey[50],
//                       ),
//                       child: Column(
//                         children: [
//                           Row(
//                             mainAxisAlignment:
//                             MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text("Activity ${i + 1}",
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 16)),
//                               IconButton(
//                                 onPressed: () => _removeActivityRow(i),
//                                 icon: const Icon(Icons.delete,
//                                     color: Colors.red),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           TextField(
//                             controller: a["titleController"],
//                             decoration: InputDecoration(
//                               labelText: "Activity Name",
//                               filled: true,
//                               fillColor: Colors.white,
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12)),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           TextField(
//                             controller: a["descController"],
//                             maxLines: 3,
//                             decoration: InputDecoration(
//                               labelText: "Description",
//                               filled: true,
//                               fillColor: Colors.white,
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12)),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           TextField(
//                             controller: a["pointsController"],
//                             keyboardType: TextInputType.number,
//                             textAlign: TextAlign.center,
//                             decoration: InputDecoration(
//                               labelText: "Points",
//                               filled: true,
//                               fillColor: Colors.white,
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12)),
//                             ),
//                             onChanged: (val) => setState(() =>
//                             a["points"] =
//                                 int.tryParse(val) ?? a["points"]),
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//                   const SizedBox(height: 8),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 44,
//                     child: ElevatedButton.icon(
//                       onPressed: _addActivityRow,
//                       icon: const Icon(Icons.add, color: Colors.white),
//                       label: const Text("Add Activity",
//                           style: TextStyle(color: Colors.white)),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xff1893ff),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 16),
//
//               // ── Registration Requirements ─────────────────────────────────
//               SectionWidget(
//                 title: "Registration Requirements",
//                 children: [
//                   SwitchListTile(
//                     title: const Text("Require CV Upload?"),
//                     value: requireCv,
//                     onChanged: (v) => setState(() => requireCv = v),
//                     activeColor: const Color(0xff1893ff),
//                     activeTrackColor: const Color(0xffa3c9ff),
//                     inactiveThumbColor: Colors.grey,
//                     inactiveTrackColor: Colors.grey[300],
//                   ),
//                   const Divider(),
//                   SwitchListTile(
//                     title: const Text(
//                         "Require Student Roadmap Completion?"),
//                     value: requireRoadmap,
//                     onChanged: (v) => setState(() => requireRoadmap = v),
//                     activeColor: const Color(0xff1893ff),
//                     activeTrackColor: const Color(0xffa3c9ff),
//                     inactiveThumbColor: Colors.grey,
//                     inactiveTrackColor: Colors.grey[300],
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       const Text("Minimum progress: ",
//                           style: TextStyle(fontWeight: FontWeight.w500)),
//                       Expanded(
//                         child: Slider(
//                           min: 0,
//                           max: 100,
//                           divisions: 20,
//                           label: "${minimumProgress.round()}%",
//                           value: minimumProgress,
//                           activeColor: const Color(0xff1893ff),
//                           inactiveColor:
//                           const Color(0xffa3c9ff).withOpacity(0.3),
//                           onChanged: (v) =>
//                               setState(() => minimumProgress = v),
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: const Color(0xff1893ff),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           "${minimumProgress.round()}%",
//                           style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 24),
//
//               // ── Action Buttons ───────────────────────────────────────────
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       onPressed: _isSubmitting
//                           ? null
//                           : () => _handleSubmit(isDraft: true),
//                       icon: _isSubmitting
//                           ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor:
//                           AlwaysStoppedAnimation<Color>(
//                               Color(0xff1893ff)),
//                         ),
//                       )
//                           : const Icon(Icons.save_outlined),
//                       label: const Text("Save Draft"),
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: const Color(0xff1893ff),
//                         backgroundColor: Colors.white,
//                         side: const BorderSide(
//                             color: Color(0xff1893ff), width: 2),
//                         padding:
//                         const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: _isSubmitting
//                           ? null
//                           : () => _handleSubmit(isDraft: false),
//                       icon: _isSubmitting
//                           ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor:
//                           AlwaysStoppedAnimation<Color>(
//                               Colors.white),
//                         ),
//                       )
//                           : const Icon(Icons.publish),
//                       label: const Text("Publish"),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xff1893ff),
//                         foregroundColor: Colors.white,
//                         padding:
//                         const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }