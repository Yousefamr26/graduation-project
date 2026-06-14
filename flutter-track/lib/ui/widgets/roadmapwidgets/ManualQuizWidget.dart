import 'package:flutter/material.dart';
import '../../screens/users/company/pages/Roadmaps/quizess/QuizEditorScreen.dart';

const _kPrimary      = Color(0xff1893ff);
const _kPrimaryLight = Color(0xffE8F4FF);
const _kBackground   = Color(0xffF5F7FA);
const _kCardBg       = Colors.white;
const _kTextDark     = Color(0xff1A1A2E);
const _kTextMuted    = Color(0xff9CA3AF);
const _kBorder       = Color(0xffE5E7EB);

class ManualQuizWidget extends StatefulWidget {
  const ManualQuizWidget({Key? key}) : super(key: key);

  @override
  State<ManualQuizWidget> createState() => ManualQuizWidgetState();
}

class ManualQuizWidgetState extends State<ManualQuizWidget> {
  final List<Map<String, dynamic>> _quizzes = [];

  List<Map<String, dynamic>> get quizzes => _quizzes;

  List<Map<String, dynamic>> getQuizzesForBackend() =>
      _quizzes.map(_serializeQuiz).toList();

  void _addQuiz() {
    setState(() {
      _quizzes.add({
        'id':              null,
        'titleController': TextEditingController(),
        'questions':       <Map<String, dynamic>>[],
      });
    });
  }

  void _removeQuiz(int index) {
    setState(() {
      (_quizzes[index]['titleController'] as TextEditingController).dispose();
      _quizzes.removeAt(index);
    });
  }

  void _openQuizEditor(int quizIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizEditorScreen(
          quiz: _quizzes[quizIndex],
          onSave: (updated) => setState(() =>
          _quizzes[quizIndex]['questions'] = updated['questions']),
        ),
      ),
    );
  }

  int _totalPoints(int quizIndex) {
    final quiz = _quizzes[quizIndex];

    // ✅ لو AI استخدم savedPoints أو pointsController
    if (quiz['isAi'] == true) {
      return int.tryParse(
          (quiz['pointsController'] as TextEditingController?)?.text ?? ''
      ) ?? (quiz['savedPoints'] ?? 0);
    }

    // ✅ غير كده احسب عادي
    final questions = quiz['questions'] as List;
    return questions.fold<int>(0, (s, q) => s + ((q['points'] as int?) ?? 0));
  }


  Map<String, dynamic> _serializeQuiz(Map<String, dynamic> quiz) {
    final questions = quiz['questions'] as List;
    return {
      if (quiz['id'] != null) 'id': quiz['id'],
      'title':     (quiz['titleController'] as TextEditingController).text,
      'questions': questions.map((q) => {
        if (q['id'] != null) 'id': q['id'],
        'text':          q['text'] ?? '',
        'correctAnswer': q['correctAnswer'] ?? '',
        'points':        q['points'] ?? 5,
        // ✅ options كـ List مش jsonEncode
        'options':       List<String>.from(q['options'] ?? []),
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

  @override
  void dispose() {
    for (var q in _quizzes) {
      (q['titleController'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (_quizzes.isEmpty) _buildEmptyState(),
      ..._quizzes.asMap().entries.map((e) => _buildQuizCard(e.key)),
      const SizedBox(height: 12),
      _buildAddQuizButton(),
    ]);
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _kTextDark)),
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
            _buildManualQuestionsButton(i),
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
                    color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
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
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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

  Widget _buildManualQuestionsButton(int i) {
    final count = (_quizzes[i]['questions'] as List).length;
    return ElevatedButton.icon(
      onPressed: () => _openQuizEditor(i),
      icon: Icon(
          count == 0 ? Icons.add_circle_outline : Icons.edit_note_rounded,
          size: 20),
      label: Text(
        count == 0 ? 'Add Questions' : 'Edit Questions ($count)',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        shadowColor: _kPrimary.withOpacity(0.3),
      ),
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