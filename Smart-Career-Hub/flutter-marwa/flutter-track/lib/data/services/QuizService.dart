import 'api_service.dart';
import '../models/Student/quiz-model.dart';

class QuizService {
  /// Fetches the generated quiz for a roadmap.
  /// Path: GET /api/Roadmaps/{roadmapId}/generated-quiz
  Future<QuizModel?> getGeneratedQuiz(String roadmapId, {required String? userType}) async {
    final res = await ApiService.get('/Roadmaps/$roadmapId/generated-quiz', userType: userType);
    if (res == null) return null;
    
    // Parse dynamically to fit both direct map structures and nested maps
    if (res is Map) {
      final data = res['data'];
      if (data is List && data.isNotEmpty) {
        final sortedData = List<Map<String, dynamic>>.from(data);
        sortedData.sort((a, b) => ((b['id'] ?? 0) as int).compareTo((a['id'] ?? 0) as int));
        return QuizModel.fromMap(sortedData[0]);
      } else if (data is Map) {
        return QuizModel.fromMap(Map<String, dynamic>.from(data));
      }
      return QuizModel.fromMap(Map<String, dynamic>.from(res));
    } else if (res is List && res.isNotEmpty) {
      final sortedData = List<Map<String, dynamic>>.from(res);
      sortedData.sort((a, b) => ((b['id'] ?? 0) as int).compareTo((a['id'] ?? 0) as int));
      return QuizModel.fromMap(sortedData[0]);
    }
    
    throw Exception('Invalid response format for quiz');
  }

  /// Submits an answer to a question in the quiz.
  /// Path: POST /api/student/roadmaps/{roadmapId}/quizzes/{quizId}/submit
  Future<void> submitAnswer(
    String roadmapId,
    String quizId,
    String questionId,
    String answer, {
    required String? userType,
  }) async {
    final body = {
      'questionId': questionId,
      'question_id': questionId,
      'answer': answer,
      'selectedAnswer': answer,
      'selectedOption': answer,
    };
    await ApiService.post(
      '/student/roadmaps/$roadmapId/quizzes/$quizId/submit',
      data: body,
      userType: userType,
    );
  }

  /// Finishes the quiz session.
  /// Path: POST /api/student/roadmaps/{roadmapId}/quizzes/{quizId}/finish
  Future<void> finishQuiz(
    String roadmapId,
    String quizId, {
    required String? userType,
  }) async {
    await ApiService.post(
      '/student/roadmaps/$roadmapId/quizzes/$quizId/finish',
      userType: userType,
    );
  }

  /// Gets the final score.
  /// Path: GET /api/student/roadmaps/{roadmapId}/quizzes/{quizId}/score
  Future<double> getScore(
    String roadmapId,
    String quizId, {
    required String? userType,
  }) async {
    final res = await ApiService.get(
      '/student/roadmaps/$roadmapId/quizzes/$quizId/score',
      userType: userType,
    );
    if (res is num) {
      return res.toDouble();
    } else if (res is Map) {
      final val = res['score'] ?? res['data']?['score'] ?? res['totalScore'] ?? res['data']?['totalScore'] ?? 0;
      return (val is num) ? val.toDouble() : (double.tryParse(val.toString()) ?? 0.0);
    }
    return 0.0;
  }

  /// Gets all correct answers.
  /// Path: GET /api/student/roadmaps/{roadmapId}/quizzes/{quizId}/answers
  Future<List<dynamic>> getAnswers(
    String roadmapId,
    String quizId, {
    required String? userType,
  }) async {
    final res = await ApiService.get(
      '/student/roadmaps/$roadmapId/quizzes/$quizId/answers',
      userType: userType,
    );
    if (res is List) {
      return res;
    } else if (res is Map && res['data'] is List) {
      return res['data'];
    }
    return [];
  }
}
