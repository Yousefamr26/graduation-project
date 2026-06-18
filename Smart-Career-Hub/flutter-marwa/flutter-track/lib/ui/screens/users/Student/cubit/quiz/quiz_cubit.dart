import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../../data/services/QuizService.dart';
import 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  final QuizService quizService;
  String? _userType;

  QuizCubit([QuizService? service])
      : quizService = service ?? QuizService(),
        super(QuizInitial());

  Future<void> _initUserType() async {
    if (_userType == null) {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString('student_token') != null) {
        _userType = 'student';
      } else if (prefs.getString('graduate_token') != null) {
        _userType = 'graduate';
      }
    }
  }

  Future<void> loadQuiz(String roadmapId) async {
    emit(QuizLoading());
    try {
      await _initUserType();
      final quiz = await quizService.getGeneratedQuiz(roadmapId, userType: _userType);
      if (quiz == null) {
        emit(QuizError('Quiz not found or empty.'));
        return;
      }
      emit(QuizLoaded(quiz: quiz, selectedAnswers: {}));
    } catch (e) {
      emit(QuizError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> selectAnswer(String questionId, String selectedAnswer, String roadmapId, String quizId) async {
    final currentState = state;
    if (currentState is QuizLoaded) {
      final updatedAnswers = Map<String, String>.from(currentState.selectedAnswers);
      updatedAnswers[questionId] = selectedAnswer;
      emit(currentState.copyWith(selectedAnswers: updatedAnswers));

      try {
        await quizService.submitAnswer(roadmapId, quizId, questionId, selectedAnswer, userType: _userType);
      } catch (_) {
        // Non-blocking submission error: keep local state
      }
    }
  }

  Future<void> submitQuiz(String roadmapId, String quizId) async {
    final currentState = state;
    if (currentState is QuizLoaded) {
      emit(QuizSubmitting(quiz: currentState.quiz, selectedAnswers: currentState.selectedAnswers));

      // Simulate network delay for UX
      await Future.delayed(const Duration(seconds: 1));

      int correctCount = 0;
      List<dynamic> correctAnswersList = [];

      for (var question in currentState.quiz.questions) {
        String correctLetter = question.correctAnswer.trim().toUpperCase();
        if (correctLetter.length > 1) {
          final match = RegExp(r'^([A-Z])[\)\.]').firstMatch(correctLetter);
          if (match != null) {
            correctLetter = match.group(1)!;
          } else {
            correctLetter = correctLetter[0];
          }
        }

        final userAns = currentState.selectedAnswers[question.id.toString()]?.trim().toUpperCase() ?? '';
        String userLetter = '';
        if (userAns.isNotEmpty) {
          final match = RegExp(r'^([A-Z])[\)\.]').firstMatch(userAns);
          userLetter = match != null ? match.group(1)! : userAns[0];
        }

        if (userLetter == correctLetter && userLetter.isNotEmpty) {
          correctCount++;
        }

        // Find full string of the correct answer
        String fullCorrectOption = '';
        for (var opt in question.options) {
          String optTrimmed = opt.trim().toUpperCase();
          final match = RegExp(r'^([A-Z])[\)\.]').firstMatch(optTrimmed);
          final optLetter = match != null ? match.group(1)! : (optTrimmed.isNotEmpty ? optTrimmed[0] : '');
          if (optLetter == correctLetter) {
            fullCorrectOption = opt;
            break;
          }
        }
        correctAnswersList.add({
           'questionId': question.id.toString(),
           'correctAnswer': fullCorrectOption.isNotEmpty ? fullCorrectOption : correctLetter
        });
      }

      double scorePercentage = currentState.quiz.questions.isEmpty
          ? 0.0
          : (correctCount / currentState.quiz.questions.length) * 100;

      emit(QuizFinished(
        score: scorePercentage,
        correctAnswers: correctAnswersList,
        quiz: currentState.quiz,
        selectedAnswers: currentState.selectedAnswers,
      ));
    }
  }
}
