public class QuizAnswer
{
    public int Id { get; set; }

    public int AttemptId { get; set; }
    public int QuestionId { get; set; }

    public string? AnswerText { get; set; }
    public string? AnswerFile { get; set; }

    public virtual QuizAttempt Attempt { get; set; }
    public virtual Question Question { get; set; }
}