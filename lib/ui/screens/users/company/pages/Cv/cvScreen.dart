import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../../../data/repositories/Cv repository.dart';


// ══════════════════════════════════════════════════════════════════
//  CvTemplatesScreen
// ══════════════════════════════════════════════════════════════════
class CvTemplatesScreen extends StatefulWidget {
  const CvTemplatesScreen({Key? key}) : super(key: key);

  @override
  State<CvTemplatesScreen> createState() => _CvTemplatesScreenState();
}

class _CvTemplatesScreenState extends State<CvTemplatesScreen> {
  final CvRepository _repo = CvRepository();

  List<Map<String, dynamic>> _templates = [];
  bool    _isLoading = false;
  String? _error;

  static const _kPrimary      = Color(0xff1676C4);
  static const _kPrimaryLight = Color(0xffE8F4FF);
  static const _kBackground   = Color(0xffF5F7FA);
  static const _kCardBg       = Colors.white;
  static const _kTextDark     = Color(0xff1A1A2E);

  @override
  void initState() {
    super.initState();
    _fetchTemplates();
  }

  // ── Fetch ─────────────────────────────────────────────────────
  Future<void> _fetchTemplates() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _repo.getTemplates();
      setState(() => _templates = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Delete ────────────────────────────────────────────────────
  Future<void> _deleteTemplate(dynamic id, String name) async {
    final confirmed = await _showDeleteDialog(name);
    if (confirmed != true) return;
    try {
      final response = await _repo.deleteTemplate(id);
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 204)) {
        setState(() => _templates.removeWhere((t) => t['id'] == id));
        _showSnack("Template deleted successfully", isError: false);
      } else {
        _showSnack("Failed to delete (${response?.statusCode})", isError: true);
      }
    } catch (e) {
      _showSnack("Error: $e", isError: true);
    }
  }

  // ── Open Upload Sheet ─────────────────────────────────────────
  void _openUploadSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UploadTemplateSheet(
        onUpload: (file, title, description) async {
          Navigator.pop(context);
          await _uploadTemplate(file, title, description);
        },
      ),
    );
  }

  Future<void> _uploadTemplate(
      File file, String title, String? description) async {
    setState(() => _isLoading = true);
    try {
      final response = await _repo.uploadTemplate(
        templateFile: file,
        title:        title,
        description:  description,
      );
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        _showSnack("Template uploaded successfully!", isError: false);
        await _fetchTemplates();
      } else {
        _showSnack(
            "Upload failed (${response?.statusCode})\n${response?.data ?? ''}",
            isError: true);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnack("Error: $e", isError: true);
      setState(() => _isLoading = false);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────
  void _showSnack(String msg, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red[400] : Colors.green[600],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: Duration(seconds: isError ? 5 : 3),
    ));
  }

  Future<bool?> _showDeleteDialog(String name) => showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Delete Template",
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: Text(
          'Are you sure you want to delete "$name"?\nThis action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child:
          Text("Cancel", style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Delete"),
        ),
      ],
    ),
  );

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        title: const Text("CV Templates",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
        backgroundColor: _kPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _fetchTemplates,
            tooltip: "Refresh",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openUploadSheet,
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text("Upload Template",
            style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 4,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: _kPrimary));
    }
    if (_error != null) return _buildErrorState();
    if (_templates.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      color: _kPrimary,
      onRefresh: _fetchTemplates,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        itemCount: _templates.length,
        itemBuilder: (_, i) => _buildTemplateCard(_templates[i]),
      ),
    );
  }

  Widget _buildErrorState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.red.shade50, shape: BoxShape.circle),
          child: Icon(Icons.error_outline_rounded,
              size: 48, color: Colors.red[400]),
        ),
        const SizedBox(height: 16),
        const Text("Something went wrong",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(_error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _fetchTemplates,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text("Try Again"),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kPrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ]),
    ),
  );

  Widget _buildEmptyState() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
            color: _kPrimaryLight, shape: BoxShape.circle),
        child: const Icon(Icons.description_outlined,
            size: 64, color: _kPrimary),
      ),
      const SizedBox(height: 20),
      const Text("No CV Templates Yet",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _kTextDark)),
      const SizedBox(height: 8),
      Text("Upload your first CV template to get started",
          style: TextStyle(fontSize: 14, color: Colors.grey[500])),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: _openUploadSheet,
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text("Upload Template",
            style: TextStyle(fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _kPrimary,
          foregroundColor: Colors.white,
          padding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ]),
  );

  Widget _buildTemplateCard(Map<String, dynamic> template) {
    final id          = template['id'];
    final title       = template['title'] ?? template['name'] ?? 'Untitled';
    final description = template['description'] ?? '';
    final filePath    = template['filePath'] ??
        template['fileUrl'] ??
        template['templateUrl'] ??
        '';
    final createdAt =
        template['createdAt'] ?? template['created_at'] ?? '';

    String formattedDate = '';
    if (createdAt.toString().isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt.toString());
        formattedDate = "${dt.day}/${dt.month}/${dt.year}";
      } catch (_) {}
    }

    // ✅ DOC/DOCX only
    final ext = filePath.toString().split('.').last.toLowerCase();
    IconData fileIcon;
    Color    fileColor;
    String   fileLabel;

    if (ext == 'doc' || ext == 'docx') {
      fileIcon  = Icons.article_rounded;
      fileColor = const Color(0xff2B579A);
      fileLabel = 'Word';
    } else {
      fileIcon  = Icons.insert_drive_file_rounded;
      fileColor = Colors.grey;
      fileLabel = ext.isNotEmpty ? ext.toUpperCase() : 'FILE';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kPrimary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Gradient Header ────────────────────────────────────
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_kPrimary, Color(0xff0B5ED7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(19)),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.description_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.white, size: 22),
              onPressed: () => _deleteTemplate(id, title),
              tooltip: "Delete",
            ),
          ]),
        ),

        // ── Body ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description.isNotEmpty) ...[
                  Text(description,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                ],

                // File badge + date row
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: fileColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                      Border.all(color: fileColor.withOpacity(0.3)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(fileIcon, size: 14, color: fileColor),
                      const SizedBox(width: 5),
                      Text(fileLabel,
                          style: TextStyle(
                              fontSize: 11,
                              color: fileColor,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                  if (formattedDate.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Icon(Icons.calendar_today_outlined,
                        size: 13, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(formattedDate,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[400])),
                  ],
                  const Spacer(),
                  if (template['usageCount'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _kPrimaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.people_outline_rounded,
                                size: 13, color: _kPrimary),
                            const SizedBox(width: 4),
                            Text("${template['usageCount']} uses",
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: _kPrimary,
                                    fontWeight: FontWeight.w600)),
                          ]),
                    ),
                ]),
              ]),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  Upload Template Bottom Sheet
