import 'dart:convert';
import 'package:flutter/material.dart';

import '../../screens/users/company/pages/Roadmaps/quizess/QuizAIGenerationScreen.dart';

const _kPrimary      = Color(0xff1893ff);
const _kPrimaryLight = Color(0xffE8F4FF);
const _kBackground   = Color(0xffF5F7FA);
const _kCardBg       = Colors.white;
const _kTextDark     = Color(0xff1A1A2E);
const _kTextMuted    = Color(0xff9CA3AF);
const _kBorder       = Color(0xffE5E7EB);

enum _QuestionType { mcq, trueFalse }

class AIQuizWidget extends StatefulWidget {
  final String roadmapId;
  final List<Map<String, dynamic>> Function()? getMaterials;

  const AIQuizWidget({
    Key? key,
    required this.roadmapId,
    this.getMaterials,
  }) : super(key: key);

  @override
  State<AIQuizWidget> createState() => AIQuizWidgetState();
}

class AIQuizWidgetState extends State<AIQuizWidget> {
  final List<Map<String, dynamic>> _quizzes = [];

  List<Map<String, dynamic>> getQuizzesForBackend() =>
      _quizzes.map(_serializeQuiz).toList();

  // ── Quiz CRUD ───────────────────────────────────────────

  void _addQuiz() {
    setState(() {
      _quizzes.add({
        'id':                  DateTime.now().millisecondsSinceEpoch,
        'titleController':     TextEditingController(),
        'questionType':        _QuestionType.mcq,
        'questionCount':       10,
        'questions':           <Map<String, dynamic>>[],
        'selectedMaterialIds': <String>{},
      });
    });
  }

  void _removeQuiz(int index) {
    setState(() {
      (_quizzes[index]['titleController'] as TextEditingController).dispose();
      _quizzes.removeAt(index);
    });
  }

  // ── Material selection ──────────────────────────────────

  void _toggleMaterial(int quizIndex, String materialId) {
    setState(() {
      final ids = _quizzes[quizIndex]['selectedMaterialIds'] as Set<String>;
      ids.contains(materialId) ? ids.remove(materialId) : ids.add(materialId);
    });
  }

  void _selectAllMaterials(int quizIndex) {
    setState(() {
      final ids    = _quizzes[quizIndex]['selectedMaterialIds'] as Set<String>;
      final allIds = _allMaterials().map((m) => m['id'] as String).toSet();
      ids.containsAll(allIds) ? ids.clear() : ids.addAll(allIds);
    });
  }

  List<Map<String, dynamic>> _allMaterials() {
    if (widget.getMaterials != null) return widget.getMaterials!();
    return [];
  }

  // ── AI Generate ─────────────────────────────────────────

