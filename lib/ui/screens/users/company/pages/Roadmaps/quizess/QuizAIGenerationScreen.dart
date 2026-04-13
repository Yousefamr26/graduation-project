import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

const _kPrimary      = Color(0xff1893ff);
const _kPrimaryLight = Color(0xffE8F4FF);
const _kBackground   = Color(0xffF5F7FA);
const _kCardBg       = Colors.white;
const _kTextDark     = Color(0xff1A1A2E);
const _kTextMuted    = Color(0xff9CA3AF);
const _kBorder       = Color(0xffE5E7EB);

class QuizAIGenerationScreen extends StatefulWidget {
  final String roadmapId;
  final String quizType;     // 'MCQ' or 'TrueFalse'
  final int    numQuestions; // 1-20

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
  static const _baseUrl = 'http://smartcareerhub.runasp.net/api/roadmaps';

  bool    _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _generated = [];
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  // ── API ─────────────────────────────────────────────────

  Future<void> _fetchQuestions() async {
    setState(() { _isLoading = true; _error = null; });

    try {
      final dio = Dio();
      final url =
          '$_baseUrl/${widget.roadmapId}/generate-quiz'
          '?quizType=${widget.quizType}'
          '&numQuestions=${widget.numQuestions}';

      debugPrint('🤖 AI Generate: GET $url');

      final response = await dio.get(
        url,
        options: Options(
          validateStatus: (s) => true,
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout:    const Duration(seconds: 30),
        ),
      );

      debugPrint('✅ Status: ${response.statusCode}');
      debugPrint('📦 Data: ${response.data}');

      if (response.statusCode == 200) {
        final raw = response.data;
        List<dynamic> list = [];

        if (raw is List) {
          list = raw;
        } else if (raw is Map) {
          list = raw['questions'] as List?
              ?? raw['data']      as List?
              ?? raw['result']    as List?
              ?? [];
        }

        final parsed = list.map<Map<String, dynamic>>((item) {
          List<String> options = [];
          if (item['options'] is List) {
            options = List<String>.from(
                (item['options'] as List).map((o) => o.toString()));
          } else if (item['optionsJson'] is String) {
            try {
              options = List<String>.from(
                  jsonDecode(item['optionsJson'] as String));
            } catch (_) {}
          }

          return {
            'text':          item['text']?.toString() ?? item['question']?.toString() ?? '',
            'type':          item['type']?.toString() ?? widget.quizType,
            'options':       options,
            'correctAnswer': item['correctAnswer']?.toString() ?? item['answer']?.toString() ?? '',
            'points':        (item['points'] as num?)?.toInt() ?? 5,
          };
        }).where((q) => (q['text'] as String).isNotEmpty).toList();

        setState(() {
          _generated = parsed;
          _selected.addAll(List.generate(parsed.length, (i) => i));
          _isLoading = false;
        });
      } else {
        setState(() {
          _error     = 'Server returned ${response.statusCode}.\n${response.data?.toString() ?? ''}';
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        _error     = 'Network error: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error     = 'Unexpected error: $e';
        _isLoading = false;
      });
    }
  }

  // ── Actions ─────────────────────────────────────────────

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

  // ── BUILD ───────────────────────────────────────────────

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
              _selected.length == _generated.length
                  ? 'Deselect All'
                  : 'Select All',
              style: const TextStyle(
                  color: _kPrimary, fontWeight: FontWeight.w600),
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
          decoration: const BoxDecoration(
              color: _kPrimaryLight, shape: BoxShape.circle),
          child: const CircularProgressIndicator(color: _kPrimary),
        ),
        const SizedBox(height: 24),
        const Text('Generating questions with AI...',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _kTextDark)),
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
            decoration: BoxDecoration(
                color: Colors.red[50], shape: BoxShape.circle),
            child: Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          ),
          const SizedBox(height: 20),
          const Text('Generation Failed',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _kTextDark)),
          const SizedBox(height: 8),
          Text(_error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchQuestions,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
        const Text('No questions generated',
            style: TextStyle(fontSize: 16, color: _kTextDark)),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _fetchQuestions,
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
        ..._generated.asMap().entries.map((e) => _buildQuestionCard(e.key)),
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
            decoration: BoxDecoration(
                color: _kCardBg, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.auto_awesome, color: _kPrimary, size: 16),
          ),
          const SizedBox(width: 8),
          const Text('AI INSIGHT',
              style: TextStyle(
                  fontSize: 11,
                  color: _kPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
        ]),
        const SizedBox(height: 12),
        Text('${_generated.length} Questions Generated',
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _kTextDark)),
        const SizedBox(height: 4),
        Text('Review and select which to add to the quiz',
            style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        const SizedBox(height: 16),
        Row(children: [
          if (_mcqCount > 0) ...[
            _buildBadge('$_mcqCount MCQ'),
            const SizedBox(width: 12),
          ],
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
          style: const TextStyle(
              fontSize: 12, color: _kPrimary, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildQuestionCard(int i) {
    final q          = _generated[i];
    final isSelected = _selected.contains(i);
    final isMCQ      = (q['type'] as String) == 'MCQ';
    final options    = q['options'] as List<String>;
    final correct    = q['correctAnswer'] as String;

    return GestureDetector(
      onTap: () => _toggle(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _kPrimary.withOpacity(0.5) : _kBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            SizedBox(
              width: 22, height: 22,
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => _toggle(i),
                activeColor: _kPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isMCQ ? _kPrimaryLight : Colors.green[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(isMCQ ? 'MCQ' : 'True / False',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isMCQ ? _kPrimary : Colors.green[700],
                  )),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: _kPrimaryLight,
                  borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.stars_rounded, size: 12, color: _kPrimary),
                const SizedBox(width: 4),
                Text('${q['points']}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: _kPrimary,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
          ]),

          const SizedBox(height: 12),
          Text(q['text'] as String,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _kTextDark)),

          // MCQ options
          if (isMCQ && options.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...options.map((opt) {
              final isCorrect = opt == correct;
              return Container(
                margin: const EdgeInsets.only(bottom: 5),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green[50] : _kBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCorrect
                        ? Colors.green.withOpacity(0.4)
                        : Colors.transparent,
                  ),
                ),
                child: Row(children: [
                  Icon(
                    isCorrect
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    size: 14,
                    color: isCorrect
                        ? Colors.green[600]
                        : Colors.grey[400],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(opt,
                        style: TextStyle(
                          fontSize: 13,
                          color: isCorrect
                              ? Colors.green[700]
                              : _kTextDark,
                          fontWeight: isCorrect
                              ? FontWeight.w600
                              : FontWeight.w400,
                        )),
                  ),
                ]),
              );
            }),
          ],

          // True/False correct answer
          if (!isMCQ) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: _kBackground,
                  borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                Text('CORRECT: ',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600)),
                Text(correct,
                    style: const TextStyle(
                        fontSize: 13,
                        color: _kPrimary,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: _kCardBg,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -4))
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
              color: _kPrimaryLight,
              borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check_box_rounded, color: _kPrimary, size: 18),
            const SizedBox(width: 6),
            Text('${_selected.length} selected',
                style: const TextStyle(
                    fontSize: 13,
                    color: _kPrimary,
                    fontWeight: FontWeight.w700)),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Discard',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: _selected.isEmpty ? null : _addToQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add to Quiz',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}