// ══════════════════════════════════════════════════════════════════
class _UploadTemplateSheet extends StatefulWidget {
  final Future<void> Function(
      File file, String title, String? description) onUpload;

  const _UploadTemplateSheet({required this.onUpload});

  @override
  State<_UploadTemplateSheet> createState() =>
      _UploadTemplateSheetState();
}

class _UploadTemplateSheetState extends State<_UploadTemplateSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();

  File?   _selectedFile;
  String? _selectedFileName;
  bool    _isUploading = false;
  Map<String, String> _errors = {};

  static const _kPrimary      = Color(0xff1676C4);
  static const _kPrimaryLight = Color(0xffE8F4FF);
  static const _kWordColor    = Color(0xff2B579A);

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ✅ DOC/DOCX only — PDF مش مسموح من الـ backend
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['doc', 'docx'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile     = File(result.files.single.path!);
        _selectedFileName = result.files.single.name;
        _errors.remove('file');
      });
    }
  }

  bool _validate() {
    _errors.clear();
    if (_selectedFile == null)
      _errors['file'] = "Please select a DOC or DOCX file";
    if (_titleCtrl.text.trim().isEmpty)
      _errors['title'] = "Title is required";
    setState(() {});
    return _errors.isEmpty;
  }

  Future<void> _upload() async {
    if (!_validate()) return;
    setState(() => _isUploading = true);
    await widget.onUpload(
      _selectedFile!,
      _titleCtrl.text.trim(),
      _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomPad),
      child: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kPrimary, Color(0xff0B5ED7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(children: [
                  Icon(Icons.upload_file_rounded,
                      color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text("Upload CV Template",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700)),
                ]),
              ),
              const SizedBox(height: 20),

              // Errors
              if (_errors.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _errors.values
                        .map((e) => Text("• $e",
                        style: const TextStyle(
                            color: Colors.red, fontSize: 12)))
                        .toList(),
                  ),
                ),

              // ── File Picker ──────────────────────────────────────
              _buildLabel("Template File * (DOC, DOCX only)"),
              GestureDetector(
                onTap: _pickFile,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _selectedFile != null
                        ? _kWordColor.withOpacity(0.05)
                        : _kPrimaryLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _errors['file'] != null
                          ? Colors.red
                          : (_selectedFile != null
                          ? _kWordColor.withOpacity(0.4)
                          : _kPrimary.withOpacity(0.3)),
                      width: 1.5,
                    ),
                  ),
                  child: _selectedFile == null
                      ? Column(children: [
                    Icon(Icons.cloud_upload_outlined,
                        size: 40,
                        color: _kPrimary.withOpacity(0.6)),
                    const SizedBox(height: 8),
                    const Text("Tap to select file",
                        style: TextStyle(
                            color: _kPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    const SizedBox(height: 4),
                    Text("DOC, DOCX supported",
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 12)),
                  ])
                      : Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _kWordColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.article_rounded,
                          color: _kWordColor, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(_selectedFileName ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(
                              "${(_selectedFile!.lengthSync() / 1024).toStringAsFixed(1)} KB",
                              style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12),
                            ),
                          ]),
                    ),
                    TextButton(
                      onPressed: _pickFile,
                      child: const Text("Change",
                          style: TextStyle(color: _kPrimary)),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              // ── Title ────────────────────────────────────────────
              _buildLabel("Title *"),
              _buildTextField(
                controller: _titleCtrl,
                hint: "e.g., Software Engineer Template",
                icon: Icons.title_rounded,
                error: _errors['title'],
              ),
              const SizedBox(height: 16),

              // ── Description ──────────────────────────────────────
              _buildLabel("Description (optional)"),
              _buildTextField(
                controller: _descCtrl,
                hint: "Brief description of this template",
                icon: Icons.notes_outlined,
              ),
              const SizedBox(height: 24),

              // ── Upload Button ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _upload,
                  icon: _isUploading
                      ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.upload_rounded, size: 20),
                  label: Text(
                    _isUploading ? "Uploading..." : "Upload Template",
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xff374151))),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? error,
  }) =>
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: error != null
                ? Colors.red
                : _kPrimary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
            TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: Icon(icon, color: _kPrimary, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                vertical: 14, horizontal: 8),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      );
}