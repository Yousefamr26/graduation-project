using DataAccess.Entities.RoadMap;

public class QuizAttempt
{
    public int Id { get; set; }
    public int QuizId { get; set; }
    public string UserId { get; set; }

    public DateTime StartedAt { get; set; }
    public DateTime? CompletedAt { get; set; }

    public int Score { get; set; }
    public bool IsCompleted { get; set; }
    public DateTime? FinishedAt { get; set; } = DateTime.MinValue;

    public virtual QuizzesSec6 Quiz { get; set; }
    public virtual ICollection<QuizAnswer> Answers { get; set; }
}