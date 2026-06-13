public record QuizAttemptResponse(
       int AttemptId,
       int QuizId,
       string Title,
       string Type,
       int Score,
       bool IsCompleted,
       DateTime StartedAt,
       DateTime? CompletedAt,
       DateTime? FinishedAt,
       IEnumerable<QuizAttemptAnswerResponse> Answers
   );