  Future<void> _generateQuestions(int quizIndex) async {
    final quiz         = _quizzes[quizIndex];
    final questionType = quiz['questionType'] as _QuestionType;
    final count        = quiz['questionCount'] as int;
    final quizTypeParam = questionType == _QuestionType.mcq ? 'MCQ' : 'TrueFalse';

    final result = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      MaterialPageRoute(
        builder: (_) => QuizAIGenerationScreen(
          roadmapId:    widget.roadmapId,
          quizType:     quizTypeParam,
          numQuestions: count,
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        final current = List<Map<String, dynamic>>.from(
            _quizzes[quizIndex]['questions'] as List);
        _quizzes[quizIndex]['questions'] = [...current, ...result];
      });
      _showSnackBar('${result.length} questions added!');
    }
  }

  // ── Helpers ─────────────────────────────────────────────

  int _totalPoints(int quizIndex) {
    final questions = _quizzes[quizIndex]['questions'] as List;
    return questions.fold<int>(0, (s, q) => s + ((q['points'] as int?) ?? 0));
  }

  Map<String, dynamic> _serializeQuiz(Map<String, dynamic> quiz) {
    final questions = quiz['questions'] as List;
    return {
      'title':     (quiz['titleController'] as TextEditingController).text,
      'type':      (quiz['questionType'] as _QuestionType).name,
      'points':    questions.fold<int>(0, (s, q) => s + ((q['points'] as int?) ?? 0)),
      'questions': questions.map((q) => {
        'text':          q['text'] ?? '',
        'type':          q['type'] ?? 'MCQ',
        'optionsJson':   jsonEncode(q['options'] ?? []),
        'correctAnswer': q['correctAnswer'] ?? '',
        'points':        q['points'] ?? 5,
      }).toList(),
    };
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red[400] : _kPrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── BUILD ───────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildGlobalAICard(),
      const SizedBox(height: 16),
      if (_quizzes.isEmpty) _buildEmptyState(),
      ..._quizzes.asMap().entries.map((e) => _buildQuizCard(e.key)),
      const SizedBox(height: 12),
      _buildAddQuizButton(),
    ]);
  }

  Widget _buildGlobalAICard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kPrimary, Color(0xff0B5ED7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI Quiz Generator',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            SizedBox(height: 4),
            Text('Configure each quiz below and tap Generate',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(50),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kPrimary.withOpacity(0.2)),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(color: _kPrimaryLight, shape: BoxShape.circle),
          child: const Icon(Icons.quiz_outlined, size: 56, color: _kPrimary),
        ),
        const SizedBox(height: 20),
        const Text('No Quizzes Yet',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: _kTextDark)),
        const SizedBox(height: 6),
        Text('Start by adding a quiz',
            style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ]),
    );
  }

  Widget _buildQuizCard(int i) {
    final quiz            = _quizzes[i];
    final titleController = quiz['titleController'] as TextEditingController;
    final questions       = quiz['questions'] as List;
    final totalPoints     = _totalPoints(i);
    final questionCount   = questions.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kPrimary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
              color: _kPrimary.withOpacity(0.07),
              blurRadius: 20,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(children: [
        _buildQuizHeader(i, titleController),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            _buildTitleField(titleController),
            const SizedBox(height: 16),
            _buildStatsRow(questionCount, totalPoints),
            const SizedBox(height: 16),
            _buildMaterialsSection(i),
            const SizedBox(height: 16),
            _buildAIGeneratorCard(i),
          ]),
        ),
      ]),
    );
  }

  Widget _buildQuizHeader(int i, TextEditingController titleController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kPrimary, Color(0xff0B5ED7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.quiz_outlined, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('QUIZ ${i + 1}',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2)),
            const SizedBox(height: 2),
            ValueListenableBuilder(
              valueListenable: titleController,
              builder: (_, __, ___) => Text(
                titleController.text.isEmpty ? 'Untitled Quiz' : titleController.text,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
          onPressed: () => _removeQuiz(i),
        ),
      ]),
    );
  }

  Widget _buildTitleField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kPrimary.withOpacity(0.3), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'e.g., Week 1 Assessment',
          labelText: 'Quiz Title',
          labelStyle: const TextStyle(
              color: _kPrimary, fontWeight: FontWeight.w600, fontSize: 13),
          hintStyle: const TextStyle(color: _kTextMuted),
          prefixIcon: const Icon(Icons.edit_outlined, color: _kPrimary, size: 20),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        ),
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500, color: _kTextDark),
      ),
    );
  }

  Widget _buildStatsRow(int questionCount, int totalPoints) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kPrimaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kPrimary.withOpacity(0.2)),
      ),
      child: IntrinsicHeight(
        child: Row(children: [
          Expanded(child: _buildStatItem(
            icon: Icons.help_outline_rounded,
            iconBg: _kCardBg,
            iconColor: _kPrimary,
            value: '$questionCount',
            label: 'Questions',
          )),
          VerticalDivider(color: _kPrimary.withOpacity(0.2), width: 32),
          Expanded(child: _buildStatItem(
            icon: Icons.stars_rounded,
            iconBg: _kPrimary,
            iconColor: Colors.white,
            value: '$totalPoints',
            label: 'Points',
          )),
        ]),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      const SizedBox(height: 8),
      Text(value,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: _kPrimary)),
      Text(label,
          style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _buildMaterialsSection(int quizIndex) {
    final materials   = _allMaterials();
    final selectedIds = _quizzes[quizIndex]['selectedMaterialIds'] as Set<String>;
    final allSelected = materials.isNotEmpty &&
        selectedIds.containsAll(materials.map((m) => m['id']));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Select Materials',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: _kTextDark)),
        GestureDetector(
          onTap: () => _selectAllMaterials(quizIndex),
          child: Text(allSelected ? 'Deselect All' : 'Select All',
              style: const TextStyle(
                  fontSize: 13, color: _kPrimary, fontWeight: FontWeight.w600)),
        ),
      ]),
      const SizedBox(height: 10),
      if (materials.isEmpty)
        _buildNoMaterialsPlaceholder()
      else
        ...materials.map((m) => _buildMaterialTile(
          quizIndex: quizIndex,
          material: m,
          isSelected: selectedIds.contains(m['id']),
        )),
    ]);
  }

  Widget _buildNoMaterialsPlaceholder() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: _kBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Row(children: [
        Icon(Icons.folder_open_rounded, color: Colors.grey[400], size: 22),
        const SizedBox(width: 12),
        Text('No materials in this roadmap yet',
            style: TextStyle(color: Colors.grey[500], fontSize: 13)),
      ]),
    );
  }

  Widget _buildMaterialTile({
    required int quizIndex,
    required Map<String, dynamic> material,
    required bool isSelected,
  }) {
    final isPDF     = material['type'] == 'pdf';
    final icon      = isPDF ? Icons.picture_as_pdf_rounded : Icons.play_circle_rounded;
    final iconColor = isPDF ? Colors.red[400]! : _kPrimary;
    final iconBg    = isPDF ? Colors.red[50]! : _kPrimaryLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? _kPrimary.withOpacity(0.5) : _kBorder,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(material['title'] as String,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _kTextDark)),
        subtitle: Text(material['subtitle'] as String,
            style: const TextStyle(fontSize: 11, color: _kTextMuted)),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (_) =>
              _toggleMaterial(quizIndex, material['id'] as String),
          activeColor: _kPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        onTap: () => _toggleMaterial(quizIndex, material['id'] as String),
      ),
    );
  }

  Widget _buildAIGeneratorCard(int i) {
    final quiz        = _quizzes[i];
    final currentType = quiz['questionType'] as _QuestionType;
    final count       = quiz['questionCount'] as int;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kPrimary, Color(0xff0B5ED7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text('AI Generator',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: _QuestionType.values.map((type) {
              final isActive = currentType == type;
              final label = type == _QuestionType.mcq ? 'MCQ' : 'True / False';
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _quizzes[i]['questionType'] = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: Text(label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isActive ? _kPrimary : Colors.white,
                        )),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Questions count',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$count',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
          ),
        ]),
        Slider(
          value: count.toDouble(),
          min: 1,
          max: 20,
          divisions: 19,
          activeColor: Colors.white,
          inactiveColor: Colors.white.withOpacity(0.3),
          thumbColor: Colors.white,
          onChanged: (v) =>
              setState(() => _quizzes[i]['questionCount'] = v.round()),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _generateQuestions(i),
            icon: const Icon(Icons.rocket_launch_rounded, size: 18),
            label: const Text('Generate Questions',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _kPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildAddQuizButton() {
    return OutlinedButton.icon(
      onPressed: _addQuiz,
      icon: const Icon(Icons.add_circle_outline, size: 22),
      label: const Text('Add New Quiz',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      style: OutlinedButton.styleFrom(
        foregroundColor: _kPrimary,
        side: const BorderSide(color: _kPrimary, width: 2),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: _kCardBg,
      ),
    );
  }
}