import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../../../../data/repositories/roadmap_repository.dart';

const _kPrimary      = Color(0xff1893ff);
const _kPrimaryLight = Color(0xffE8F4FF);
const _kBackground   = Color(0xffF5F7FA);
const _kCardBg       = Colors.white;
const _kTextDark     = Color(0xff1A1A2E);
const _kTextMuted    = Color(0xff9CA3AF);
const _kBorder       = Color(0xffE5E7EB);

class QuizAIGenerationScreen extends StatefulWidget {
  final String roadmapId;
  final String quizType;
  final int    numQuestions;

  const QuizAIGenerationScreen({
    Key? key,
    required this.roadmapId,
    required this.quizType,
    required this.numQuestions,
  }) : super(key: key);

  @override
  State<QuizAIGenerationScreen> createState() => _QuizAIGenerationScreenState();
}

class _QuizAIGenerationScreenState extends State<QuizAIGenerationScreen> {
  final RoadmapRepository _repo = RoadmapRepository();

  bool    _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _generated = [];
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    _generateAndPoll();
  }

  // ── Step 1: trigger generation ─────────────────────────────
  Future<void> _generateAndPoll() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; _generated = []; _selected.clear(); });

    try {
      // ✅ Step 1: POST لتشغيل الـ AI generation
      final genResponse = await _repo.generateAiQuiz(
        roadmapId:    int.parse(widget.roadmapId),
        quizType:     widget.quizType,
        numQuestions: widget.numQuestions,
      );

      debugPrint('🤖 [GENERATE] Status: ${genResponse?.statusCode}');

      if (genResponse == null ||
          (genResponse.statusCode != 200 &&
              genResponse.statusCode != 201 &&
              genResponse.statusCode != 202)) {
        setState(() {
          _error     = 'Failed to start generation (${genResponse?.statusCode})';
          _isLoading = false;
        });
        return;
      }

      // ✅ Step 2: Poll حتى تكتمل
      await _pollForResult();

    } catch (e) {
      debugPrint('❌ [GENERATE ERROR] $e');
      if (!mounted) return;
      setState(() { _error = 'Error: $e'; _isLoading = false; });
    }
  }

  // ── Step 2: poll until COMPLETED ───────────────────────────
  Future<void> _pollForResult() async {
    const maxRetries = 20;
    const delay      = Duration(seconds: 3);

    for (int i = 0; i < maxRetries; i++) {
      await Future.delayed(delay);
      if (!mounted) return;

      try {
        final fetchResponse = await _repo.getGeneratedQuiz(
          int.parse(widget.roadmapId),
        );
        if (fetchResponse == null) continue;

        debugPrint('🔄 [POLL $i] Status: ${fetchResponse.statusCode}');

        final responseData = fetchResponse.data;

        if (responseData is Map) {
          final status = responseData['status'];
          final code   = responseData['code'];

          // لسه شغال
          if (status == 'PENDING' || code == 'QUIZ_NOT_READY') continue;

          // اكتمل
          if (status == 'COMPLETED' || responseData['data'] != null) {
            final questions = _parseQuestions(responseData);
            debugPrint('✅ [POLL] Parsed ${questions.length} questions');

            if (!mounted) return;
            setState(() {
              _generated = questions;
              _selected.addAll(List.generate(questions.length, (i) => i));
              _isLoading = false;
            });
            return;
          }
        }
      } catch (e) {
        debugPrint('⚠️ [POLL $i] Error: $e');
        continue;
      }
    }

    // timeout
    if (mounted) {
      setState(() {
        _error     = 'Quiz generation timed out. Please try again.';
        _isLoading = false;
      });
    }
  }

  // ── Parse questions from API response ──────────────────────
  List<Map<String, dynamic>> _parseQuestions(Map responseData) {
    try {
      final dataList = responseData['data'];
      if (dataList == null || dataList is! List || dataList.isEmpty) return [];

      final firstQuiz = dataList[0];
      if (firstQuiz is! Map) return [];

      final rawQuestions    = firstQuiz['questions'];
      if (rawQuestions == null || rawQuestions is! List) return [];

      // ✅ احسب points لكل question
      final quizTotalPoints   = (firstQuiz['points'] as num? ?? 0).toInt();
      final questionCount     = rawQuestions.length;
      final pointsPerQuestion = questionCount > 0
          ? (quizTotalPoints / questionCount).round()
          : 5;

      debugPrint('✅ [POINTS] Quiz total: $quizTotalPoints | Per Q: $pointsPerQuestion');

      return rawQuestions.map<Map<String, dynamic>>((q) {
        final question  = Map<String, dynamic>.from(q as Map);
        final optionsRaw = question['optionsJson'];

        // ✅ parse options
        if (optionsRaw is String) {
          try {
            question['options'] = jsonDecode(optionsRaw) as List;
          } catch (_) {
            question['options'] = [];
          }
        } else if (optionsRaw is List) {
          question['options'] = optionsRaw;
        } else {
          question['options'] = [];
        }

        // ✅ اضبط الـ points لو مش موجودة
        question['points'] ??= pointsPerQuestion;

        // ✅ normalize field names
        question['text'] ??= question['questionText'] ?? '';

        return question;
      }).where((q) => (q['text'] as String? ?? '').isNotEmpty).toList();

    } catch (e) {
      debugPrint('❌ [PARSE] Error: $e');
      return [];
    }
  }

  // ── Actions ─────────────────────────────────────────────────

  void _toggle(int index) => setState(() {
    _selected.contains(index) ? _selected.remove(index) : _selected.add(index);
  });

  void _selectAll() => setState(() {
    _selected.length == _generated.length
        ? _selected.clear()
        : _selected.addAll(List.generate(_generated.length, (i) => i));
  });

  void _addToQuiz() =>
      Navigator.pop(context, _selected.map((i) => _generated[i]).toList());

  void _discard() => Navigator.pop(context, <Map<String, dynamic>>[]);

  int get _mcqCount => _generated.where((q) => q['type'] == 'MCQ').length;
  int get _tfCount  => _generated.where((q) => q['type'] == 'TrueFalse').length;

  // ── BUILD ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      body: Column(children: [
        _buildHeader(),
        Expanded(child: _buildBody()),
        if (!_isLoading && _error == null) _buildBottomBar(),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16, right: 16, bottom: 16,
      ),
      color: _kCardBg,
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.close_rounded, color: _kTextDark),
          onPressed: _discard,
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text('AI GENERATION RESULT',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _kTextMuted,
                  letterSpacing: 1.2)),
        ),
        if (!_isLoading && _error == null && _generated.isNotEmpty)
          TextButton(
            onPressed: _selectAll,
            child: Text(
              _selected.length == _generated.length ? 'Deselect All' : 'Select All',
              style: const TextStyle(color: _kPrimary, fontWeight: FontWeight.w600),
            ),
          ),
      ]),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildLoadingState();
    if (_error != null) return _buildErrorState();
    if (_generated.isEmpty) return _buildEmptyState();
    return _buildQuestionsList();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: _kPrimaryLight, shape: BoxShape.circle),
          child: const CircularProgressIndicator(color: _kPrimary),
        ),
        const SizedBox(height: 24),
        const Text('AI is generating your questions...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _kTextDark)),
        const SizedBox(height: 8),
        Text('This may take a few seconds',
            style: TextStyle(fontSize: 13, color: Colors.grey[500])),
      ]),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
            child: Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          ),
          const SizedBox(height: 20),
          const Text('Generation Failed',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _kTextDark)),
          const SizedBox(height: 8),
          Text(_error!, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _generateAndPoll,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.quiz_outlined, size: 56, color: Colors.grey[400]),
        const SizedBox(height: 16),
        const Text('No questions generated', style: TextStyle(fontSize: 16, color: _kTextDark)),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _generateAndPoll,
          style: ElevatedButton.styleFrom(backgroundColor: _kPrimary),
          child: const Text('Retry', style: TextStyle(color: Colors.white)),
        ),
      ]),
    );
  }

  Widget _buildQuestionsList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _buildInsightCard(),
        const SizedBox(height: 16),
        ..._generated.asMap().entries.map((e) => _buildQuestionCard(e.key, e.value)),
      ],
    );
  }

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kPrimaryLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kPrimary.withOpacity(0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: _kCardBg, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.auto_awesome, color: _kPrimary, size: 16),
          ),
          const SizedBox(width: 8),
          const Text('AI INSIGHT',
              style: TextStyle(fontSize: 11, color: _kPrimary,
                  fontWeight: FontWeight.w700, letterSpacing: 1)),
        ]),
        const SizedBox(height: 12),
        Text('${_generated.length} Questions Generated',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _kTextDark)),
        const SizedBox(height: 4),
        Text('Review and select which to add to the quiz',
            style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        const SizedBox(height: 16),
        Row(children: [
          if (_mcqCount > 0) ...[_buildBadge('$_mcqCount MCQ'), const SizedBox(width: 12)],
          if (_tfCount > 0) _buildBadge('$_tfCount True/False'),
        ]),
      ]),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kPrimary.withOpacity(0.3)),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 12, color: _kPrimary, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildQuestionCard(int index, Map<String, dynamic> question) {
    final text          = (question['text'] ?? 'Question ${index + 1}').toString();
    final correctAnswer = (question['correctAnswer'] ?? question['answer'] ?? '').toString().trim();
    final options       = question['options'] ?? <dynamic>[];
    final points        = question['points'] ?? 0;
    final isSelected    = _selected.contains(index);

    return GestureDetector(
      onTap: () => _toggle(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _kPrimary.withOpacity(0.5) : _kBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
              child: Row(children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: isSelected ? _kPrimary : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('${index + 1}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(text,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: _kTextDark)),
                ),
                const SizedBox(width: 8),
                // ✅ Points badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.stars, size: 14, color: Colors.amber),
                    const SizedBox(width: 3),
                    Text('$points pts',
                        style: const TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.bold)),
                  ]),
                ),
                // Checkbox
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => _toggle(index),
                  activeColor: _kPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ]),
            ),

            // ── Options ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: options is List && options.isNotEmpty
                  ? Column(
                children: List.generate(options.length, (i) {
                  final opt = options[i].toString().trim();

                  // ✅ إصلاح correct answer matching
                  bool isCorrect = false;
                  if (opt.isNotEmpty && correctAnswer.isNotEmpty) {
                    // حالة 1: correctAnswer حرف واحد + option يبدأ بـ "X)"
                    if (correctAnswer.length == 1 && opt.length >= 2 && opt[1] == ')') {
                      isCorrect = opt[0].toUpperCase() == correctAnswer.toUpperCase();
                    }
                    // حالة 2: مطابقة كاملة
                    else if (opt.toUpperCase() == correctAnswer.toUpperCase()) {
                      isCorrect = true;
                    }
                    // حالة 3: الـ option يبدأ بالـ correctAnswer
                    else if (opt.toUpperCase().startsWith(correctAnswer.toUpperCase())) {
                      isCorrect = true;
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCorrect ? Colors.green.withOpacity(0.4) : Colors.grey[200]!,
                      ),
                    ),
                    child: Row(children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.radio_button_unchecked,
                        size: 16,
                        color: isCorrect ? Colors.green : Colors.grey[400],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(opt,
                            style: TextStyle(
                              fontSize: 13,
                              color: isCorrect ? Colors.green[800] : Colors.grey[800],
                              fontWeight: isCorrect ? FontWeight.w600 : FontWeight.normal,
                            )),
                      ),
                    ]),
                  );
                }),
              )
                  : Row(children: [
                _tfChip('True',  correctAnswer.toLowerCase() == 'true'),
                const SizedBox(width: 8),
                _tfChip('False', correctAnswer.toLowerCase() == 'false'),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tfChip(String label, bool isCorrect) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect ? Colors.green.withOpacity(0.4) : Colors.grey[200]!,
        ),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(isCorrect ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16, color: isCorrect ? Colors.green : Colors.grey[400]),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
              fontSize: 13,
              color: isCorrect ? Colors.green[800] : Colors.grey[700],
              fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
            )),
      ]),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: _kCardBg,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4))
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: _kPrimaryLight, borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check_box_rounded, color: _kPrimary, size: 18),
            const SizedBox(width: 6),
            Text('${_selected.length} selected',
                style: const TextStyle(fontSize: 13, color: _kPrimary, fontWeight: FontWeight.w700)),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _discard,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kTextMuted,
                  side: const BorderSide(color: _kBorder),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Discard', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: _selected.isEmpty ? null : _addToQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add to Quiz', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}